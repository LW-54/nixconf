//! Pure Model-A Fractal Uniform Agency (`ADR-0002` + `ADR-0003` + `ADR-0008`):
//!
//! - **ONE universal `AgentManifest`** covers Atomic Agents, Nested Dressed Superagents
//!   (`web-stack`), Standalone Portable Tools (`git`), Orthogonal Substrate Agents
//!   (`target-nixos-efi`, `storage-ephemeral`, `sub-home-hjem`), and Closed Root Hosts
//!   (`astrolabe`, `live-iso`). There is **no** separate `HostManifest` type.
//! - **Parameters ARE Promises**: configurable inputs are declared as standard `-b`
//!   requirements (`requires."config:*"`), satisfied by enclosing Dressed Superagents via
//!   `internal_offers` or private child-scoped `offers` wrappers (zero sibling pollution!).
//! - **Strictly Non-Piercing (`ADR-0006` C2)**: Every parent observes **only** its direct
//!   children's exterior surfaces (`offers`, `requires`, coarse-grained `budgets`, `state`,
//!   and `contributes_traits`) — never piercing nested Superagent interiors.
//! - **Closed TCB**: `build_agent_tree` compiles any Superagent directly into the recursive
//!   [`Agent`] AST verified identically by Rust `check_agent_tree` and Lean 4 `aky-oracle`!

use std::collections::{BTreeMap, BTreeSet};

use serde::{Deserialize, Serialize};
use serde_json::Value;

use crate::agency::{
    Agent, BoundaryError, Cardinality, ExteriorSurface, Polarity, Promise, SoftContract, Strength,
    derive_substrate, sibling_operational_view, total_budget_supply,
    validate_superagent_conformance,
};
use crate::attr_expr::AttrExpr;
use crate::authority::Entity;
use crate::binding::{BindingError, check_agent_tree, inbound_from_exterior, validate_scope};
use crate::drt::OracleRequest;
use crate::state::{StateError, StateVolume, needs_local_persistence, validate_volumes};

/// Promise offer (`+b`) declared in `[offers."<name>"]` or `[internal_offers."<name>"]`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct OfferSpec {
    /// Optional explicit promise contract type (`τ`); defaults to the TOML table key when omitted.
    #[serde(default)]
    pub ptype: Option<String>,
    /// Optional explicit commutative merge key; defaults to the TOML table key when omitted.
    #[serde(default)]
    pub key: Option<String>,
    /// Binding cardinality (defaults to `Exclusive`).
    #[serde(default = "default_exclusive")]
    pub kind: Cardinality,
    /// Enforcement strength (defaults to `Hard`).
    #[serde(default = "default_hard")]
    pub strength: Strength,
    /// Quantitative resource supply for `Budgeted` promises (e.g., RAM MiB).
    #[serde(default)]
    pub amount: u64,
    /// Optional tags for `Partitioned` matching.
    #[serde(default)]
    pub tags: Vec<String>,
    /// Optional soft-promise contract metadata (mandatory when `strength = "soft"`).
    #[serde(default)]
    pub soft: Option<SoftContract>,
    /// Arbitrary typed offer payload fields passed across `Σ` into bound consumers (`bound.<key>.*`).
    #[serde(flatten)]
    pub payload: BTreeMap<String, Value>,
}

impl OfferSpec {
    /// Returns the resolved promise type (`ptype` if set, otherwise `table_key`).
    #[must_use]
    pub fn resolved_ptype<'a>(&'a self, table_key: &'a str) -> &'a str {
        self.ptype.as_deref().unwrap_or(table_key)
    }

    /// Returns the resolved commutative key (`key` if set, otherwise `table_key`).
    #[must_use]
    pub fn resolved_key<'a>(&'a self, table_key: &'a str) -> &'a str {
        self.key.as_deref().unwrap_or(table_key)
    }
}

/// Promise requirement (`-b`) declared in `[requires."<name>"]` (also models typed parameters!).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct RequireSpec {
    /// Optional explicit promise contract type (`τ`); defaults to the TOML table key when omitted.
    #[serde(default)]
    pub ptype: Option<String>,
    /// Optional explicit commutative merge key; defaults to the TOML table key when omitted.
    #[serde(default)]
    pub key: Option<String>,
    /// Binding cardinality (defaults to `Exclusive`).
    #[serde(default = "default_exclusive")]
    pub kind: Cardinality,
    /// Enforcement strength (defaults to `Hard`).
    #[serde(default = "default_hard")]
    pub strength: Strength,
    /// Whether an unsatisfied `Hard` requirement fails verification (defaults to `true`).
    #[serde(default = "default_true")]
    pub mandatory: bool,
    /// Optional `AttrExpr` selector for `Partitioned` handlers.
    #[serde(default = "default_any")]
    pub selector: AttrExpr,
    /// Optional soft-promise contract metadata.
    #[serde(default)]
    pub soft: Option<SoftContract>,
    /// Optional fallback payload used when `mandatory = false` and no offer exists in scope.
    #[serde(default)]
    pub default: Option<Value>,
}

impl RequireSpec {
    /// Returns the resolved promise type (`ptype` if set, otherwise `table_key`).
    #[must_use]
    pub fn resolved_ptype<'a>(&'a self, table_key: &'a str) -> &'a str {
        self.ptype.as_deref().unwrap_or(table_key)
    }

    /// Returns the resolved commutative key (`key` if set, otherwise `table_key`).
    #[must_use]
    pub fn resolved_key<'a>(&'a self, table_key: &'a str) -> &'a str {
        self.key.as_deref().unwrap_or(table_key)
    }
}

/// Resource budget envelope declared in `[budgets]` (compiles to `Budgeted` `-b ram` promises).
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct BudgetSpec {
    /// RAM demand in MiB.
    #[serde(default)]
    pub ram_mib: u64,
    /// Priority tier (`"critical"` = 0, otherwise 1).
    #[serde(default = "default_tier")]
    pub tier: String,
}

