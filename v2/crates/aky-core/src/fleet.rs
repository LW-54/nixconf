//! High-level Antikythera (`A2` TOML) fleet boundary model, `P-Dual` profile flattening,
//! open arbitrary-axis substrate evaluation, and `S1` deterministic binding resolution.

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

/// Promise offer declared in an `agent.toml` `[offers."<key>"]` table.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct OfferSpec {
    /// Binding cardinality (defaults to `Exclusive`).
    #[serde(default = "default_exclusive")]
    pub kind: Cardinality,
    /// Enforcement strength (defaults to `Hard`).
    #[serde(default = "default_hard")]
    pub strength: Strength,
    /// Optional tags for `Partitioned` matching.
    #[serde(default)]
    pub tags: Vec<String>,
    /// Optional soft-promise contract metadata (mandatory when `strength = "soft"`).
    #[serde(default)]
    pub soft: Option<SoftContract>,
    /// Arbitrary typed offer payload fields passed into bound consumers (`bound.<key>.*`).
    #[serde(flatten)]
    pub payload: BTreeMap<String, Value>,
}

/// Promise requirement declared in an `agent.toml` `[requires."<key>"]` table.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
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
}

/// Resource budget envelope declared in `[budgets]`.
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
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
pub struct StateSpec {
    /// Mount/directory path owned by this agent.
    pub path: String,
    /// Open composable state traits (e.g., `["survives-reboot", "backup-required", "single-auth-writer"]`).
    #[serde(default)]
    pub traits: Vec<String>,
}

/// Exterior boundary manifest parsed from `agents/<name>/agent.toml`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct AgentManifest {
    /// Unique agent identifier.
    pub id: String,
    /// Role hint (`"atomic"`, `"standalone"`, `"substrate"`, etc.).
    #[serde(default = "default_atomic")]
    pub kind: String,
    /// Human-readable description (enforces `QA-04` self-documentation).
    #[serde(default)]
    pub description: String,
    /// Optional substrate traits contributed by this agent (open arbitrary-axis composition!).
    #[serde(default)]
    pub contributes_traits: Vec<String>,
    /// Positive promises (`+b`) exported by this agent.
    #[serde(default)]
    pub offers: BTreeMap<String, OfferSpec>,
    /// Negative promises (`-b`) required by this agent.
    #[serde(default)]
    pub requires: BTreeMap<String, RequireSpec>,
    /// Resource budget envelope (`C4`).
    #[serde(default)]
    pub budgets: BudgetSpec,
    /// Agent-declared state volumes (`S2+`).
    #[serde(default)]
    pub state: BTreeMap<String, StateSpec>,
    /// Optional default parameters for multi-instance instantiation (`QA-02`).
    #[serde(default)]
    pub params: BTreeMap<String, Value>,
}

/// Transparent Profile (`P-Dual`, `profiles/<name>.toml`): flat sibling set with zero ceremony.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct ProfileManifest {
    /// Unique profile identifier.
    pub id: String,
    /// Optional description.
    #[serde(default)]
    pub description: String,
    /// Nested transparent profiles to flatten recursively.
    #[serde(default)]
    pub profiles: Vec<String>,
    /// Agents included by this profile.
    #[serde(default)]
    pub agents: Vec<String>,
}

/// Named multi-instance instantiation (`[instances.<name>]` inside `hosts/<host>.toml`).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct InstanceSpec {
    /// Agent template identifier under `agents/`.
    pub agent: String,
    /// Instance-specific parameter overrides.
    #[serde(default)]
    pub params: BTreeMap<String, Value>,
}

