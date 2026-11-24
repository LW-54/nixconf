//! AWS Cedar Verification-Guided Development (VGD) Differential Randomized Testing (DRT)
//! wire protocol and deterministic generator mirroring `Aky/Oracle/Protocol.lean`.

use serde::{Deserialize, Serialize};

use crate::agency::{
    Agent, Cardinality, ExteriorSurface, Polarity, Promise, SoftContract, Strength,
};
use crate::attr_expr::AttrExpr;
use crate::authority::{
    AuthPolicy, AuthResponse, Capability, Effect, Entity, authorize, blast_radius,
    is_delegated_authorized,
};
use crate::binding::{HandlerRule, check_agent_tree, is_scope_valid, validate_stratum_rules};
use crate::state::{StateVolume, SubstrateCapabilities, all_volumes_valid};

/// Authorization query sent to both `aky-core` and `aky-oracle`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct AuthQuery {
    /// Principal entity.
    pub principal: Entity,
    /// Action name.
    pub action: String,
    /// Resource entity.
    pub resource: Entity,
}

/// Cross-boundary delegated authorization query.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct DelegatedQuery {
    /// Delegating principal.
    pub delegator: Entity,
    /// Receiving delegatee.
    pub delegatee: Entity,
    /// Attenuated Biscuit capability.
    pub capability: Capability,
    /// Action name.
    pub action: String,
    /// Resource entity.
    pub resource: Entity,
}

/// Complete DRT request wire frame consumed by `aky-oracle` (`Aky.Oracle.Protocol`).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct OracleRequest {
    /// Full recursive Fractal Uniform Agent tree verified non-piercingly.
    pub agent_tree: Agent,
    /// Scope promises.
    pub promises: Vec<Promise>,
    /// Multi-stratum handler rules.
    pub stratum_rules: Vec<HandlerRule>,
    /// Cedar authorization policies.
    pub policies: Vec<AuthPolicy>,
    /// Direct authorization queries.
    pub auth_queries: Vec<AuthQuery>,
    /// Combined cross-boundary delegation queries.
    pub delegated_queries: Vec<DelegatedQuery>,
    /// Principal target for blast-radius query.
    pub blast_target: Entity,
    /// Action for blast-radius query.
    pub blast_action: String,
    /// Universe of resources for blast-radius query.
    pub all_resources: Vec<Entity>,
    /// Substrate capabilities.
    pub substrate: SubstrateCapabilities,
    /// Declared state volumes.
    pub volumes: Vec<StateVolume>,
}

/// Complete DRT response wire frame emitted by both `aky-core` and `aky-oracle`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
#[expect(
    clippy::struct_excessive_bools,
    reason = "Mirrors Aky.Oracle.Protocol JSON wire schema verbatim"
)]
pub struct OracleResponse {
    /// Cedar verdicts with `determiningPolicies`.
    pub auth_responses: Vec<AuthResponse>,
    /// Blast-radius resource IDs.
    pub blast_radius: Vec<String>,
    /// Combined delegation verdicts.
    pub delegated_results: Vec<bool>,
    /// `B3` scoped binding verdict.
    pub scope_valid: bool,
    /// `S2+` open-trait & CALM state verdict.
    pub state_valid: bool,
    /// Multi-stratum DAG acyclicity verdict.
    pub stratum_valid: bool,
    /// Full recursive `Agent` tree non-piercing conformance + binding verdict.
    pub tree_valid: bool,
}

/// Evaluates an [`OracleRequest`] using the pure Rust `aky-core` kernel.
#[must_use]
pub fn eval_request(req: &OracleRequest) -> OracleResponse {
    let tree_valid = check_agent_tree(&req.agent_tree);
    let scope_valid = is_scope_valid(&req.promises);
    let stratum_valid = validate_stratum_rules(&req.stratum_rules);
    let auth_responses = req
        .auth_queries
        .iter()
        .map(|q| authorize(&req.policies, &q.principal, &q.action, &q.resource))
        .collect();
    let delegated_results = req
        .delegated_queries
        .iter()
        .map(|q| {
            is_delegated_authorized(
                &req.policies,
                &q.delegator,
                &q.delegatee,
                &q.capability,
                &q.action,
                &q.resource,
            )
        })
        .collect();
    let blast = blast_radius(
        &req.policies,
        &req.blast_target,
        &req.blast_action,
        &req.all_resources,
    );
    let state_valid = all_volumes_valid(&req.substrate, &req.volumes);

    OracleResponse {
        auth_responses,
        blast_radius: blast,
        delegated_results,
        scope_valid,
        state_valid,
        stratum_valid,
        tree_valid,
    }
}