/// Open composable state volume declared in `[state.<name>]`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct StateSpec {
    /// Mount/directory path owned or surfaced by this agent.
    pub path: String,
    /// Open composable state traits (e.g., `["survives-reboot", "backup-required", "single-auth-writer"]`).
    #[serde(default)]
    pub traits: Vec<String>,
}

/// Child reference inside a Dressed Superagent's `contains = [ ... ]`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ChildRef {
    /// Referenced agent ID under `agents/`.
    pub agent: String,
    /// Optional local instance alias for multi-instance instantiation (`QA-02`).
    #[serde(default)]
    pub instance: Option<String>,
    /// Optional child-scoped `+b` offers wrapped in a private 1-child Dressed Superagent.
    #[serde(default)]
    pub offers: BTreeMap<String, OfferSpec>,
}

impl ChildRef {
    /// Returns the local unique node name (`instance` if set, otherwise `agent`).
    #[must_use]
    pub fn local_name(&self) -> &str {
        self.instance.as_deref().unwrap_or(&self.agent)
    }
}

/// Optional realization metadata for a closed root Dressed Superagent (e.g., a NixOS host/image).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct RealizeSpec {
    /// Target architecture (`"x86_64-linux"`, `"aarch64-linux"`, etc.).
    pub system: String,
}

/// Universal Model-A Agent manifest parsed from `agents/<name>/agent.toml`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct AgentManifest {
    /// Unique agent identifier.
    pub id: String,
    /// Optional role tag (`"atomic"`, `"standalone"`, `"substrate"`, `"superagent"`).
    #[serde(default = "default_atomic")]
    pub kind: String,
    /// Human-readable description (enforces `QA-04`).
    #[serde(default)]
    pub description: String,
    /// Factual Cedar `L3+` attributes (`["role:server", "env:prod"]`).
    #[serde(default)]
    pub attributes: Vec<String>,
    /// Open substrate traits contributed by this agent (arbitrary-axis composition, `ADR-0010`).
    #[serde(default)]
    pub contributes_traits: Vec<String>,
    /// Optional root target realization metadata (present on deployable hosts/images).
    #[serde(default)]
    pub realize: Option<RealizeSpec>,
    /// Transparent profiles (`P-Dual`) flattened into this superagent's interior.
    #[serde(default)]
    pub profiles: Vec<String>,
    /// Direct child agents contained inside this Dressed Superagent (`CONTAINS`).
    #[serde(default)]
    pub contains: Vec<ChildRef>,
    /// Interior-only `+b` promises offered inside this superagent's scope.
    #[serde(default)]
    pub internal_offers: BTreeMap<String, OfferSpec>,
    /// Exterior `+b` promises exported across `Σ`.
    #[serde(default)]
    pub offers: BTreeMap<String, OfferSpec>,
    /// Exterior `-b` promises required across `Σ` (including typed parameters!).
    #[serde(default)]
    pub requires: BTreeMap<String, RequireSpec>,
    /// Coarse-grained exterior resource budget envelope (`C4`).
    #[serde(default)]
    pub budgets: BudgetSpec,
    /// Exterior agent-declared state volumes (`S2+`).
    #[serde(default)]
    pub state: BTreeMap<String, StateSpec>,
}

impl AgentManifest {
    /// Returns `true` iff this agent is a Dressed Superagent (`contains` or `profiles` non-empty).
    #[must_use]
    pub const fn is_superagent(&self) -> bool {
        !self.contains.is_empty() || !self.profiles.is_empty()
    }

    /// Returns `true` iff this agent is a deployable closed root target (`[realize]` present).
    #[must_use]
    pub const fn is_root_target(&self) -> bool {
        self.realize.is_some()
    }
}

/// Transparent Profile (`P-Dual`, `profiles/<name>.toml`): flat sibling set with zero boundary ceremony.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ProfileManifest {
    /// Unique profile identifier.
    pub id: String,
    /// Optional description.
    #[serde(default)]
    pub description: String,
    /// Nested transparent profiles flattened recursively.
    #[serde(default)]
    pub profiles: Vec<String>,
    /// Sibling agents included by this profile.
    #[serde(default)]
    pub agents: Vec<String>,
}

/// Cedar policy + entity catalog parsed from `policies/*.toml`.
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct PolicyCatalog {
    /// Known principals (humans, AI agents, CI runners, hosts).
    #[serde(default)]
    pub principals: Vec<Entity>,
    /// Governed resources (secrets, caches, deployment targets).
    #[serde(default)]
    pub resources: Vec<Entity>,
    /// Cedar `Permit` / `Forbid` policies.
    #[serde(default)]
    pub policies: Vec<crate::authority::AuthPolicy>,
}

/// Complete in-memory Antikythera fleet specification (100% pure data, zero `std::fs`!).
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct FleetSpec {
    /// Universal catalog of ALL agents (atomic, standalone, substrate, nested superagents, and root hosts!).
    pub agents: BTreeMap<String, AgentManifest>,
    /// Transparent profiles (`P-Dual`).
    pub profiles: BTreeMap<String, ProfileManifest>,
    /// Cedar `L3+` authorization policies and entities.
    pub policy_catalog: PolicyCatalog,
}

