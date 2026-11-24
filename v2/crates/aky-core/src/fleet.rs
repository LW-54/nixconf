//! Pure Model-A Fractal Uniform Agency (`ADR-0002` + `ADR-0003` + `ADR-0008`):
//!
//! - **ONE universal `AgentManifest`** covers Atomic Agents, Nested Dressed Superagents
//!   (`web-stack`), Standalone Portable Tools (`git`), Orthogonal Substrate Agents
//!   (`target-nixos-efi`, `storage-ephemeral`, `sub-home-hjem`), and Closed Root Hosts
//!   (`astrolabe`, `live-iso`). There is **no** separate `HostManifest` type.
//! - **Parameters ARE Promises**: configurable inputs are declared as standard `-b`
//!   requirements (`requires."config:*"`, optional with `default` or mandatory `Exclusive`),
//!   satisfied by enclosing Dressed Superagents via `internal_offers` or child-scoped `offers`.

use std::collections::{BTreeMap, BTreeSet};

use serde::{Deserialize, Serialize};
use serde_json::Value;

use crate::agency::{
    BoundaryError, Cardinality, ExteriorSurface, Polarity, Promise, SoftContract, Strength,
    validate_superagent_conformance,
};
use crate::attr_expr::AttrExpr;
use crate::authority::{AuthPolicy, Entity};
use crate::binding::{BindingError, validate_scope};
use crate::drt::{ConformanceCheck, OracleRequest};
use crate::state::{
    StateError, StateVolume, SubstrateCapabilities, needs_local_persistence, validate_volumes,
};

/// Promise offer (`+b`) declared in `[offers."<key>"]` or `[internal_offers."<key>"]`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct OfferSpec {
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

/// Promise requirement (`-b`) declared in `[requires."<key>"]` (also models typed parameters!).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct RequireSpec {
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
    /// Mount/directory path owned by this agent.
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
    /// Optional child-scoped `+b` offers (parameter-as-promise local binding without polluting siblings!).
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
///
/// Covers Atomic Agents, Standalone Tools, Substrate Agents, Nested Dressed Superagents,
/// and Closed Root Hosts uniformly.
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
    /// Interior-only `+b` promises offered inside this superagent's scope (budgets, config parameters, ambient capabilities).
    #[serde(default)]
    pub internal_offers: BTreeMap<String, OfferSpec>,
    /// Exterior `+b` promises exported across `Σ`.
    #[serde(default)]
    pub offers: BTreeMap<String, OfferSpec>,
    /// Exterior `-b` promises required across `Σ` (including typed parameters!).
    #[serde(default)]
    pub requires: BTreeMap<String, RequireSpec>,
    /// Resource budget envelope (`C4`).
    #[serde(default)]
    pub budgets: BudgetSpec,
    /// Agent-declared state volumes (`S2+`).
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
    pub policies: Vec<AuthPolicy>,
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
    /// Missing agent or profile references.
    pub missing_refs: Vec<String>,
    /// `B3` scoped binding errors inside this superagent's interior.
    pub binding_errors: Vec<BindingError>,
    /// `P-Explicit` interior conformance errors (`conforms_no_lying_offers` / `conforms_no_leaked_requirements`).
    pub boundary_errors: Vec<BoundaryError>,
    /// `S2+` open-trait & CALM state safety errors (evaluated on closed root targets).
    pub state_errors: Vec<StateError>,
    /// Paths requiring local persistence across the entire recursive subtree.
    pub persistent_paths: Vec<String>,
}