/// Deterministic `SplitMix64` PRNG (zero external RNG dependencies, reproducible DRT seeds).
struct Rng(u64);

impl Rng {
    const fn new(seed: u64) -> Self {
        Self(seed)
    }

    const fn next_u64(&mut self) -> u64 {
        self.0 = self.0.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let mut z = self.0;
        z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        z ^ (z >> 31)
    }

    fn pick<'a, T>(&mut self, items: &'a [T]) -> Option<&'a T> {
        let len = u64::try_from(items.len()).ok()?;
        if len == 0 {
            return None;
        }
        let idx = usize::try_from(self.next_u64().checked_rem(len)?).ok()?;
        items.get(idx)
    }

    const fn flip(&mut self) -> bool {
        (self.next_u64() & 1) == 1
    }

    const fn range(&mut self, bound: u64) -> u64 {
        match self.next_u64().checked_rem(bound) {
            Some(v) => v,
            None => 0,
        }
    }
}

const TAGS: &[&str] = &[
    "role:server",
    "role:workstation",
    "posture:roaming",
    "actor:ai-agent",
    "env:prod",
    "zone:public",
    "zone:mesh",
];

const STATE_TAGS: &[&str] = &[
    "survives-reboot",
    "reconstructible",
    "external-owned",
    "multi-writer",
    "monotonic",
    "single-auth-writer",
    "backup-required",
];

fn rand_expr(rng: &mut Rng, depth: u8) -> AttrExpr {
    if depth == 0 {
        let tag = rng.pick(TAGS).copied().unwrap_or("role:server");
        return AttrExpr::atom(tag);
    }
    let next_depth = depth.saturating_sub(1);
    match rng.range(6) {
        0 => AttrExpr::atom(rng.pick(TAGS).copied().unwrap_or("role:server")),
        1 => AttrExpr::union(rand_expr(rng, next_depth), rand_expr(rng, next_depth)),
        2 => AttrExpr::inter(rand_expr(rng, next_depth), rand_expr(rng, next_depth)),
        3 => AttrExpr::diff(rand_expr(rng, next_depth), rand_expr(rng, next_depth)),
        4 => AttrExpr::compl(rand_expr(rng, next_depth)),
        _ => AttrExpr::Any,
    }
}

fn rand_tags(rng: &mut Rng, pool: &[&str], max_n: u64) -> Vec<String> {
    let n = rng.range(max_n.saturating_add(1));
    let mut out = Vec::new();
    for _ in 0..n {
        if let Some(&t) = rng.pick(pool) {
            out.push(t.to_string());
        }
    }
    out
}

fn rand_promises(rng: &mut Rng, case_idx: usize) -> Vec<Promise> {
    let ptypes = ["proxy:https", "ram", "metrics", "http:route"];
    let keys = ["k0", "k1", "ram"];
    let n_ps = rng.range(6).saturating_add(2);
    let mut promises = Vec::new();
    for j in 0..n_ps {
        let card = match rng.range(4) {
            0 => Cardinality::Exclusive,
            1 => Cardinality::Broadcast,
            2 => Cardinality::Partitioned,
            _ => Cardinality::Budgeted,
        };
        let strength = if rng.flip() {
            Strength::Hard
        } else {
            Strength::Soft
        };
        let soft_info = if strength == Strength::Soft && rng.range(4) != 0 {
            Some(SoftContract {
                condition_ref: "power:ac-plugged".to_string(),
                degraded_mode: "pause-gracefully".to_string(),
                probe_id: format!("probe-{j}"),
            })
        } else {
            None
        };
        promises.push(Promise {
            id: format!("p-{case_idx}-{j}"),
            ptype: rng.pick(&ptypes).copied().unwrap_or("ram").to_string(),
            key: rng.pick(&keys).copied().unwrap_or("k0").to_string(),
            polarity: if rng.flip() {
                Polarity::Offer
            } else {
                Polarity::Use
            },
            strength,
            cardinality: card,
            mandatory: rng.flip(),
            amount: rng.range(2048),
            priority: rng.range(2),
            stratum: rng.range(3),
            tags: rand_tags(rng, TAGS, 3),
            selector: rand_expr(rng, 1),
            soft_info,
        });
    }
    promises
}

fn mk_budget_promise(id: &str, polarity: Polarity, amount: u64, priority: u64) -> Promise {
    Promise {
        id: id.to_string(),
        ptype: "ram".to_string(),
        key: "ram".to_string(),
        polarity,
        strength: Strength::Hard,
        cardinality: Cardinality::Budgeted,
        mandatory: true,
        amount,
        priority,
        stratum: 1,
        tags: Vec::new(),
        selector: AttrExpr::Any,
        soft_info: None,
    }
}