/// Recursive verification report for a Dressed Superagent (including root hosts & nested stacks!).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct SuperagentReport {
    /// Agent identifier.
    pub agent_id: String,
    /// Optional target system architecture (present on root targets).
    pub system: Option<String>,
    /// Direct children inside this superagent (after `P-Dual` profile flattening).
    pub direct_children: Vec<String>,
    /// Missing agent/profile references or containment cycles.
    pub missing_refs: Vec<String>,
    /// `B3` scoped binding errors inside this superagent's interior (and local child wrappers).
    pub binding_errors: Vec<BindingError>,
    /// `P-Explicit` interior conformance errors (offers, uses, budgets, state volumes).
    pub boundary_errors: Vec<BoundaryError>,
    /// `S2+` open-trait & CALM state safety errors on direct children's exterior volumes.
    pub state_errors: Vec<StateError>,
    /// Recursive `check_agent_tree` verdict mirroring Lean 4 `Aky.Spec.checkAgentTree` 1:1.
    pub tree_valid: bool,
    /// Non-piercing paths requiring local persistence (read strictly from direct children's exteriors!).
    pub persistent_paths: Vec<String>,
}

impl SuperagentReport {
    /// Returns `true` iff this superagent and its entire recursive tree passed every check.
    #[must_use]
    pub const fn is_valid(&self) -> bool {
        self.tree_valid
            && self.missing_refs.is_empty()
            && self.binding_errors.is_empty()
            && self.boundary_errors.is_empty()
            && self.state_errors.is_empty()
    }
}

/// Fleet-wide verification report returned by [`verify_fleet`].
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct FleetReport {
    /// Reports for every Dressed Superagent (both nested stacks like `web-stack` AND root hosts like `astrolabe`!).
    pub superagents: BTreeMap<String, SuperagentReport>,
    /// Standalone agents validated as store-only (`X4`).
    pub standalone_agents: Vec<String>,
}

impl FleetReport {
    /// Returns `true` iff every Dressed Superagent in the fleet is valid.
    #[must_use]
    pub fn is_valid(&self) -> bool {
        self.superagents.values().all(SuperagentReport::is_valid)
    }
}

/// Deterministic `S1` binding resolution output for a root Dressed Superagent,
/// mirroring `v2/lib/realize.nix` bit-for-bit!
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct ResolvedTargetBindings {
    /// Root superagent identifier (e.g., `"astrolabe"`).
    pub root_id: String,
    /// Target architecture.
    pub system: String,
    /// Sorted list of materialized leaf atomic agent instance paths (e.g., `"web-stack/vaultwarden"`).
    pub leaf_instances: Vec<String>,
    /// Sorted list of state paths requiring local persistence (non-piercing direct exterior view!).
    pub persistent_paths: Vec<String>,
    /// Per-leaf-instance resolved `bound` map (`instance_path -> req_key -> resolved_payload`).
    pub bound_by_instance: BTreeMap<String, BTreeMap<String, Value>>,
}

const fn default_exclusive() -> Cardinality {
    Cardinality::Exclusive
}

const fn default_hard() -> Strength {
    Strength::Hard
}

const fn default_true() -> bool {
    true
}

const fn default_any() -> AttrExpr {
    AttrExpr::Any
}

fn default_tier() -> String {
    "best-effort".to_string()
}

fn default_atomic() -> String {
    "atomic".to_string()
}

fn offer_to_promise(prefix: &str, table_key: &str, spec: &OfferSpec, stratum: u64) -> Promise {
    let ptype = spec.resolved_ptype(table_key);
    let key = spec.resolved_key(table_key);
    Promise {
        id: format!("{prefix}:+{table_key}"),
        ptype: ptype.to_string(),
        key: key.to_string(),
        polarity: Polarity::Offer,
        strength: spec.strength,
        cardinality: spec.kind,
        mandatory: true,
        amount: spec.amount,
        priority: 0,
        stratum,
        tags: spec.tags.clone(),
        selector: AttrExpr::Any,
        soft_info: spec.soft.clone(),
    }
}

fn require_to_promise(prefix: &str, table_key: &str, spec: &RequireSpec, stratum: u64) -> Promise {
    let ptype = spec.resolved_ptype(table_key);
    let key = spec.resolved_key(table_key);
    Promise {
        id: format!("{prefix}:-{table_key}"),
        ptype: ptype.to_string(),
        key: key.to_string(),
        polarity: Polarity::Use,
        strength: spec.strength,
        cardinality: spec.kind,
        mandatory: spec.mandatory,
        amount: 0,
        priority: 0,
        stratum,
        tags: Vec::new(),
        selector: spec.selector.clone(),
        soft_info: spec.soft.clone(),
    }
}

fn offer_to_json(spec: &OfferSpec) -> Value {
    let mut map = serde_json::Map::new();
    if let Ok(kind_val) = serde_json::to_value(spec.kind) {
        map.insert("kind".to_string(), kind_val);
    }
    if spec.amount > 0 {
        map.insert("amount".to_string(), Value::from(spec.amount));
    }
    for (k, v) in &spec.payload {
        map.insert(k.clone(), v.clone());
    }
    Value::Object(map)
}

/// Flattens `P-Dual` transparent profiles + explicit `contains` children for a superagent.
fn expand_children(fleet: &FleetSpec, agent: &AgentManifest) -> (Vec<ChildRef>, Vec<String>) {
    let mut visited_profiles = BTreeSet::new();
    let mut stack: Vec<String> = agent.profiles.clone();
    let mut by_local_name: BTreeMap<String, ChildRef> = BTreeMap::new();
    let mut missing = Vec::new();

    while let Some(pid) = stack.pop() {
        if !visited_profiles.insert(pid.clone()) {
            continue;
        }
        if let Some(prof) = fleet.profiles.get(&pid) {
            for sub in &prof.profiles {
                stack.push(sub.clone());
            }
            for aid in &prof.agents {
                by_local_name
                    .entry(aid.clone())
                    .or_insert_with(|| ChildRef {
                        agent: aid.clone(),
                        instance: None,
                        offers: BTreeMap::new(),
                    });
            }
        } else {
            missing.push(format!("profile:{pid}"));
        }
    }

    for ch in &agent.contains {
        by_local_name.insert(ch.local_name().to_string(), ch.clone());
    }

    for ch in by_local_name.values() {
        if !fleet.agents.contains_key(&ch.agent) {
            missing.push(format!("agent:{}", ch.agent));
        }
    }

    (by_local_name.into_values().collect(), missing)
}