/// Host Superagent boundary manifest parsed from `hosts/<name>.toml`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct HostManifest {
    /// Unique hostname / agent identifier.
    pub id: String,
    /// Target architecture (`"x86_64-linux"` or `"aarch64-linux"`).
    pub system: String,
    /// Total RAM supply in MiB (`Budgeted` supply).
    pub ram_mib: u64,
    /// Number of bound off-host backup providers available to this host.
    #[serde(default)]
    pub backup_providers: u64,
    /// Factual Cedar `L3+` host attributes (e.g., `["role:server", "tier:prod"]`).
    #[serde(default)]
    pub attributes: Vec<String>,
    /// Direct host-level substrate traits (combined with `contributes_traits` of active agents).
    #[serde(default)]
    pub substrate_traits: Vec<String>,
    /// Direct host-level ambient offers (e.g., `["secrets:runtime"]`).
    #[serde(default)]
    pub substrate_offers: Vec<String>,
    /// Transparent profiles (`P-Dual`) included by this host.
    #[serde(default)]
    pub profiles: Vec<String>,
    /// Direct atomic agents included by this host.
    #[serde(default)]
    pub agents: Vec<String>,
    /// Named multi-instance agent instantiations (`QA-02`).
    #[serde(default)]
    pub instances: BTreeMap<String, InstanceSpec>,
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
    /// Catalog of all agents keyed by ID.
    pub agents: BTreeMap<String, AgentManifest>,
    /// Catalog of all transparent profiles keyed by ID.
    pub profiles: BTreeMap<String, ProfileManifest>,
    /// Catalog of all host superagents keyed by ID.
    pub hosts: BTreeMap<String, HostManifest>,
    /// Cedar `L3+` authorization policies and entities.
    pub policy_catalog: PolicyCatalog,
}

/// Verification report for one host superagent.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct HostReport {
    /// Host identifier.
    pub host_id: String,
    /// Target architecture.
    pub system: String,
    /// Flattened unique list of active agents.
    pub resolved_agents: Vec<String>,
    /// Missing agent or profile reference errors.
    pub missing_refs: Vec<String>,
    /// `B3` scoped binding errors.
    pub binding_errors: Vec<BindingError>,
    /// `P-Explicit` interior conformance errors.
    pub boundary_errors: Vec<BoundaryError>,
    /// `S2+` open-trait state safety errors.
    pub state_errors: Vec<StateError>,
    /// Paths requiring local persistence (`survives-reboot \ (reconstructible ∪ external-owned)`).
    pub persistent_paths: Vec<String>,
}

impl HostReport {
    /// Returns `true` iff this host passed every check with zero errors.
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
    /// Per-host diagnostic reports keyed by host ID.
    pub hosts: BTreeMap<String, HostReport>,
    /// Standalone agents validated as self-contained (`X4`).
    pub standalone_agents: Vec<String>,
}

impl FleetReport {
    /// Returns `true` iff every host in the fleet is valid.
    #[must_use]
    pub fn is_valid(&self) -> bool {
        self.hosts.values().all(HostReport::is_valid)
    }
}

/// Deterministic `S1` binding resolution output matching `lib/realize.nix` bit-for-bit.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct ResolvedHostBindings {
    /// Host identifier.
    pub host_id: String,
    /// Target architecture.
    pub system: String,
    /// Flattened sorted list of active agent IDs.
    pub agents: Vec<String>,
    /// Sorted list of state paths requiring local persistence.
    pub persistent_paths: Vec<String>,
    /// Per-agent resolved `bound` map (`agent_id -> req_key -> offer_payload`).
    pub bound_by_agent: BTreeMap<String, BTreeMap<String, Value>>,
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

fn flatten_profiles(fleet: &FleetSpec, host: &HostManifest) -> (Vec<String>, Vec<String>) {
    let mut visited_profiles = BTreeSet::new();
    let mut stack: Vec<String> = host.profiles.clone();
    let mut active_agents = BTreeSet::new();
    let mut missing = Vec::new();

    while let Some(pid) = stack.pop() {
        if !visited_profiles.insert(pid.clone()) {
            continue;
        }
        if let Some(prof) = fleet.profiles.get(&pid) {
            for sub in &prof.profiles {
                stack.push(sub.clone());
            }
            for a in &prof.agents {
                active_agents.insert(a.clone());
            }
        } else {
            missing.push(format!("profile:{pid}"));
        }
    }

    for a in &host.agents {
        active_agents.insert(a.clone());
    }
    for inst in host.instances.values() {
        active_agents.insert(inst.agent.clone());
    }

    for a in &active_agents {
        if !fleet.agents.contains_key(a) {
            missing.push(format!("agent:{a}"));
        }
    }

    (active_agents.into_iter().collect(), missing)
}

struct CompiledHostScope {
    resolved_agents: Vec<String>,
    missing_refs: Vec<String>,
    promises: Vec<Promise>,
    exterior: ExteriorSurface,
    children: Vec<ExteriorSurface>,
    substrate: SubstrateCapabilities,
    volumes: Vec<StateVolume>,
    persistent_paths: Vec<String>,
}