fn rand_nested_superagent(rng: &mut Rng, i: usize) -> (Agent, u64) {
    let child_ram = rng.range(256).saturating_add(64);
    let child_prio = rng.range(2);
    let nested_ram = if rng.flip() {
        child_ram.saturating_add(rng.range(64))
    } else {
        child_ram.saturating_sub(32)
    };
    let nested_prio = if rng.flip() { child_prio } else { 1 };

    let leaf_vol = StateVolume {
        id: format!("/var/lib/svc-{i}"),
        owner: format!("leaf-{i}"),
        traits: rand_tags(rng, STATE_TAGS, 3),
    };
    let nested_ext_vols = if rng.flip() {
        vec![StateVolume {
            id: leaf_vol.id.clone(),
            owner: format!("nested-{i}"),
            traits: leaf_vol.traits.clone(),
        }]
    } else {
        Vec::new()
    };

    let leaf_a = Agent::Atomic {
        ext: ExteriorSurface {
            agent_id: format!("leaf-{i}"),
            promises: vec![
                mk_budget_promise(
                    &format!("leaf-{i}:-ram"),
                    Polarity::Use,
                    child_ram,
                    child_prio,
                ),
                Promise {
                    id: format!("leaf-{i}:+route"),
                    ptype: "http:route".to_string(),
                    key: format!("r-{i}"),
                    polarity: Polarity::Offer,
                    strength: Strength::Hard,
                    cardinality: Cardinality::Partitioned,
                    mandatory: true,
                    amount: 0,
                    priority: 0,
                    stratum: 1,
                    tags: vec!["zone:public".to_string()],
                    selector: AttrExpr::Any,
                    soft_info: None,
                },
            ],
            attributes: Vec::new(),
            volumes: vec![leaf_vol],
        },
        interior_hash: "h-leaf".to_string(),
    };

    let nested = Agent::Superagent {
        ext: ExteriorSurface {
            agent_id: format!("nested-{i}"),
            promises: vec![mk_budget_promise(
                &format!("nested-{i}:-ram"),
                Polarity::Use,
                nested_ram,
                nested_prio,
            )],
            attributes: Vec::new(),
            volumes: nested_ext_vols,
        },
        children: vec![leaf_a],
    };
    (nested, nested_ram)
}

fn rand_substrate_profile(
    rng: &mut Rng,
    i: usize,
    nested_ram: u64,
    promises: &[Promise],
    volumes: &[StateVolume],
) -> Agent {
    let root_ram = if rng.flip() {
        nested_ram.saturating_add(512)
    } else {
        nested_ram.saturating_sub(32)
    };
    let mut sub_attrs = Vec::new();
    if rng.flip() {
        sub_attrs.push("trait:durable".to_string());
    }
    if rng.range(4) == 0 {
        sub_attrs.push("trait:ephemeral".to_string());
    }
    let mut sub_promises = vec![mk_budget_promise(
        &format!("root-{i}:+ram"),
        Polarity::Offer,
        root_ram,
        0,
    )];
    if rng.flip() {
        sub_promises.push(Promise {
            id: format!("root-{i}:+bak"),
            ptype: "backup:provider".to_string(),
            key: "backup:provider".to_string(),
            polarity: Polarity::Offer,
            strength: Strength::Hard,
            cardinality: Cardinality::Broadcast,
            mandatory: true,
            amount: 0,
            priority: 0,
            stratum: 0,
            tags: Vec::new(),
            selector: AttrExpr::Any,
            soft_info: None,
        });
    }
    if rng.range(3) == 0 {
        sub_promises.extend(promises.iter().take(2).cloned());
    }

    Agent::Profile {
        members: vec![Agent::Atomic {
            ext: ExteriorSurface {
                agent_id: format!("sub-{i}"),
                promises: sub_promises,
                attributes: sub_attrs,
                volumes: volumes.iter().take(1).cloned().collect(),
            },
            interior_hash: "h-sub".to_string(),
        }],
    }
}

fn rand_agent_tree(
    rng: &mut Rng,
    i: usize,
    promises: &[Promise],
    volumes: &[StateVolume],
) -> Agent {
    let (nested, nested_ram) = rand_nested_superagent(rng, i);
    let substrate_profile = rand_substrate_profile(rng, i, nested_ram, promises, volumes);
    Agent::Superagent {
        ext: ExteriorSurface {
            agent_id: format!("root-{i}"),
            promises: Vec::new(),
            attributes: rand_tags(rng, TAGS, 2),
            volumes: Vec::new(),
        },
        children: vec![substrate_profile, nested],
    }
}

