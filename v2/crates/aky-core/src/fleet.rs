//! Zero-Sugar Pure-Primitive Model-A Fractal Uniform Agency (`ADR-0002` + `ADR-0003`):
//!
//! - **Zero syntactic sugar, zero domain strings, zero special types.**
//! - **ONE universal 7-field `AgentManifest`** (`id`, `description`, `attributes`, `profiles`,
//!   `contains`, `internal_promises`, `promises`) covers every entity uniformly.
//! - **ONE raw `PromiseSpec`** covers every offer, requirement, parameter, route, resource
//!   budget, storage capability, and state declaration uniformly.
//! - **Declarative `PromiseInvariant` rules** in `PolicyCatalog` enforce domain laws (such as
//!   CALM monotonicity) purely as data — zero domain logic in the kernel.

use std::collections::{BTreeMap, BTreeSet};

use serde::{Deserialize, Serialize};
use serde_json::Value;

use crate::agency::{
    Agent, BoundaryError, Cardinality, ExteriorSurface, Polarity, Promise, SoftContract, Strength,
    can_compose_in_scope, sibling_operational_view, total_budget_supply,
    validate_superagent_conformance,
};
use crate::attr_expr::AttrExpr;
use crate::authority::{AuthPolicy, Entity};
use crate::binding::{
    BindingError, check_agent_tree, inbound_from_exterior, outbound_from_exterior, validate_scope,
};
use crate::drt::{AuthQuery, OracleRequest};
use crate::invariants::{InvariantError, PromiseInvariant, validate_invariants};

/// Raw zero-sugar promise declaration (`[[promises]]` or `[[internal_promises]]`).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct PromiseSpec {
    /// Promise contract type (`τ`).
    pub ptype: String,
    /// Commutative merge / unique key.
    pub key: String,
    /// Offer (`+b`) or Use (`-b`).
    pub polarity: Polarity,
    /// Static `Hard` or conditional `Soft` (defaults to `Hard`).
    #[serde(default = "default_hard")]
    pub strength: Strength,
    /// `B3` binding cardinality.
    pub cardinality: Cardinality,
    /// Whether an unbound `Hard` promise fails verification (defaults to `true`).
    #[serde(default = "default_true")]
    pub mandatory: bool,
    /// Quantitative resource amount for `Budgeted` promises.
    #[serde(default)]
    pub amount: u64,
    /// Priority tier (`0` = critical survival tier; defaults to `1`).
    #[serde(default = "default_priority")]
    pub priority: u64,
    /// Acyclic stratification rank.
    #[serde(default)]
    pub stratum: u64,
    /// Expressed tags for `Partitioned` routing and declarative `PromiseInvariant` rules.
    #[serde(default)]
    pub tags: Vec<String>,
    /// `AttrExpr` selector for `Partitioned` consumers.
    #[serde(default = "default_any")]
    pub selector: AttrExpr,
    /// Mandatory metadata when `strength == Strength::Soft`.
    #[serde(default)]
    pub soft: Option<SoftContract>,
    /// Optional fallback payload when a `-b` Use is optional and unbound.
    #[serde(default)]
    pub default: Option<Value>,
    /// Arbitrary typed data payload carried across `Σ` by `+b` Offers.
    #[serde(default)]
    pub payload: BTreeMap<String, Value>,
}

/// Child reference inside a Dressed Superagent's `contains = [ ... ]`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ChildRef {
    /// Referenced agent ID under `agents/`.
    pub agent: String,
    /// Optional local instance alias for multi-instance instantiation.
    #[serde(default)]
    pub instance: Option<String>,
    /// Optional child-scoped `+b` promises wrapped in a private 1-child Dressed Superagent.
    #[serde(default)]
    pub promises: Vec<PromiseSpec>,
}

impl ChildRef {
    /// Returns the local unique node name (`instance` if set, otherwise `agent`).
    #[must_use]
    pub fn local_name(&self) -> &str {
        self.instance.as_deref().unwrap_or(&self.agent)
    }
}