fn build_ambient_promises(host: &HostManifest) -> Vec<Promise> {
    let mut ambient_ps = vec![Promise {
        id: format!("{}:+ram", host.id),
        ptype: "ram".to_string(),
        key: "ram".to_string(),
        polarity: Polarity::Offer,
        strength: Strength::Hard,
        cardinality: Cardinality::Budgeted,
        mandatory: true,
        amount: host.ram_mib,
        priority: 0,
        stratum: 0,
        tags: Vec::new(),
        selector: AttrExpr::Any,
        soft_info: None,
    }];
    for off in &host.substrate_offers {
        ambient_ps.push(Promise {
            id: format!("{}:+{off}", host.id),
            ptype: off.clone(),
            key: off.clone(),
            polarity: Polarity::Offer,
            strength: Strength::Hard,
            cardinality: Cardinality::Exclusive,
            mandatory: true,
            amount: 0,
            priority: 0,
            stratum: 0,
            tags: Vec::new(),
            selector: AttrExpr::Any,
            soft_info: None,
        });
    }
    ambient_ps
}

fn build_agent_promises(aid: &str, agent: &AgentManifest) -> Vec<Promise> {
    let mut aps = Vec::new();
    if agent.budgets.ram_mib > 0 {
        let prio = u64::from(agent.budgets.tier != "critical");
        aps.push(Promise {
            id: format!("{aid}:-ram"),
            ptype: "ram".to_string(),
            key: "ram".to_string(),
            polarity: Polarity::Use,
            strength: Strength::Hard,
            cardinality: Cardinality::Budgeted,
            mandatory: true,
            amount: agent.budgets.ram_mib,
            priority: prio,
            stratum: 1,
            tags: Vec::new(),
            selector: AttrExpr::Any,
            soft_info: None,
        });
    }
    for (okey, ospec) in &agent.offers {
        aps.push(Promise {
            id: format!("{aid}:+{okey}"),
            ptype: okey.clone(),
            key: okey.clone(),
            polarity: Polarity::Offer,
            strength: ospec.strength,
            cardinality: ospec.kind,
            mandatory: true,
            amount: 0,
            priority: 0,
            stratum: 1,
            tags: ospec.tags.clone(),
            selector: AttrExpr::Any,
            soft_info: ospec.soft.clone(),
        });
    }
    for (rkey, rspec) in &agent.requires {
        aps.push(Promise {
            id: format!("{aid}:-{rkey}"),
            ptype: rkey.clone(),
            key: rkey.clone(),
            polarity: Polarity::Use,
            strength: rspec.strength,
            cardinality: rspec.kind,
            mandatory: rspec.mandatory,
            amount: 0,
            priority: 0,
            stratum: 1,
            tags: Vec::new(),
            selector: rspec.selector.clone(),
            soft_info: rspec.soft.clone(),
        });
    }
    aps
}

fn compile_host_scope(fleet: &FleetSpec, host: &HostManifest) -> CompiledHostScope {
    let (resolved_agents, missing_refs) = flatten_profiles(fleet, host);
    let ambient_ps = build_ambient_promises(host);
    let mut promises = ambient_ps.clone();
    let mut children = vec![ExteriorSurface {
        agent_id: format!("{}-ambient", host.id),
        promises: ambient_ps,
        attributes: host.attributes.clone(),
    }];
    let mut volumes = Vec::new();
    let mut persistent_paths = BTreeSet::new();
    let mut combined_traits: BTreeSet<String> = host.substrate_traits.iter().cloned().collect();

    for aid in &resolved_agents {
        if let Some(agent) = fleet.agents.get(aid) {
            combined_traits.extend(agent.contributes_traits.iter().cloned());
            let aps = build_agent_promises(aid, agent);
            promises.extend(aps.iter().cloned());
            for (vname, vspec) in &agent.state {
                if needs_local_persistence(&vspec.traits) {
                    persistent_paths.insert(vspec.path.clone());
                }
                volumes.push(StateVolume {
                    id: format!("{aid}:{vname}"),
                    owner: aid.clone(),
                    traits: vspec.traits.clone(),
                });
            }
            children.push(ExteriorSurface {
                agent_id: aid.clone(),
                promises: aps,
                attributes: Vec::new(),
            });
        }
    }

    let provides_durable_storage =
        combined_traits.contains("durable") && !combined_traits.contains("ephemeral");
    let substrate = SubstrateCapabilities {
        provides_durable_storage,
        backup_provider_count: host.backup_providers,
    };
    let exterior = ExteriorSurface {
        agent_id: host.id.clone(),
        promises: Vec::new(),
        attributes: host.attributes.clone(),
    };

    CompiledHostScope {
        resolved_agents,
        missing_refs,
        promises,
        exterior,
        children,
        substrate,
        volumes,
        persistent_paths: persistent_paths.into_iter().collect(),
    }
}