fn rand_stratum_rules(rng: &mut Rng, i: usize) -> Vec<HandlerRule> {
    let in_s = rng.range(3);
    let out_s = if rng.range(4) == 0 {
        in_s
    } else {
        in_s.saturating_add(1)
    };
    vec![HandlerRule {
        id: format!("rule-{i}"),
        in_stratum: in_s,
        out_stratum: out_s,
        emitted: vec![Promise {
            id: format!("em-{i}"),
            ptype: "metrics".to_string(),
            key: "k0".to_string(),
            polarity: Polarity::Offer,
            strength: Strength::Hard,
            cardinality: Cardinality::Broadcast,
            mandatory: false,
            amount: 0,
            priority: 1,
            stratum: out_s,
            tags: Vec::new(),
            selector: AttrExpr::Any,
            soft_info: None,
        }],
    }]
}

fn rand_policies(rng: &mut Rng, i: usize) -> Vec<AuthPolicy> {
    (0..rng.range(4).saturating_add(1))
        .map(|p_idx| AuthPolicy {
            id: format!("pol-{i}-{p_idx}"),
            effect: if rng.flip() {
                Effect::Permit
            } else {
                Effect::Forbid
            },
            action: "read-secret".to_string(),
            principal_pred: rand_expr(rng, 2),
            resource_pred: rand_expr(rng, 2),
        })
        .collect()
}

fn generate_single_case(rng: &mut Rng, i: usize) -> OracleRequest {
    let promises = rand_promises(rng, i);
    let stratum_rules = rand_stratum_rules(rng, i);
    let policies = rand_policies(rng, i);

    let delegator = Entity {
        id: "admin".to_string(),
        tags: rand_tags(rng, TAGS, 3),
    };
    let delegatee = Entity {
        id: "agy".to_string(),
        tags: rand_tags(rng, TAGS, 3),
    };
    let resources: Vec<Entity> = (0..3)
        .map(|r| Entity {
            id: format!("res-{r}"),
            tags: rand_tags(rng, TAGS, 3),
        })
        .collect();
    let res0 = resources.first().cloned().unwrap_or_else(|| Entity {
        id: "res-0".to_string(),
        tags: Vec::new(),
    });
    let volumes: Vec<StateVolume> = (0..rng.range(3).saturating_add(1))
        .map(|v| StateVolume {
            id: format!("vol-{i}-{v}"),
            owner: format!("svc-{v}"),
            traits: rand_tags(rng, STATE_TAGS, 4),
        })
        .collect();
    let agent_tree = rand_agent_tree(rng, i, &promises, &volumes);

    OracleRequest {
        agent_tree,
        promises,
        stratum_rules,
        policies,
        auth_queries: vec![
            AuthQuery {
                principal: delegator.clone(),
                action: "read-secret".to_string(),
                resource: res0.clone(),
            },
            AuthQuery {
                principal: delegatee.clone(),
                action: "read-secret".to_string(),
                resource: res0.clone(),
            },
        ],
        delegated_queries: vec![DelegatedQuery {
            delegator: delegator.clone(),
            delegatee,
            capability: Capability {
                root_policy_id: "root".to_string(),
                allowed_action: "read-secret".to_string(),
                caveats: vec![rand_expr(rng, 1)],
            },
            action: "read-secret".to_string(),
            resource: res0,
        }],
        blast_target: delegator,
        blast_action: "read-secret".to_string(),
        all_resources: resources,
        substrate: SubstrateCapabilities {
            provides_durable_storage: rng.flip(),
            backup_provider_count: rng.range(2),
        },
        volumes,
    }
}

/// Generates `count` deterministic fuzzed [`OracleRequest`] vectors exercising every Lean theorem.
#[must_use]
pub fn generate_fuzzed_cases(seed: u64, count: usize) -> Vec<OracleRequest> {
    let mut rng = Rng::new(seed);
    (0..count)
        .map(|i| generate_single_case(&mut rng, i))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::{eval_request, generate_fuzzed_cases};

    #[test]
    fn generator_produces_deterministic_cases() {
        let a = generate_fuzzed_cases(42, 32);
        let b = generate_fuzzed_cases(42, 32);
        assert_eq!(a, b);
        let mut saw_true = false;
        let mut saw_false = false;
        for case in &a {
            let resp = eval_request(case);
            if resp.tree_valid {
                saw_true = true;
            } else {
                saw_false = true;
            }
        }
        assert!(saw_true, "expected at least one valid fuzzed agent tree");
        assert!(saw_false, "expected at least one invalid fuzzed agent tree");
    }
}