/// Universal 7-field Zero-Sugar Agent manifest parsed from `agents/<name>/agent.toml`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct AgentManifest {
    /// Unique agent identifier.
    pub id: String,
    /// Human-readable description.
    #[serde(default)]
    pub description: String,
    /// Factual entity attributes (`EXPRESSES` tags).
    #[serde(default)]
    pub attributes: Vec<String>,
    /// Transparent profiles (`P-Dual`) flattened into this superagent's interior.
    #[serde(default)]
    pub profiles: Vec<String>,
    /// Direct child agents contained inside this Dressed Superagent (`CONTAINS`).
    #[serde(default)]
    pub contains: Vec<ChildRef>,
    /// Interior-only promises scoped strictly inside this superagent.
    #[serde(default)]
    pub internal_promises: Vec<PromiseSpec>,
    /// Exterior promises (`Π_ext`) exported or required across `Σ`.
    #[serde(default)]
    pub promises: Vec<PromiseSpec>,
}

impl AgentManifest {
    /// Returns `true` iff this agent is a Dressed Superagent (`contains` or `profiles` non-empty).
    #[must_use]
    pub const fn is_superagent(&self) -> bool {
        !self.contains.is_empty() || !self.profiles.is_empty()
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

/// Declarative policies, entities, and promise invariants parsed from `policies/*.toml`.
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct PolicyCatalog {
    /// Known principals.
    #[serde(default)]
    pub principals: Vec<Entity>,
    /// Governed resources.
    #[serde(default)]
    pub resources: Vec<Entity>,
    /// Cedar `Permit` / `Forbid` policies.
    #[serde(default)]
    pub policies: Vec<AuthPolicy>,
    /// Declarative `AttrExpr` promise invariants (domain laws expressed purely as data!).
    #[serde(default)]
    pub invariants: Vec<PromiseInvariant>,
}

/// Complete in-memory specification (100% pure data, zero `std::fs`, zero domain strings!).
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct FleetSpec {
    /// Universal catalog of ALL agents.
    pub agents: BTreeMap<String, AgentManifest>,
    /// Transparent profiles (`P-Dual`).
    pub profiles: BTreeMap<String, ProfileManifest>,
    /// Authorization policies and declarative promise invariants.
    pub policy_catalog: PolicyCatalog,
}

/// Recursive verification report for a Dressed Superagent.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct SuperagentReport {
    /// Agent identifier.
    pub agent_id: String,
    /// Direct children inside this superagent (after `P-Dual` profile flattening).
    pub direct_children: Vec<String>,
    /// Missing agent/profile references or containment cycles.
    pub missing_refs: Vec<String>,
    /// `B3` scoped binding errors inside this superagent's interior (and local child wrappers).
    pub binding_errors: Vec<BindingError>,
    /// `P-Explicit` interior conformance errors.
    pub boundary_errors: Vec<BoundaryError>,
    /// Declarative `PromiseInvariant` violations on this superagent's exterior & direct children.
    pub invariant_errors: Vec<InvariantError>,
    /// Recursive `check_agent_tree` verdict mirroring Lean 4 `Aky.Spec.checkAgentTree` 1:1.
    pub tree_valid: bool,
}

impl SuperagentReport {
    /// Returns `true` iff this superagent and its entire recursive tree passed every check.
    #[must_use]
    pub const fn is_valid(&self) -> bool {
        self.tree_valid
            && self.missing_refs.is_empty()
            && self.binding_errors.is_empty()
            && self.boundary_errors.is_empty()
            && self.invariant_errors.is_empty()
    }
}

/// Fleet-wide verification report returned by [`verify_fleet`].
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct FleetReport {
    /// Reports for every Dressed Superagent.
    pub superagents: BTreeMap<String, SuperagentReport>,
    /// Atomic agents whose exterior promises close inside an empty ambient scope (zero external deps!).
    pub self_contained_agents: Vec<String>,
    /// Declarative invariant violations on standalone atomic agents outside any superagent.
    pub atomic_invariant_errors: Vec<InvariantError>,
}

impl FleetReport {
    /// Returns `true` iff every superagent and atomic invariant passed cleanly.
    #[must_use]
    pub fn is_valid(&self) -> bool {
        self.superagents.values().all(SuperagentReport::is_valid)
            && self.atomic_invariant_errors.is_empty()
    }
}

/// Deterministic `S1` binding resolution output for any Dressed Superagent,
/// mirroring `v2/lib/realize.nix` bit-for-bit (100% platform-agnostic!).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct ResolvedTargetBindings {
    /// Root superagent identifier.
    pub root_id: String,
    /// Sorted list of materialized leaf atomic agent instance paths.
    pub leaf_instances: Vec<String>,
    /// Per-leaf-instance resolved `bound` map (`instance_path -> use_key -> resolved_payload`).
    pub bound_by_instance: BTreeMap<String, BTreeMap<String, Value>>,
}