/// Verifies every host superagent and standalone agent in `fleet`.
#[must_use]
pub fn verify_fleet(fleet: &FleetSpec) -> FleetReport {
    let mut hosts = BTreeMap::new();
    for (hid, hspec) in &fleet.hosts {
        let compiled = compile_host_scope(fleet, hspec);
        let binding_errors = validate_scope(&compiled.promises);
        let boundary_errors =
            validate_superagent_conformance(&compiled.exterior, &compiled.children);
        let state_errors = validate_volumes(&compiled.substrate, &compiled.volumes);

        hosts.insert(
            hid.clone(),
            HostReport {
                host_id: hid.clone(),
                system: hspec.system.clone(),
                resolved_agents: compiled.resolved_agents,
                missing_refs: compiled.missing_refs,
                binding_errors,
                boundary_errors,
                state_errors,
                persistent_paths: compiled.persistent_paths,
            },
        );
    }

    // Standalone check (X4): agent has zero mandatory Hard requirements outside store-only scope
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
        hosts,
        standalone_agents,
    }
}

/// Deterministically resolves `bound` offers & `persistent_paths` for a host,
/// mirroring `v2/lib/realize.nix` for the `S1` CI binding-equivalence test.
#[must_use]
pub fn resolve_host_bindings(fleet: &FleetSpec, host_id: &str) -> Option<ResolvedHostBindings> {
    let host = fleet.hosts.get(host_id)?;
    let compiled = compile_host_scope(fleet, host);

    let mut all_offers: BTreeMap<String, Value> = BTreeMap::new();
    for off in &host.substrate_offers {
        all_offers.insert(off.clone(), serde_json::json!({ "kind": "exclusive" }));
    }
    for aid in &compiled.resolved_agents {
        if let Some(agent) = fleet.agents.get(aid) {
            for (okey, ospec) in &agent.offers {
                let mut map = serde_json::Map::new();
                if let Ok(kind_val) = serde_json::to_value(ospec.kind) {
                    map.insert("kind".to_string(), kind_val);
                }
                for (k, v) in &ospec.payload {
                    map.insert(k.clone(), v.clone());
                }
                all_offers.insert(okey.clone(), Value::Object(map));
            }
        }
    }

    let mut bound_by_agent = BTreeMap::new();
    for aid in &compiled.resolved_agents {
        if let Some(agent) = fleet.agents.get(aid) {
            let mut bound = BTreeMap::new();
            for rkey in agent.requires.keys() {
                if let Some(val) = all_offers.get(rkey) {
                    bound.insert(rkey.clone(), val.clone());
                }
            }
            bound_by_agent.insert(aid.clone(), bound);
        }
    }

    Some(ResolvedHostBindings {
        host_id: host.id.clone(),
        system: host.system.clone(),
        agents: compiled.resolved_agents,
        persistent_paths: compiled.persistent_paths,
        bound_by_agent,
    })
}

/// Projects a real Antikythera host + policies into an [`OracleRequest`] for live Lean 4 DRT!
#[must_use]
pub fn host_to_oracle_request(fleet: &FleetSpec, host_id: &str) -> Option<OracleRequest> {
    let host = fleet.hosts.get(host_id)?;
    let compiled = compile_host_scope(fleet, host);
    let blast_target = fleet
        .policy_catalog
        .principals
        .first()
        .cloned()
        .unwrap_or_else(|| Entity {
            id: host.id.clone(),
            tags: host.attributes.clone(),
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

    Some(OracleRequest {
        conformance: ConformanceCheck {
            exterior: compiled.exterior,
            children: compiled.children,
        },
        promises: compiled.promises,
        stratum_rules: Vec::new(),
        policies: fleet.policy_catalog.policies.clone(),
        auth_queries,
        delegated_queries: Vec::new(),
        blast_target,
        blast_action: "read-secret".to_string(),
        all_resources: fleet.policy_catalog.resources.clone(),
        substrate: compiled.substrate,
        volumes: compiled.volumes,
    })
}