impl SuperagentReport {
    /// Returns `true` iff this superagent passed every check with zero errors.
    #[must_use]
    pub const fn is_valid(&self) -> bool {
        self.missing_refs.is_empty()
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
    /// Sorted list of state paths requiring local persistence.
    pub persistent_paths: Vec<String>,
    /// Per-leaf-instance resolved `bound` map (`instance_path -> req_key -> offer_payload`).
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

fn offer_to_promise(prefix: &str, key: &str, spec: &OfferSpec, stratum: u64) -> Promise {
    Promise {
        id: format!("{prefix}:+{key}"),
        ptype: key.to_string(),
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

fn require_to_promise(prefix: &str, key: &str, spec: &RequireSpec, stratum: u64) -> Promise {
    Promise {
        id: format!("{prefix}:-{key}"),
        ptype: key.to_string(),
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

/// Collects an agent's exterior promises (`Π_ext`) PLUS rolled-up subtree RAM demands.
fn exterior_promises(fleet: &FleetSpec, agent: &AgentManifest, prefix: &str) -> Vec<Promise> {
    let mut ps = Vec::new();
    let total_ram = subtree_ram_demands(fleet, agent, &mut BTreeSet::new());
    for (idx, (ram, prio)) in total_ram.into_iter().enumerate() {
        if ram > 0 {
            ps.push(Promise {
                id: format!("{prefix}:-ram:{idx}"),
                ptype: "ram".to_string(),
                key: "ram".to_string(),
                polarity: Polarity::Use,
                strength: Strength::Hard,
                cardinality: Cardinality::Budgeted,
                mandatory: true,
                amount: ram,
                priority: prio,
                stratum: 1,
                tags: Vec::new(),
                selector: AttrExpr::Any,
                soft_info: None,
            });
        }
    }
    for (k, o) in &agent.offers {
        ps.push(offer_to_promise(prefix, k, o, 1));
    }
    for (k, r) in &agent.requires {
        ps.push(require_to_promise(prefix, k, r, 1));
    }
    ps
}

fn subtree_ram_demands(
    fleet: &FleetSpec,
    agent: &AgentManifest,
    visited: &mut BTreeSet<String>,
) -> Vec<(u64, u64)> {
    if !visited.insert(agent.id.clone()) {
        return Vec::new();
    }
    let mut out = Vec::new();
    if agent.budgets.ram_mib > 0 {
        out.push((
            agent.budgets.ram_mib,
            u64::from(agent.budgets.tier != "critical"),
        ));
    }
    if agent.is_superagent() {
        let (children, _) = expand_children(fleet, agent);
        for ch in children {
            if let Some(child_agent) = fleet.agents.get(&ch.agent) {
                out.extend(subtree_ram_demands(fleet, child_agent, visited));
            }
        }
    }
    visited.remove(&agent.id);
    out
}

fn collect_subtree_state_and_traits(
    fleet: &FleetSpec,
    agent: &AgentManifest,
    visited: &mut BTreeSet<String>,
    traits_out: &mut BTreeSet<String>,
    volumes_out: &mut Vec<StateVolume>,
    persistent_out: &mut BTreeSet<String>,
) {
    if !visited.insert(agent.id.clone()) {
        return;
    }
    traits_out.extend(agent.contributes_traits.iter().cloned());
    for (vname, vspec) in &agent.state {
        if needs_local_persistence(&vspec.traits) {
            persistent_out.insert(vspec.path.clone());
        }
        volumes_out.push(StateVolume {
            id: format!("{}:{vname}", agent.id),
            owner: agent.id.clone(),
            traits: vspec.traits.clone(),
        });
    }
    if agent.is_superagent() {
        let (children, _) = expand_children(fleet, agent);
        for ch in children {
            if let Some(child_agent) = fleet.agents.get(&ch.agent) {
                collect_subtree_state_and_traits(
                    fleet,
                    child_agent,
                    visited,
                    traits_out,
                    volumes_out,
                    persistent_out,
                );
            }
        }
    }
    visited.remove(&agent.id);
}

struct CompiledSuperagent {
    direct_children: Vec<String>,
    missing_refs: Vec<String>,
    scope_promises: Vec<Promise>,
    exterior: ExteriorSurface,
    conformance_children: Vec<ExteriorSurface>,
    substrate: SubstrateCapabilities,
    volumes: Vec<StateVolume>,
    persistent_paths: Vec<String>,
}

fn build_inbound_offers(agent: &AgentManifest) -> Vec<Promise> {
    agent
        .requires
        .iter()
        .map(|(k, r)| Promise {
            id: format!("{}:inbound:+{k}", agent.id),
            ptype: k.clone(),
            key: k.clone(),
            polarity: Polarity::Offer,
            strength: r.strength,
            cardinality: r.kind,
            mandatory: true,
            amount: 0,
            priority: 0,
            stratum: 0,
            tags: Vec::new(),
            selector: AttrExpr::Any,
            soft_info: r.soft.clone(),
        })
        .collect()
}

fn build_exterior_surface(agent: &AgentManifest) -> ExteriorSurface {
    let mut ext_ps = Vec::new();
    for (k, o) in &agent.offers {
        ext_ps.push(offer_to_promise(&agent.id, k, o, 1));
    }
    for (k, r) in &agent.requires {
        ext_ps.push(require_to_promise(&agent.id, k, r, 1));
    }
    ExteriorSurface {
        agent_id: agent.id.clone(),
        promises: ext_ps,
        attributes: agent.attributes.clone(),
    }
}

fn compile_superagent(fleet: &FleetSpec, agent: &AgentManifest) -> CompiledSuperagent {
    let (children, missing_refs) = expand_children(fleet, agent);
    let direct_children: Vec<String> = children
        .iter()
        .map(|c| c.local_name().to_string())
        .collect();

    let ambient_ps: Vec<Promise> = agent
        .internal_offers
        .iter()
        .map(|(k, o)| offer_to_promise(&agent.id, k, o, 0))
        .collect();

    let mut scope_promises = ambient_ps.clone();
    scope_promises.extend(build_inbound_offers(agent));

    let mut conformance_children = vec![ExteriorSurface {
        agent_id: format!("{}-internal", agent.id),
        promises: ambient_ps,
        attributes: agent.attributes.clone(),
    }];

    for ch in &children {
        if let Some(child_agent) = fleet.agents.get(&ch.agent) {
            let local = ch.local_name();
            let mut child_ps = exterior_promises(fleet, child_agent, local);
            for (ok, ospec) in &ch.offers {
                let p = offer_to_promise(&format!("{local}:local"), ok, ospec, 0);
                scope_promises.push(p.clone());
                child_ps.push(p);
            }
            let effective_ps: Vec<Promise> = if agent.is_root_target() {
                child_ps
            } else {
                child_ps
                    .into_iter()
                    .filter(|p| p.cardinality != Cardinality::Budgeted)
                    .collect()
            };
            scope_promises.extend(effective_ps.iter().cloned());
            conformance_children.push(ExteriorSurface {
                agent_id: local.to_string(),
                promises: effective_ps,
                attributes: child_agent.attributes.clone(),
            });
        }
    }

    let mut combined_traits = BTreeSet::new();
    let mut volumes = Vec::new();
    let mut persistent_set = BTreeSet::new();
    collect_subtree_state_and_traits(
        fleet,
        agent,
        &mut BTreeSet::new(),
        &mut combined_traits,
        &mut volumes,
        &mut persistent_set,
    );

    let provides_durable_storage =
        combined_traits.contains("durable") && !combined_traits.contains("ephemeral");
    let backup_provider_count = u64::try_from(
        scope_promises
            .iter()
            .filter(|p| p.polarity == Polarity::Offer && p.ptype == "backup:provider")
            .count(),
    )
    .unwrap_or(0);

    CompiledSuperagent {
        direct_children,
        missing_refs,
        scope_promises,
        exterior: build_exterior_surface(agent),
        conformance_children,
        substrate: SubstrateCapabilities {
            provides_durable_storage,
            backup_provider_count,
        },
        volumes,
        persistent_paths: persistent_set.into_iter().collect(),
    }
}

/// Verifies every Dressed Superagent (both nested stacks and closed root targets) and standalone agent.
#[must_use]
pub fn verify_fleet(fleet: &FleetSpec) -> FleetReport {
    let mut superagents = BTreeMap::new();
    for (aid, agent) in &fleet.agents {
        if !agent.is_superagent() {
            continue;
        }
        let compiled = compile_superagent(fleet, agent);
        let binding_errors = validate_scope(&compiled.scope_promises);
        let boundary_errors =
            validate_superagent_conformance(&compiled.exterior, &compiled.conformance_children);
        let state_errors = if agent.is_root_target() {
            validate_volumes(&compiled.substrate, &compiled.volumes)
        } else {
            Vec::new()
        };

        superagents.insert(
            aid.clone(),
            SuperagentReport {
                agent_id: aid.clone(),
                system: agent.realize.as_ref().map(|r| r.system.clone()),
                direct_children: compiled.direct_children,
                missing_refs: compiled.missing_refs,
                binding_errors,
                boundary_errors,
                state_errors,
                persistent_paths: compiled.persistent_paths,
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

    // Scope offers visible inside this superagent = inbound parent offers (STRICTLY declared in `requires`!)
    // + superagent's `internal_offers` + direct children's exterior `offers` (NON-PIERCING!).
    let mut scope_offers: BTreeMap<String, Value> = inbound_bound.clone();
    for (k, o) in &agent.internal_offers {
        scope_offers.insert(k.clone(), offer_to_json(o));
    }
    for ch in &children {
        if let Some(child_agent) = fleet.agents.get(&ch.agent) {
            for (k, o) in &child_agent.offers {
                scope_offers.insert(k.clone(), offer_to_json(o));
            }
        }
    }

    for ch in children {
        if let Some(child_agent) = fleet.agents.get(&ch.agent) {
            let child_path = if prefix.is_empty() {
                ch.local_name().to_string()
            } else {
                format!("{prefix}/{}", ch.local_name())
            };
            // NON-PIERCING projection: child receives ONLY offers matching its declared `requires`
            // (with child-scoped `ch.offers` overriding scope offers, or `rspec.default` if optional).
            let mut child_bound = BTreeMap::new();
            for (rkey, rspec) in &child_agent.requires {
                if let Some(local_offer) = ch.offers.get(rkey) {
                    child_bound.insert(rkey.clone(), offer_to_json(local_offer));
                } else if let Some(val) = scope_offers.get(rkey) {
                    child_bound.insert(rkey.clone(), val.clone());
                } else if let Some(def) = &rspec.default {
                    child_bound.insert(rkey.clone(), def.clone());
                }
            }
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

/// Deterministically resolves recursive non-piercing `bound` maps & `persistent_paths`
/// for any root Dressed Superagent, mirroring `v2/lib/realize.nix` bit-for-bit!
#[must_use]
pub fn resolve_target_bindings(fleet: &FleetSpec, root_id: &str) -> Option<ResolvedTargetBindings> {
    let root = fleet.agents.get(root_id)?;
    let realize = root.realize.as_ref()?;
    let compiled = compile_superagent(fleet, root);

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
        persistent_paths: compiled.persistent_paths,
        bound_by_instance,
    })
}

/// Projects any Dressed Superagent (nested stack or root host) + policies into an [`OracleRequest`]
/// for live AWS Cedar DRT against the 35-theorem Lean 4 `aky-oracle`!
#[must_use]
pub fn superagent_to_oracle_request(fleet: &FleetSpec, agent_id: &str) -> Option<OracleRequest> {
    let agent = fleet.agents.get(agent_id)?;
    if !agent.is_superagent() {
        return None;
    }
    let compiled = compile_superagent(fleet, agent);
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
        compiled.volumes
    } else {
        Vec::new()
    };

    Some(OracleRequest {
        conformance: ConformanceCheck {
            exterior: compiled.exterior,
            children: compiled.conformance_children,
        },
        promises: compiled.scope_promises,
        stratum_rules: Vec::new(),
        policies: fleet.policy_catalog.policies.clone(),
        auth_queries,
        delegated_queries: Vec::new(),
        blast_target,
        blast_action: "read-secret".to_string(),
        all_resources: fleet.policy_catalog.resources.clone(),
        substrate: compiled.substrate,
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
        // Lies about offering `http:fake` AND leaks `secrets:runtime`!
        bad_super.offers.insert("http:fake".to_string(), mk_offer());

        let mut fleet = FleetSpec::default();
        fleet.agents.insert(child.id.clone(), child);
        fleet.agents.insert(bad_super.id.clone(), bad_super);

        let report = verify_fleet(&fleet);
        let sr = report.superagents.get("bad-stack").unwrap();
        assert!(!sr.is_valid());
        assert!(sr.boundary_errors.iter().any(
            |e| matches!(e, BoundaryError::UnbackedOffer { ptype, .. } if ptype == "http:fake")
        ));
        assert!(sr
            .boundary_errors
            .iter()
            .any(|e| matches!(e, BoundaryError::LeakedRequirement { ptype, .. } if ptype == "secrets:runtime")));
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
}