const fn default_hard() -> Strength {
    Strength::Hard
}

const fn default_true() -> bool {
    true
}

const fn default_priority() -> u64 {
    1
}

const fn default_any() -> AttrExpr {
    AttrExpr::Any
}

fn spec_to_promise(prefix: &str, idx: usize, spec: &PromiseSpec) -> Promise {
    let dir = match spec.polarity {
        Polarity::Offer => "+",
        Polarity::Use => "-",
    };
    Promise {
        id: format!("{prefix}:{dir}{}:{}:{idx}", spec.ptype, spec.key),
        ptype: spec.ptype.clone(),
        key: spec.key.clone(),
        polarity: spec.polarity,
        strength: spec.strength,
        cardinality: spec.cardinality,
        mandatory: spec.mandatory,
        amount: spec.amount,
        priority: spec.priority,
        stratum: spec.stratum,
        tags: spec.tags.clone(),
        selector: spec.selector.clone(),
        soft_info: spec.soft.clone(),
    }
}

fn payload_to_json(payload: &BTreeMap<String, Value>) -> Value {
    let mut map = serde_json::Map::new();
    for (k, v) in payload {
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
                        promises: Vec::new(),
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
    let promises = agent
        .promises
        .iter()
        .enumerate()
        .map(|(idx, p)| spec_to_promise(local_id, idx, p))
        .collect();
    ExteriorSurface {
        agent_id: local_id.to_string(),
        promises,
        attributes: agent.attributes.clone(),
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

fn wrap_with_local_promises(
    child_agent: &AgentManifest,
    local_name: &str,
    local_specs: &[PromiseSpec],
    child_tree: Agent,
) -> Agent {
    let local_ps: Vec<Promise> = local_specs
        .iter()
        .enumerate()
        .map(|(idx, p)| spec_to_promise(&format!("{local_name}:local"), idx, p))
        .collect();
    let mut wrapper_ext = build_agent_exterior(child_agent, local_name);
    wrapper_ext
        .promises
        .retain(|p| p.polarity != Polarity::Use || !local_offers_satisfy(&local_ps, p));
    let local_node = Agent::Atomic {
        ext: ExteriorSurface {
            agent_id: format!("{local_name}:local"),
            promises: local_ps,
            attributes: Vec::new(),
        },
        interior_hash: "local-promises".to_string(),
    };
    Agent::Superagent {
        ext: wrapper_ext,
        children: vec![local_node, child_tree],
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
    if !agent.internal_promises.is_empty() {
        let ambient_ps: Vec<Promise> = agent
            .internal_promises
            .iter()
            .enumerate()
            .map(|(idx, p)| spec_to_promise(&format!("{local_id}:internal"), idx, p))
            .collect();
        child_agents.push(Agent::Atomic {
            ext: ExteriorSurface {
                agent_id: format!("{local_id}:internal"),
                promises: ambient_ps,
                attributes: Vec::new(),
            },
            interior_hash: "internal".to_string(),
        });
    }

    for ch in &children_refs {
        if let Some(child_agent) = fleet.agents.get(&ch.agent) {
            let local = ch.local_name();
            let child_tree = build_agent_tree_rec(fleet, child_agent, local, visited, missing_refs);
            if ch.promises.is_empty() {
                child_agents.push(child_tree);
            } else {
                child_agents.push(wrap_with_local_promises(
                    child_agent,
                    local,
                    &ch.promises,
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

fn scope_promises_for(ext: &ExteriorSurface, children: &[Agent]) -> Vec<Promise> {
    let int_ps: Vec<Promise> = sibling_operational_view(children)
        .into_iter()
        .flat_map(|s| s.promises.iter().cloned())
        .collect();
    let mut scope_ps = inbound_from_exterior(ext);
    scope_ps.extend(outbound_from_exterior(ext, &int_ps));
    scope_ps.extend(int_ps);
    scope_ps
}

fn collect_local_wrapper_errors(
    children: &[Agent],
    invs: &[PromiseInvariant],
    binding_errors: &mut Vec<BindingError>,
    boundary_errors: &mut Vec<BoundaryError>,
    invariant_errors: &mut Vec<InvariantError>,
) {
    for ch in children {
        if let Agent::Superagent {
            ext,
            children: w_children,
        } = ch
        {
            let is_local_wrapper = w_children.iter().any(|wc| {
                matches!(wc, Agent::Atomic { interior_hash, .. } if interior_hash == "local-promises")
            });
            if is_local_wrapper {
                let w_scope = scope_promises_for(ext, w_children);
                binding_errors.extend(validate_scope(&w_scope));
                boundary_errors.extend(validate_superagent_conformance(ext, w_children));
                invariant_errors.extend(validate_invariants(invs, &ext.promises));
            }
        }
    }
}

/// Verifies every Dressed Superagent, recursive tree, declarative invariant, and
/// self-contained atomic agent — strictly usage-agnostic and non-piercing!
#[must_use]
pub fn verify_fleet(fleet: &FleetSpec) -> FleetReport {
    let invs = &fleet.policy_catalog.invariants;
    let empty_ambient = ExteriorSurface {
        agent_id: "empty-ambient".to_string(),
        promises: Vec::new(),
        attributes: Vec::new(),
    };
    let mut superagents = BTreeMap::new();
    let mut self_contained_agents = Vec::new();
    let mut atomic_invariant_errors = Vec::new();

    for (aid, agent) in &fleet.agents {
        if !agent.is_superagent() {
            let ext = build_agent_exterior(agent, aid);
            atomic_invariant_errors.extend(validate_invariants(invs, &ext.promises));
            if can_compose_in_scope(&empty_ambient, &ext) {
                self_contained_agents.push(aid.clone());
            }
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
        let tree_valid = check_agent_tree(invs, &tree);

        let (binding_errors, boundary_errors, invariant_errors) =
            if let Agent::Superagent { ext, children } = &tree {
                let scope_ps = scope_promises_for(ext, children);
                let mut bind_errs = validate_scope(&scope_ps);
                let mut bound_errs = validate_superagent_conformance(ext, children);
                let mut inv_errs = validate_invariants(invs, &ext.promises);
                for surf in sibling_operational_view(children) {
                    inv_errs.extend(validate_invariants(invs, &surf.promises));
                }
                collect_local_wrapper_errors(
                    children,
                    invs,
                    &mut bind_errs,
                    &mut bound_errs,
                    &mut inv_errs,
                );
                (bind_errs, bound_errs, inv_errs)
            } else {
                (Vec::new(), Vec::new(), Vec::new())
            };

        superagents.insert(
            aid.clone(),
            SuperagentReport {
                agent_id: aid.clone(),
                direct_children,
                missing_refs,
                binding_errors,
                boundary_errors,
                invariant_errors,
                tree_valid,
            },
        );
    }

    FleetReport {
        superagents,
        self_contained_agents,
        atomic_invariant_errors,
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

fn specs_to_scope_offers(specs: &[PromiseSpec]) -> Vec<ScopeOffer> {
    specs
        .iter()
        .filter(|p| p.polarity == Polarity::Offer)
        .map(|o| ScopeOffer {
            ptype: o.ptype.clone(),
            key: o.key.clone(),
            kind: o.cardinality,
            tags: o.tags.clone(),
            value: payload_to_json(&o.payload),
        })
        .collect()
}

fn collect_scope_offers(
    fleet: &FleetSpec,
    agent: &AgentManifest,
    children: &[ChildRef],
    inbound_bound: &BTreeMap<String, Value>,
) -> Vec<ScopeOffer> {
    let mut offers = Vec::new();
    for p in &agent.promises {
        if p.polarity == Polarity::Use
            && let Some(val) = inbound_bound.get(&p.key)
        {
            offers.push(ScopeOffer {
                ptype: p.ptype.clone(),
                key: p.key.clone(),
                kind: p.cardinality,
                tags: Vec::new(),
                value: val.clone(),
            });
        }
    }
    offers.extend(specs_to_scope_offers(&agent.internal_promises));
    for ch in children {
        if let Some(child_agent) = fleet.agents.get(&ch.agent) {
            offers.extend(specs_to_scope_offers(&child_agent.promises));
        }
    }
    offers
}

fn bind_child_uses(
    child_agent: &AgentManifest,
    scope_offers: &[ScopeOffer],
    local_offers: &[ScopeOffer],
) -> BTreeMap<String, Value> {
    let mut bound = BTreeMap::new();
    for r in &child_agent.promises {
        if r.polarity != Polarity::Use {
            continue;
        }
        match r.cardinality {
            Cardinality::Partitioned => {
                let mut matched = serde_json::Map::new();
                for o in scope_offers.iter().chain(local_offers.iter()) {
                    if o.ptype == r.ptype
                        && o.kind == Cardinality::Partitioned
                        && r.selector.eval(&o.tags)
                    {
                        matched.insert(o.key.clone(), o.value.clone());
                    }
                }
                bound.insert(r.key.clone(), Value::Object(matched));
            }
            Cardinality::Broadcast => {
                let mut matched = serde_json::Map::new();
                for o in scope_offers.iter().chain(local_offers.iter()) {
                    if o.ptype == r.ptype {
                        matched.insert(o.key.clone(), o.value.clone());
                    }
                }
                bound.insert(r.key.clone(), Value::Object(matched));
            }
            Cardinality::Exclusive | Cardinality::Budgeted => {
                if let Some(o) = local_offers
                    .iter()
                    .rev()
                    .find(|o| o.ptype == r.ptype && o.key == r.key)
                    .or_else(|| {
                        scope_offers
                            .iter()
                            .rev()
                            .find(|o| o.ptype == r.ptype && o.key == r.key)
                    })
                {
                    bound.insert(r.key.clone(), o.value.clone());
                } else if let Some(def) = &r.default {
                    bound.insert(r.key.clone(), def.clone());
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
            let local_offers = specs_to_scope_offers(&ch.promises);
            let child_bound = bind_child_uses(child_agent, &scope_offers, &local_offers);
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

/// Deterministically resolves recursive non-piercing `bound` maps for any Dressed Superagent,
/// mirroring `v2/lib/realize.nix` bit-for-bit!
#[must_use]
pub fn resolve_target_bindings(fleet: &FleetSpec, root_id: &str) -> Option<ResolvedTargetBindings> {
    let root = fleet.agents.get(root_id)?;
    if !root.is_superagent() {
        return None;
    }

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
        leaf_instances,
        bound_by_instance,
    })
}

/// Projects any Dressed Superagent's FULL RECURSIVE [`Agent`] tree + declarative invariants +
/// policies into an [`OracleRequest`] for live AWS Cedar DRT against Lean 4 `aky-oracle`!
#[must_use]
pub fn superagent_to_oracle_request(fleet: &FleetSpec, agent_id: &str) -> Option<OracleRequest> {
    let agent = fleet.agents.get(agent_id)?;
    if !agent.is_superagent() {
        return None;
    }
    let (agent_tree, _) = build_agent_tree(fleet, agent_id)?;
    let scope_promises = if let Agent::Superagent { ext, children } = &agent_tree {
        scope_promises_for(ext, children)
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

    let actions: BTreeSet<String> = fleet
        .policy_catalog
        .policies
        .iter()
        .map(|p| p.action.clone())
        .collect();
    let blast_action = actions
        .iter()
        .next()
        .cloned()
        .unwrap_or_else(|| "none".to_string());

    let mut auth_queries = Vec::new();
    for action in &actions {
        for p in &fleet.policy_catalog.principals {
            for r in &fleet.policy_catalog.resources {
                auth_queries.push(AuthQuery {
                    principal: p.clone(),
                    action: action.clone(),
                    resource: r.clone(),
                });
            }
        }
    }

    Some(OracleRequest {
        agent_tree,
        invariants: fleet.policy_catalog.invariants.clone(),
        promises: scope_promises,
        stratum_rules: Vec::new(),
        policies: fleet.policy_catalog.policies.clone(),
        auth_queries,
        delegated_queries: Vec::new(),
        blast_target,
        blast_action,
        all_resources: fleet.policy_catalog.resources.clone(),
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn mk_agent(id: &str) -> AgentManifest {
        AgentManifest {
            id: id.to_string(),
            description: String::new(),
            attributes: Vec::new(),
            profiles: Vec::new(),
            contains: Vec::new(),
            internal_promises: Vec::new(),
            promises: Vec::new(),
        }
    }

    fn mk_promise(
        ptype: &str,
        key: &str,
        polarity: Polarity,
        cardinality: Cardinality,
    ) -> PromiseSpec {
        PromiseSpec {
            ptype: ptype.to_string(),
            key: key.to_string(),
            polarity,
            strength: Strength::Hard,
            cardinality,
            mandatory: true,
            amount: 0,
            priority: 1,
            stratum: 1,
            tags: Vec::new(),
            selector: AttrExpr::Any,
            soft: None,
            default: None,
            payload: BTreeMap::new(),
        }
    }

    #[test]
    fn lying_offer_and_leaked_use_and_dropped_mandatory_partitioned_offer_caught() {
        let mut child = mk_agent("child-svc");
        child.promises.push(mk_promise(
            "dep:x",
            "dep:x",
            Polarity::Use,
            Cardinality::Exclusive,
        ));
        let mut part_offer = mk_promise(
            "chan:out",
            "item-1",
            Polarity::Offer,
            Cardinality::Partitioned,
        );
        part_offer.tags = vec!["tag:a".to_string()];
        child.promises.push(part_offer);

        let mut bad_super = mk_agent("bad-stack");
        bad_super.contains.push(ChildRef {
            agent: "child-svc".to_string(),
            instance: None,
            promises: Vec::new(),
        });
        bad_super.promises.push(mk_promise(
            "fake:cap",
            "fake:cap",
            Polarity::Offer,
            Cardinality::Exclusive,
        ));

        let mut fleet = FleetSpec::default();
        fleet.agents.insert(child.id.clone(), child);
        fleet.agents.insert(bad_super.id.clone(), bad_super);

        let report = verify_fleet(&fleet);
        let sr = report.superagents.get("bad-stack").unwrap();
        assert!(!sr.is_valid());
        assert!(!sr.tree_valid);
        assert!(sr.boundary_errors.iter().any(
            |e| matches!(e, BoundaryError::UnbackedOffer { ptype, .. } if ptype == "fake:cap")
        ));
        assert!(sr.boundary_errors.iter().any(
            |e| matches!(e, BoundaryError::LeakedRequirement { ptype, .. } if ptype == "dep:x")
        ));
        assert!(sr.boundary_errors.iter().any(
            |e| matches!(e, BoundaryError::DroppedMandatoryOffer { ptype, key, .. } if ptype == "chan:out" && key == "item-1")
        ));
    }

    #[test]
    fn underreported_generic_budget_and_declarative_invariant_caught() {
        let mut leaf = mk_agent("worker");
        let mut bud = mk_promise("res:q", "res:q", Polarity::Use, Cardinality::Budgeted);
        bud.amount = 256;
        bud.priority = 0;
        leaf.promises.push(bud);
        let mut bad_tagged = mk_promise("chan:x", "k0", Polarity::Offer, Cardinality::Partitioned);
        bad_tagged.mandatory = false;
        bad_tagged.tags = vec!["bad-a".to_string()];
        leaf.promises.push(bad_tagged);

        let mut stack = mk_agent("stack");
        let mut small_bud = mk_promise("res:q", "res:q", Polarity::Use, Cardinality::Budgeted);
        small_bud.amount = 128;
        small_bud.priority = 1;
        stack.promises.push(small_bud);
        stack.contains.push(ChildRef {
            agent: "worker".to_string(),
            instance: None,
            promises: Vec::new(),
        });

        let mut fleet = FleetSpec::default();
        fleet.policy_catalog.invariants.push(PromiseInvariant {
            id: "forbid-bad-a-without-guard".to_string(),
            ptype: "chan:x".to_string(),
            forbid_tags: AttrExpr::diff(AttrExpr::atom("bad-a"), AttrExpr::atom("guard")),
        });
        fleet.agents.insert(leaf.id.clone(), leaf);
        fleet.agents.insert(stack.id.clone(), stack);

        let report = verify_fleet(&fleet);
        let sr = report.superagents.get("stack").unwrap();
        assert!(!sr.is_valid());
        assert!(sr.boundary_errors.iter().any(
            |e| matches!(e, BoundaryError::UnderreportedBudget { ptype, .. } if ptype == "res:q")
        ));
        assert!(sr.boundary_errors.iter().any(|e| matches!(
            e,
            BoundaryError::UnderreportedCriticalBudget { ptype, .. } if ptype == "res:q"
        )));
        assert!(
            sr.invariant_errors
                .iter()
                .any(|e| e.invariant_id == "forbid-bad-a-without-guard")
        );
    }

    #[test]
    fn multi_instance_local_promises_and_mandatory_broadcast_work_without_collision() {
        let mut worker = mk_agent("worker");
        worker.promises.push(mk_promise(
            "cfg:id",
            "cfg:id",
            Polarity::Use,
            Cardinality::Exclusive,
        ));
        worker.promises.push(mk_promise(
            "cap:sink",
            "cap:sink",
            Polarity::Offer,
            Cardinality::Broadcast,
        ));

        let mut consumer = mk_agent("consumer");
        consumer.promises.push(mk_promise(
            "cap:sink",
            "cap:sink",
            Polarity::Use,
            Cardinality::Broadcast,
        ));

        let mut o1 = mk_promise("cfg:id", "cfg:id", Polarity::Offer, Cardinality::Exclusive);
        o1.payload.insert("v".to_string(), Value::from("one"));
        let mut o2 = mk_promise("cfg:id", "cfg:id", Polarity::Offer, Cardinality::Exclusive);
        o2.payload.insert("v".to_string(), Value::from("two"));

        let mut root = mk_agent("root");
        root.contains.push(ChildRef {
            agent: "worker".to_string(),
            instance: Some("w1".to_string()),
            promises: vec![o1],
        });
        root.contains.push(ChildRef {
            agent: "worker".to_string(),
            instance: Some("w2".to_string()),
            promises: vec![o2],
        });
        root.contains.push(ChildRef {
            agent: "consumer".to_string(),
            instance: None,
            promises: Vec::new(),
        });

        let mut fleet = FleetSpec::default();
        fleet.agents.insert(worker.id.clone(), worker);
        fleet.agents.insert(consumer.id.clone(), consumer);
        fleet.agents.insert(root.id.clone(), root);

        let report = verify_fleet(&fleet);
        assert!(report.is_valid(), "unexpected errors: {report:?}");
        let resolved = resolve_target_bindings(&fleet, "root").unwrap();
        assert_eq!(
            resolved.bound_by_instance["w1"]["cfg:id"]["v"],
            Value::from("one")
        );
        assert_eq!(
            resolved.bound_by_instance["w2"]["cfg:id"]["v"],
            Value::from("two")
        );
    }
}