/// Builds an agent's strictly NON-PIERCING exterior surface (`Π_ext`) from its own manifest ONLY!
fn build_agent_exterior(agent: &AgentManifest, local_id: &str) -> ExteriorSurface {
    let mut promises = Vec::new();
    if agent.budgets.ram_mib > 0 {
        promises.push(Promise {
            id: format!("{local_id}:-ram"),
            ptype: "ram".to_string(),
            key: "ram".to_string(),
            polarity: Polarity::Use,
            strength: Strength::Hard,
            cardinality: Cardinality::Budgeted,
            mandatory: true,
            amount: agent.budgets.ram_mib,
            priority: u64::from(agent.budgets.tier != "critical"),
            stratum: 1,
            tags: Vec::new(),
            selector: AttrExpr::Any,
            soft_info: None,
        });
    }
    for (k, o) in &agent.offers {
        promises.push(offer_to_promise(local_id, k, o, 1));
    }
    for (k, r) in &agent.requires {
        promises.push(require_to_promise(local_id, k, r, 1));
    }

    let mut attributes = agent.attributes.clone();
    for tr in &agent.contributes_traits {
        attributes.push(format!("trait:{tr}"));
    }

    let volumes = agent
        .state
        .values()
        .map(|vspec| StateVolume {
            id: vspec.path.clone(),
            owner: local_id.to_string(),
            traits: vspec.traits.clone(),
        })
        .collect();

    ExteriorSurface {
        agent_id: local_id.to_string(),
        promises,
        attributes,
        volumes,
    }
}

fn local_offers_satisfy(local_ps: &[Promise], use_p: &Promise) -> bool {
    match use_p.cardinality {
        Cardinality::Partitioned => local_ps.iter().any(|o| {
            o.polarity == Polarity::Offer
                && o.cardinality == Cardinality::Partitioned
                && o.ptype == use_p.ptype
                && use_p.selector.eval(&o.tags)
        }),
        Cardinality::Broadcast => local_ps
            .iter()
            .any(|o| o.polarity == Polarity::Offer && o.ptype == use_p.ptype),
        Cardinality::Budgeted => total_budget_supply(local_ps.iter(), &use_p.ptype) >= use_p.amount,
        Cardinality::Exclusive => local_ps
            .iter()
            .any(|o| o.polarity == Polarity::Offer && o.ptype == use_p.ptype && o.key == use_p.key),
    }
}

fn wrap_with_local_offers(
    child_agent: &AgentManifest,
    local_name: &str,
    local_offers: &BTreeMap<String, OfferSpec>,
    child_tree: Agent,
) -> Agent {
    let local_ps: Vec<Promise> = local_offers
        .iter()
        .map(|(k, o)| offer_to_promise(&format!("{local_name}:offers"), k, o, 0))
        .collect();
    let mut wrapper_ext = build_agent_exterior(child_agent, local_name);
    wrapper_ext
        .promises
        .retain(|p| p.polarity != Polarity::Use || !local_offers_satisfy(&local_ps, p));
    let offers_node = Agent::Atomic {
        ext: ExteriorSurface {
            agent_id: format!("{local_name}:offers"),
            promises: local_ps,
            attributes: Vec::new(),
            volumes: Vec::new(),
        },
        interior_hash: "local-offers".to_string(),
    };
    Agent::Superagent {
        ext: wrapper_ext,
        children: vec![offers_node, child_tree],
    }
}

fn build_agent_tree_rec(
    fleet: &FleetSpec,
    agent: &AgentManifest,
    local_id: &str,
    visited: &mut BTreeSet<String>,
    missing_refs: &mut Vec<String>,
) -> Agent {
    let ext = build_agent_exterior(agent, local_id);
    if !agent.is_superagent() {
        return Agent::Atomic {
            ext,
            interior_hash: format!("atomic:{local_id}"),
        };
    }
    if !visited.insert(agent.id.clone()) {
        missing_refs.push(format!("cycle:{}", agent.id));
        return Agent::Atomic {
            ext,
            interior_hash: "cycle".to_string(),
        };
    }

    let (children_refs, local_missing) = expand_children(fleet, agent);
    missing_refs.extend(local_missing);

    let mut child_agents = Vec::new();
    if !agent.internal_offers.is_empty() {
        let ambient_ps: Vec<Promise> = agent
            .internal_offers
            .iter()
            .map(|(k, o)| offer_to_promise(&format!("{local_id}:internal"), k, o, 0))
            .collect();
        child_agents.push(Agent::Atomic {
            ext: ExteriorSurface {
                agent_id: format!("{local_id}:internal"),
                promises: ambient_ps,
                attributes: Vec::new(),
                volumes: Vec::new(),
            },
            interior_hash: "internal".to_string(),
        });
    }

    for ch in &children_refs {
        if let Some(child_agent) = fleet.agents.get(&ch.agent) {
            let local = ch.local_name();
            let child_tree = build_agent_tree_rec(fleet, child_agent, local, visited, missing_refs);
            if ch.offers.is_empty() {
                child_agents.push(child_tree);
            } else {
                child_agents.push(wrap_with_local_offers(
                    child_agent,
                    local,
                    &ch.offers,
                    child_tree,
                ));
            }
        }
    }

    visited.remove(&agent.id);
    Agent::Superagent {
        ext,
        children: child_agents,
    }
}

/// Compiles any Agent into its exact recursive [`Agent`] AST (mirroring `Aky.Spec.Agent` 1:1).
#[must_use]
pub fn build_agent_tree(fleet: &FleetSpec, agent_id: &str) -> Option<(Agent, Vec<String>)> {
    let agent = fleet.agents.get(agent_id)?;
    let mut visited = BTreeSet::new();
    let mut missing = Vec::new();
    let tree = build_agent_tree_rec(fleet, agent, &agent.id, &mut visited, &mut missing);
    Some((tree, missing))
}

fn direct_persistent_paths(ext: &ExteriorSurface, children: &[Agent]) -> Vec<String> {
    let mut set = BTreeSet::new();
    for v in &ext.volumes {
        if needs_local_persistence(&v.traits) {
            set.insert(v.id.clone());
        }
    }
    for surf in sibling_operational_view(children) {
        for v in &surf.volumes {
            if needs_local_persistence(&v.traits) {
                set.insert(v.id.clone());
            }
        }
    }
    set.into_iter().collect()
}

fn collect_local_wrapper_errors(
    children: &[Agent],
    binding_errors: &mut Vec<BindingError>,
    boundary_errors: &mut Vec<BoundaryError>,
) {
    for ch in children {
        if let Agent::Superagent {
            ext,
            children: w_children,
        } = ch
        {
            let is_local_wrapper = w_children.iter().any(|wc| {
                matches!(wc, Agent::Atomic { interior_hash, .. } if interior_hash == "local-offers")
            });
            if is_local_wrapper {
                let mut w_scope = inbound_from_exterior(ext);
                for surf in sibling_operational_view(w_children) {
                    w_scope.extend(surf.promises.iter().cloned());
                }
                binding_errors.extend(validate_scope(&w_scope));
                boundary_errors.extend(validate_superagent_conformance(ext, w_children));
            }
        }
    }
}

/// Verifies every Dressed Superagent (both nested stacks and closed root targets) and standalone agent
/// strictly without interior piercing!
#[must_use]
pub fn verify_fleet(fleet: &FleetSpec) -> FleetReport {
    let mut superagents = BTreeMap::new();
    for (aid, agent) in &fleet.agents {
        if !agent.is_superagent() {
            continue;
        }
        let (children_refs, _) = expand_children(fleet, agent);
        let direct_children: Vec<String> = children_refs
            .iter()
            .map(|c| c.local_name().to_string())
            .collect();
        let Some((tree, missing_refs)) = build_agent_tree(fleet, aid) else {
            continue;
        };
        let tree_valid = check_agent_tree(&tree);

        let (binding_errors, boundary_errors, state_errors, persistent_paths) =
            if let Agent::Superagent { ext, children } = &tree {
                let int_surfaces = sibling_operational_view(children);
                let mut scope_ps = inbound_from_exterior(ext);
                for surf in &int_surfaces {
                    scope_ps.extend(surf.promises.iter().cloned());
                }
                let mut bind_errs = validate_scope(&scope_ps);
                let mut bound_errs = validate_superagent_conformance(ext, children);
                collect_local_wrapper_errors(children, &mut bind_errs, &mut bound_errs);

                let state_errs = if agent.is_root_target() {
                    let sub = derive_substrate(&int_surfaces);
                    let direct_vols: Vec<StateVolume> = int_surfaces
                        .iter()
                        .flat_map(|s| s.volumes.iter().cloned())
                        .collect();
                    validate_volumes(&sub, &direct_vols)
                } else {
                    Vec::new()
                };
                let persist = direct_persistent_paths(ext, children);
                (bind_errs, bound_errs, state_errs, persist)
            } else {
                (Vec::new(), Vec::new(), Vec::new(), Vec::new())
            };

        superagents.insert(
            aid.clone(),
            SuperagentReport {
                agent_id: aid.clone(),
                system: agent.realize.as_ref().map(|r| r.system.clone()),
                direct_children,
                missing_refs,
                binding_errors,
                boundary_errors,
                state_errors,
                tree_valid,
                persistent_paths,
            },
        );
    }

    let standalone_agents = fleet
        .agents
        .iter()
        .filter(|(_, a)| {
            a.kind == "standalone"
                && a.requires
                    .values()
                    .all(|r| !(r.strength == Strength::Hard && r.mandatory))
        })
        .map(|(id, _)| id.clone())
        .collect();

    FleetReport {
        superagents,
        standalone_agents,
    }
}

#[derive(Clone, Debug)]
struct ScopeOffer {
    ptype: String,
    key: String,
    kind: Cardinality,
    tags: Vec<String>,
    value: Value,
}

fn collect_scope_offers(
    fleet: &FleetSpec,
    agent: &AgentManifest,
    children: &[ChildRef],
    inbound_bound: &BTreeMap<String, Value>,
) -> Vec<ScopeOffer> {
    let mut offers = Vec::new();
    for (rkey, rspec) in &agent.requires {
        if let Some(val) = inbound_bound.get(rkey) {
            let ptype = rspec.resolved_ptype(rkey).to_string();
            let key = rspec.resolved_key(rkey).to_string();
            offers.push(ScopeOffer {
                ptype,
                key,
                kind: rspec.kind,
                tags: Vec::new(),
                value: val.clone(),
            });
        }
    }
    for (k, o) in &agent.internal_offers {
        offers.push(ScopeOffer {
            ptype: o.resolved_ptype(k).to_string(),
            key: o.resolved_key(k).to_string(),
            kind: o.kind,
            tags: o.tags.clone(),
            value: offer_to_json(o),
        });
    }
    for ch in children {
        if let Some(child_agent) = fleet.agents.get(&ch.agent) {
            for (k, o) in &child_agent.offers {
                offers.push(ScopeOffer {
                    ptype: o.resolved_ptype(k).to_string(),
                    key: o.resolved_key(k).to_string(),
                    kind: o.kind,
                    tags: o.tags.clone(),
                    value: offer_to_json(o),
                });
            }
        }
    }
    offers
}

fn bind_child_requires(
    child_agent: &AgentManifest,
    scope_offers: &[ScopeOffer],
    local_offers: &[ScopeOffer],
) -> BTreeMap<String, Value> {
    let mut bound = BTreeMap::new();
    for (rkey, rspec) in &child_agent.requires {
        let req_ptype = rspec.resolved_ptype(rkey);
        let req_key = rspec.resolved_key(rkey);
        match rspec.kind {
            Cardinality::Partitioned => {
                let mut matched = serde_json::Map::new();
                for o in scope_offers.iter().chain(local_offers.iter()) {
                    if o.ptype == req_ptype
                        && o.kind == Cardinality::Partitioned
                        && rspec.selector.eval(&o.tags)
                    {
                        matched.insert(o.key.clone(), o.value.clone());
                    }
                }
                bound.insert(rkey.clone(), Value::Object(matched));
            }
            Cardinality::Broadcast => {
                let mut matched = serde_json::Map::new();
                for o in scope_offers.iter().chain(local_offers.iter()) {
                    if o.ptype == req_ptype {
                        matched.insert(o.key.clone(), o.value.clone());
                    }
                }
                bound.insert(rkey.clone(), Value::Object(matched));
            }
            Cardinality::Exclusive | Cardinality::Budgeted => {
                if let Some(o) = local_offers
                    .iter()
                    .rev()
                    .find(|o| o.ptype == req_ptype && o.key == req_key)
                    .or_else(|| {
                        scope_offers
                            .iter()
                            .rev()
                            .find(|o| o.ptype == req_ptype && o.key == req_key)
                    })
                {
                    bound.insert(rkey.clone(), o.value.clone());
                } else if let Some(def) = &rspec.default {
                    bound.insert(rkey.clone(), def.clone());
                }
            }
        }
    }
    bound
}

fn resolve_recursive(
    fleet: &FleetSpec,
    agent: &AgentManifest,
    prefix: &str,
    inbound_bound: &BTreeMap<String, Value>,
    leaf_instances: &mut Vec<String>,
    bound_by_instance: &mut BTreeMap<String, BTreeMap<String, Value>>,
) {
    if !agent.is_superagent() {
        leaf_instances.push(prefix.to_string());
        bound_by_instance.insert(prefix.to_string(), inbound_bound.clone());
        return;
    }

    let (children, _) = expand_children(fleet, agent);
    let scope_offers = collect_scope_offers(fleet, agent, &children, inbound_bound);

    for ch in children {
        if let Some(child_agent) = fleet.agents.get(&ch.agent) {
            let child_path = if prefix.is_empty() {
                ch.local_name().to_string()
            } else {
                format!("{prefix}/{}", ch.local_name())
            };
            let local_offers: Vec<ScopeOffer> = ch
                .offers
                .iter()
                .map(|(k, o)| ScopeOffer {
                    ptype: o.resolved_ptype(k).to_string(),
                    key: o.resolved_key(k).to_string(),
                    kind: o.kind,
                    tags: o.tags.clone(),
                    value: offer_to_json(o),
                })
                .collect();
            let child_bound = bind_child_requires(child_agent, &scope_offers, &local_offers);
            resolve_recursive(
                fleet,
                child_agent,
                &child_path,
                &child_bound,
                leaf_instances,
                bound_by_instance,
            );
        }
    }
}

/// Deterministically resolves recursive non-piercing `bound` maps & direct `persistent_paths`
/// for any root Dressed Superagent, mirroring `v2/lib/realize.nix` bit-for-bit!
#[must_use]
pub fn resolve_target_bindings(fleet: &FleetSpec, root_id: &str) -> Option<ResolvedTargetBindings> {
    let root = fleet.agents.get(root_id)?;
    let realize = root.realize.as_ref()?;
    let (tree, _) = build_agent_tree(fleet, root_id)?;
    let persistent_paths = if let Agent::Superagent { ext, children } = &tree {
        direct_persistent_paths(ext, children)
    } else {
        Vec::new()
    };

    let mut leaf_instances = Vec::new();
    let mut bound_by_instance = BTreeMap::new();
    resolve_recursive(
        fleet,
        root,
        "",
        &BTreeMap::new(),
        &mut leaf_instances,
        &mut bound_by_instance,
    );
    leaf_instances.sort();

    Some(ResolvedTargetBindings {
        root_id: root.id.clone(),
        system: realize.system.clone(),
        leaf_instances,
        persistent_paths,
        bound_by_instance,
    })
}

/// Projects any Dressed Superagent's FULL RECURSIVE [`Agent`] tree + policies into an
/// [`OracleRequest`] for live AWS Cedar DRT against the 41-theorem Lean 4 `aky-oracle`!
#[must_use]
pub fn superagent_to_oracle_request(fleet: &FleetSpec, agent_id: &str) -> Option<OracleRequest> {
    let agent = fleet.agents.get(agent_id)?;
    if !agent.is_superagent() {
        return None;
    }
    let (agent_tree, _) = build_agent_tree(fleet, agent_id)?;
    let (scope_promises, substrate, direct_vols) =
        if let Agent::Superagent { ext, children } = &agent_tree {
            let int_surfaces = sibling_operational_view(children);
            let mut ps = inbound_from_exterior(ext);
            for surf in &int_surfaces {
                ps.extend(surf.promises.iter().cloned());
            }
            let sub = derive_substrate(&int_surfaces);
            let vols: Vec<StateVolume> = int_surfaces
                .iter()
                .flat_map(|s| s.volumes.iter().cloned())
                .collect();
            (ps, sub, vols)
        } else {
            return None;
        };

    let blast_target = fleet
        .policy_catalog
        .principals
        .first()
        .cloned()
        .unwrap_or_else(|| Entity {
            id: agent.id.clone(),
            tags: agent.attributes.clone(),
        });

    let mut auth_queries = Vec::new();
    for p in &fleet.policy_catalog.principals {
        for r in &fleet.policy_catalog.resources {
            auth_queries.push(crate::drt::AuthQuery {
                principal: p.clone(),
                action: "read-secret".to_string(),
                resource: r.clone(),
            });
        }
    }

    let volumes = if agent.is_root_target() {
        direct_vols
    } else {
        Vec::new()
    };

    Some(OracleRequest {
        agent_tree,
        promises: scope_promises,
        stratum_rules: Vec::new(),
        policies: fleet.policy_catalog.policies.clone(),
        auth_queries,
        delegated_queries: Vec::new(),
        blast_target,
        blast_action: "read-secret".to_string(),
        all_resources: fleet.policy_catalog.resources.clone(),
        substrate,
        volumes,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn mk_atomic(id: &str) -> AgentManifest {
        AgentManifest {
            id: id.to_string(),
            kind: "atomic".to_string(),
            description: String::new(),
            attributes: Vec::new(),
            contributes_traits: Vec::new(),
            realize: None,
            profiles: Vec::new(),
            contains: Vec::new(),
            internal_offers: BTreeMap::new(),
            offers: BTreeMap::new(),
            requires: BTreeMap::new(),
            budgets: BudgetSpec::default(),
            state: BTreeMap::new(),
        }
    }

    fn mk_offer() -> OfferSpec {
        OfferSpec {
            ptype: None,
            key: None,
            kind: Cardinality::Exclusive,
            strength: Strength::Hard,
            amount: 0,
            tags: Vec::new(),
            soft: None,
            payload: BTreeMap::new(),
        }
    }

    fn mk_req() -> RequireSpec {
        RequireSpec {
            ptype: None,
            key: None,
            kind: Cardinality::Exclusive,
            strength: Strength::Hard,
            mandatory: true,
            selector: AttrExpr::Any,
            soft: None,
            default: None,
        }
    }

    #[test]
    fn lying_and_leaking_dressed_superagent_caught() {
        let mut child = mk_atomic("vaultwarden");
        child
            .requires
            .insert("secrets:runtime".to_string(), mk_req());

        let mut bad_super = mk_atomic("bad-stack");
        bad_super.kind = "superagent".to_string();
        bad_super.contains.push(ChildRef {
            agent: "vaultwarden".to_string(),
            instance: None,
            offers: BTreeMap::new(),
        });
        bad_super.offers.insert("http:fake".to_string(), mk_offer());

        let mut fleet = FleetSpec::default();
        fleet.agents.insert(child.id.clone(), child);
        fleet.agents.insert(bad_super.id.clone(), bad_super);

        let report = verify_fleet(&fleet);
        let sr = report.superagents.get("bad-stack").unwrap();
        assert!(!sr.is_valid());
        assert!(!sr.tree_valid);
        assert!(sr.boundary_errors.iter().any(
            |e| matches!(e, BoundaryError::UnbackedOffer { ptype, .. } if ptype == "http:fake")
        ));
        assert!(sr.boundary_errors.iter().any(
            |e| matches!(e, BoundaryError::LeakedRequirement { ptype, .. } if ptype == "secrets:runtime")
        ));
    }

    #[test]
    fn missing_parameter_promise_rejected() {
        let mut caddy = mk_atomic("caddy");
        caddy.requires.insert("config:domain".to_string(), mk_req());

        let mut host = mk_atomic("broken-host");
        host.kind = "superagent".to_string();
        host.realize = Some(RealizeSpec {
            system: "x86_64-linux".to_string(),
        });
        host.contains.push(ChildRef {
            agent: "caddy".to_string(),
            instance: None,
            offers: BTreeMap::new(),
        });

        let mut fleet = FleetSpec::default();
        fleet.agents.insert(caddy.id.clone(), caddy);
        fleet.agents.insert(host.id.clone(), host);

        let report = verify_fleet(&fleet);
        let hr = report.superagents.get("broken-host").unwrap();
        assert!(!hr.is_valid());
        assert!(hr.binding_errors.iter().any(|e| matches!(
            e,
            BindingError::ExclusiveMismatch { ptype, offer_count: 0, .. } if ptype == "config:domain"
        )));
    }

    #[test]
    fn gap1_underreported_superagent_budget_and_hidden_state_caught() {
        let mut vw = mk_atomic("vaultwarden");
        vw.budgets = BudgetSpec {
            ram_mib: 256,
            tier: "critical".to_string(),
        };
        vw.state.insert(
            "data".to_string(),
            StateSpec {
                path: "/var/lib/vaultwarden".to_string(),
                traits: vec![
                    "survives-reboot".to_string(),
                    "backup-required".to_string(),
                    "single-auth-writer".to_string(),
                ],
            },
        );

        let mut stack = mk_atomic("cheating-stack");
        stack.kind = "superagent".to_string();
        // Cheats on BOTH RAM (128 < 256) AND tier (best-effort vs critical) AND hides state volume!
        stack.budgets = BudgetSpec {
            ram_mib: 128,
            tier: "best-effort".to_string(),
        };
        stack.contains.push(ChildRef {
            agent: "vaultwarden".to_string(),
            instance: None,
            offers: BTreeMap::new(),
        });

        let mut fleet = FleetSpec::default();
        fleet.agents.insert(vw.id.clone(), vw);
        fleet.agents.insert(stack.id.clone(), stack);

        let report = verify_fleet(&fleet);
        let sr = report.superagents.get("cheating-stack").unwrap();
        assert!(!sr.is_valid());
        assert!(!sr.tree_valid);
        assert!(sr.boundary_errors.iter().any(
            |e| matches!(e, BoundaryError::UnderreportedBudget { ptype, .. } if ptype == "ram")
        ));
        assert!(sr.boundary_errors.iter().any(|e| matches!(
            e,
            BoundaryError::UnderreportedCriticalBudget { ptype, .. } if ptype == "ram"
        )));
        assert!(sr.boundary_errors.iter().any(|e| matches!(
            e,
            BoundaryError::LeakedVolume { volume_id, .. } if volume_id == "/var/lib/vaultwarden"
        )));
    }

    #[test]
    fn gap2_and_gap3_multi_instance_local_offers_no_sibling_collision() {
        let mut rclone = mk_atomic("rclone");
        rclone
            .requires
            .insert("config:remote".to_string(), mk_req());
        let mut bak = mk_offer();
        bak.kind = Cardinality::Broadcast;
        rclone.offers.insert("backup:provider".to_string(), bak);

        let mut gdrive_offer = mk_offer();
        gdrive_offer
            .payload
            .insert("value".to_string(), Value::from("gdrive"));
        let mut b2_offer = mk_offer();
        b2_offer
            .payload
            .insert("value".to_string(), Value::from("b2"));

        let mut host = mk_atomic("multi-host");
        host.kind = "superagent".to_string();
        host.realize = Some(RealizeSpec {
            system: "x86_64-linux".to_string(),
        });
        host.contains.push(ChildRef {
            agent: "rclone".to_string(),
            instance: Some("rclone-gdrive".to_string()),
            offers: BTreeMap::from([("config:remote".to_string(), gdrive_offer)]),
        });
        host.contains.push(ChildRef {
            agent: "rclone".to_string(),
            instance: Some("rclone-b2".to_string()),
            offers: BTreeMap::from([("config:remote".to_string(), b2_offer)]),
        });

        let mut fleet = FleetSpec::default();
        fleet.agents.insert(rclone.id.clone(), rclone);
        fleet.agents.insert(host.id.clone(), host);

        let report = verify_fleet(&fleet);
        let hr = report.superagents.get("multi-host").unwrap();
        assert!(
            hr.is_valid(),
            "expected multi-instance local offers to pass without sibling collision, got: {hr:?}"
        );
        let resolved = resolve_target_bindings(&fleet, "multi-host").unwrap();
        assert_eq!(
            resolved.bound_by_instance["rclone-gdrive"]["config:remote"]["value"],
            Value::from("gdrive")
        );
        assert_eq!(
            resolved.bound_by_instance["rclone-b2"]["config:remote"]["value"],
            Value::from("b2")
        );
    }

    #[test]
    fn gap4_partitioned_attr_expr_routing_and_overlap_detection() {
        let mut vw = mk_atomic("vw");
        let mut r_vw = mk_offer();
        r_vw.ptype = Some("http:route".to_string());
        r_vw.key = Some("vault".to_string());
        r_vw.kind = Cardinality::Partitioned;
        r_vw.tags = vec!["zone:public".to_string()];
        r_vw.payload.insert("port".to_string(), Value::from(8222));
        vw.offers.insert("route:vault".to_string(), r_vw);

        let mut internal_svc = mk_atomic("internal");
        let mut r_int = mk_offer();
        r_int.ptype = Some("http:route".to_string());
        r_int.key = Some("admin".to_string());
        r_int.kind = Cardinality::Partitioned;
        r_int.tags = vec!["zone:mesh".to_string()];
        r_int.payload.insert("port".to_string(), Value::from(9000));
        internal_svc.offers.insert("route:admin".to_string(), r_int);

        let mut caddy = mk_atomic("caddy");
        let mut req_pub = mk_req();
        req_pub.kind = Cardinality::Partitioned;
        req_pub.mandatory = false;
        req_pub.selector = AttrExpr::atom("zone:public");
        caddy.requires.insert("http:route".to_string(), req_pub);

        let mut host = mk_atomic("web-host");
        host.kind = "superagent".to_string();
        host.realize = Some(RealizeSpec {
            system: "x86_64-linux".to_string(),
        });
        for name in ["vw", "internal", "caddy"] {
            host.contains.push(ChildRef {
                agent: name.to_string(),
                instance: None,
                offers: BTreeMap::new(),
            });
        }

        let mut fleet = FleetSpec::default();
        fleet.agents.insert(vw.id.clone(), vw);
        fleet.agents.insert(internal_svc.id.clone(), internal_svc);
        fleet.agents.insert(caddy.id.clone(), caddy.clone());
        fleet.agents.insert(host.id.clone(), host.clone());

        let report = verify_fleet(&fleet);
        assert!(
            report.is_valid(),
            "expected partitioned routing to pass: {report:?}"
        );
        let resolved = resolve_target_bindings(&fleet, "web-host").unwrap();
        let routes = resolved.bound_by_instance["caddy"]["http:route"]
            .as_object()
            .unwrap();
        assert!(routes.contains_key("vault"));
        assert!(!routes.contains_key("admin"));

        // Now add a second overlapping proxy with the same `zone:public` selector -> MUST FAIL!
        let mut nginx = caddy;
        nginx.id = "nginx".to_string();
        host.contains.push(ChildRef {
            agent: "nginx".to_string(),
            instance: None,
            offers: BTreeMap::new(),
        });
        fleet.agents.insert(nginx.id.clone(), nginx);
        fleet.agents.insert(host.id.clone(), host);

        let bad_report = verify_fleet(&fleet);
        let hr = bad_report.superagents.get("web-host").unwrap();
        assert!(!hr.is_valid());
        assert!(hr.binding_errors.iter().any(|e| matches!(
            e,
            BindingError::OverlappingPartitionHandlers { ptype, handler_count: 2, .. } if ptype == "http:route"
        )));
    }
}
