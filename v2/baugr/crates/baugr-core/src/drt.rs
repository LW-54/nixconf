//! AWS Cedar Verification-Guided Development (VGD) Differential Randomized Testing (DRT)
//! wire protocol and deterministic generator (`F-2`, `F-3`, `F-6`) mirroring `Baugr/Oracle/Protocol.lean`.

use serde::{Deserialize, Serialize};

use crate::agency::{
    Agent, Cardinality, ExteriorSurface, Polarity, Promise, SoftContract, Strength,
};
use crate::attr_expr::AttrExpr;
use crate::authority::{
    AuthPolicy, AuthResponse, Capability, Effect, Entity, authorize, blast_radius,
    is_delegated_authorized,
};
use crate::binding::{AuthBinding, check_agent_tree, is_scope_valid};
use crate::invariants::{PromiseInvariant, all_invariants_hold};
use crate::resolve::{ResolvedScope, resolve_agent_tree};
use crate::spacetime::{impact_cone, project_agent_sst, reverse_impact_cone};

/// Authorization query sent to both `baugr-core` and `baugr-oracle`.
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

/// Complete DRT request wire frame consumed by `baugr-oracle` (`Baugr.Oracle.Protocol`).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct OracleRequest {
    /// Full recursive Fractal Uniform Agent tree verified & resolved non-piercingly.
    pub agent_tree: Agent,
    /// Declarative `AttrExpr` promise invariants.
    pub invariants: Vec<PromiseInvariant>,
    /// Scope promises.
    pub promises: Vec<Promise>,
    /// Cedar authorization policies.
    pub policies: Vec<AuthPolicy>,
    /// Usage-agnostic structural Cedar authorization bindings.
    #[serde(default)]
    pub auth_bindings: Vec<AuthBinding>,
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
    /// Seed node ID for SST forward & reverse impact-cone DRT (`F-3`).
    #[serde(default)]
    pub sst_seed: String,
}

/// Complete DRT response wire frame emitted by both `baugr-core` and `baugr-oracle`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct OracleResponse {
    /// Cedar verdicts with `determiningPolicies`.
    pub auth_responses: Vec<AuthResponse>,
    /// Blast-radius resource IDs.
    pub blast_radius: Vec<String>,
    /// Combined delegation verdicts.
    pub delegated_results: Vec<bool>,
    /// Declarative promise invariant verdict.
    pub invariants_valid: bool,
    /// Exact recursive `resolveAgentTree` output (`F-2` Progress & Preservation DRT!).
    pub resolved_scopes: Option<Vec<ResolvedScope>>,
    /// `B3` scoped binding verdict.
    pub scope_valid: bool,
    /// Projected SST unique edge count (`F-3`).
    pub sst_edge_count: usize,
    /// Sorted forward SST `FOLLOWS` impact cone from `sst_seed` (`F-3`).
    pub sst_impact_cone: Vec<String>,
    /// Projected SST unique node count (`F-3`).
    pub sst_node_count: usize,
    /// Sorted reverse SST `FOLLOWS` impact cone from `sst_seed` (`F-3`).
    pub sst_reverse_impact_cone: Vec<String>,
    /// Full recursive `Agent` tree verdict mirroring `Baugr.Engine.checkAgentTree`.
    pub tree_valid: bool,
}

/// Evaluates an [`OracleRequest`] using the pure Rust `baugr-core` kernel.
#[must_use]
pub fn eval_request(req: &OracleRequest) -> OracleResponse {
    let tree_valid = check_agent_tree(
        &req.invariants,
        &req.policies,
        &req.auth_bindings,
        &req.agent_tree,
    );
    let resolved_scopes = resolve_agent_tree(&req.agent_tree);
    let sst = project_agent_sst(&req.agent_tree);
    let sst_impact_cone = if req.sst_seed.is_empty() {
        Vec::new()
    } else {
        impact_cone(&sst, 4, std::slice::from_ref(&req.sst_seed))
    };
    let sst_reverse_impact_cone = if req.sst_seed.is_empty() {
        Vec::new()
    } else {
        reverse_impact_cone(&sst, 4, &req.sst_seed)
    };
    let invariants_valid = all_invariants_hold(&req.invariants, &req.promises);
    let scope_valid = is_scope_valid(&req.promises);
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

    OracleResponse {
        auth_responses,
        blast_radius: blast,
        delegated_results,
        invariants_valid,
        resolved_scopes,
        scope_valid,
        sst_edge_count: sst.edges.len(),
        sst_impact_cone,
        sst_node_count: sst.nodes.len(),
        sst_reverse_impact_cone,
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

const TAGS: &[&str] = &["t0", "t1", "t2", "t3", "t4", "t5", "t6"];
const PTYPES: &[&str] = &["cap:a", "cap:b", "cap:c", "cap:d"];
const KEYS: &[&str] = &["k0", "k1", "k2"];

fn rand_expr(rng: &mut Rng, depth: u8) -> AttrExpr {
    if depth == 0 {
        let tag = rng.pick(TAGS).copied().unwrap_or("t0");
        return AttrExpr::atom(tag);
    }
    let next_depth = depth.saturating_sub(1);
    match rng.range(6) {
        0 => AttrExpr::atom(rng.pick(TAGS).copied().unwrap_or("t0")),
        1 => AttrExpr::union(rand_expr(rng, next_depth), rand_expr(rng, next_depth)),
        2 => AttrExpr::inter(rand_expr(rng, next_depth), rand_expr(rng, next_depth)),
        3 => AttrExpr::diff(rand_expr(rng, next_depth), rand_expr(rng, next_depth)),
        4 => AttrExpr::compl(rand_expr(rng, next_depth)),
        _ => AttrExpr::Any,
    }
}

fn rand_tags(rng: &mut Rng, max_n: u64) -> Vec<String> {
    let n = rng.range(max_n.saturating_add(1));
    let mut out = Vec::new();
    for _ in 0..n {
        if let Some(&t) = rng.pick(TAGS) {
            out.push(t.to_string());
        }
    }
    out
}

fn rand_promises(rng: &mut Rng, case_idx: usize) -> Vec<Promise> {
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
                condition_ref: "cond:0".to_string(),
                degraded_mode: "degraded:0".to_string(),
                probe_id: format!("probe-{j}"),
            })
        } else {
            None
        };
        promises.push(Promise {
            id: format!("p-{case_idx}-{j}"),
            ptype: rng.pick(PTYPES).copied().unwrap_or("cap:a").to_string(),
            key: rng.pick(KEYS).copied().unwrap_or("k0").to_string(),
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
            tags: rand_tags(rng, 3),
            selector: rand_expr(rng, 1),
            soft_info,
        });
    }
    promises
}

fn mk_budget(id: &str, polarity: Polarity, amount: u64, priority: u64) -> Promise {
    Promise {
        id: id.to_string(),
        ptype: "cap:b".to_string(),
        key: "cap:b".to_string(),
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

fn mk_part_offer(id: &str, key: &str, tags: Vec<String>, mandatory: bool) -> Promise {
    Promise {
        id: id.to_string(),
        ptype: "cap:c".to_string(),
        key: key.to_string(),
        polarity: Polarity::Offer,
        strength: Strength::Hard,
        cardinality: Cardinality::Partitioned,
        mandatory,
        amount: 0,
        priority: 0,
        stratum: 1,
        tags,
        selector: AttrExpr::Any,
        soft_info: None,
    }
}

fn rand_nested_superagent(rng: &mut Rng, i: usize) -> (Agent, u64) {
    let child_bud = rng.range(256).saturating_add(64);
    let child_prio = rng.range(2);
    let nested_bud = if rng.range(3) != 0 {
        child_bud.saturating_add(rng.range(64))
    } else {
        child_bud.saturating_sub(32)
    };
    let nested_prio = if rng.range(3) != 0 { child_prio } else { 1 };
    let part_tags = vec!["t0".to_string()];
    let leaf_part = mk_part_offer(
        &format!("leaf-{i}:+c"),
        &format!("k-{i}"),
        part_tags.clone(),
        true,
    );

    let mut nested_promises = vec![
        mk_budget(
            &format!("nested-{i}:-b"),
            Polarity::Use,
            nested_bud,
            nested_prio,
        ),
        Promise {
            id: format!("nested-{i}:-d"),
            ptype: "cap:d".to_string(),
            key: "cap:d".to_string(),
            polarity: Polarity::Use,
            strength: Strength::Hard,
            cardinality: Cardinality::Broadcast,
            mandatory: true,
            amount: 0,
            priority: 0,
            stratum: 1,
            tags: Vec::new(),
            selector: AttrExpr::Any,
            soft_info: None,
        },
    ];
    if rng.range(3) != 0 {
        nested_promises.push(mk_part_offer(
            &format!("nested-{i}:+c"),
            &format!("k-{i}"),
            part_tags,
            true,
        ));
    }

    let leaf = Agent::Atomic {
        ext: ExteriorSurface {
            agent_id: format!("leaf-{i}"),
            promises: vec![
                mk_budget(
                    &format!("leaf-{i}:-b"),
                    Polarity::Use,
                    child_bud,
                    child_prio,
                ),
                Promise {
                    id: format!("leaf-{i}:-d"),
                    ptype: "cap:d".to_string(),
                    key: "cap:d".to_string(),
                    polarity: Polarity::Use,
                    strength: Strength::Hard,
                    cardinality: Cardinality::Broadcast,
                    mandatory: true,
                    amount: 0,
                    priority: 0,
                    stratum: 1,
                    tags: Vec::new(),
                    selector: AttrExpr::Any,
                    soft_info: None,
                },
                leaf_part,
            ],
            attributes: rand_tags(rng, 2),
        },
        interior_hash: "h-leaf".to_string(),
    };

    let nested = Agent::Superagent {
        ext: ExteriorSurface {
            agent_id: format!("nested-{i}"),
            promises: nested_promises,
            attributes: Vec::new(),
        },
        children: vec![leaf],
    };
    (nested, nested_bud)
}

fn rand_agent_tree(rng: &mut Rng, i: usize, promises: &[Promise]) -> Agent {
    let (nested, nested_bud) = rand_nested_superagent(rng, i);
    let root_bud = if rng.range(3) != 0 {
        nested_bud.saturating_add(512)
    } else {
        nested_bud.saturating_sub(32)
    };
    let mut provider_ps = vec![mk_budget(
        &format!("root-{i}:+b"),
        Polarity::Offer,
        root_bud,
        0,
    )];
    if rng.range(3) != 0 {
        provider_ps.push(Promise {
            id: format!("root-{i}:+d"),
            ptype: "cap:d".to_string(),
            key: "cap:d".to_string(),
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
    if rng.range(3) != 0 {
        provider_ps.push(Promise {
            id: format!("root-{i}:-c"),
            ptype: "cap:c".to_string(),
            key: "cap:c".to_string(),
            polarity: Polarity::Use,
            strength: Strength::Hard,
            cardinality: Cardinality::Partitioned,
            mandatory: false,
            amount: 0,
            priority: 0,
            stratum: 1,
            tags: Vec::new(),
            selector: AttrExpr::atom("t0"),
            soft_info: None,
        });
    }
    if rng.range(4) == 0 {
        provider_ps.extend(promises.iter().take(2).cloned());
    }

    let profile = Agent::Profile {
        members: vec![Agent::Atomic {
            ext: ExteriorSurface {
                agent_id: format!("prov-{i}"),
                promises: provider_ps,
                attributes: rand_tags(rng, 2),
            },
            interior_hash: "h-prov".to_string(),
        }],
    };

    Agent::Superagent {
        ext: ExteriorSurface {
            agent_id: format!("root-{i}"),
            promises: Vec::new(),
            attributes: rand_tags(rng, 2),
        },
        children: vec![profile, nested],
    }
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
            action: "act:0".to_string(),
            principal_pred: rand_expr(rng, 2),
            resource_pred: rand_expr(rng, 2),
        })
        .collect()
}

fn generate_single_case(rng: &mut Rng, i: usize) -> OracleRequest {
    let promises = rand_promises(rng, i);
    let invariants = vec![PromiseInvariant {
        id: format!("inv-{i}"),
        ptype: "cap:c".to_string(),
        forbid_tags: AttrExpr::diff(
            AttrExpr::atom("t1"),
            AttrExpr::union(AttrExpr::atom("t2"), AttrExpr::atom("t3")),
        ),
    }];
    let agent_tree = rand_agent_tree(rng, i, &promises);
    let policies = rand_policies(rng, i);

    let delegator = Entity {
        id: "p0".to_string(),
        tags: rand_tags(rng, 3),
    };
    let delegatee = Entity {
        id: "p1".to_string(),
        tags: rand_tags(rng, 3),
    };
    let resources: Vec<Entity> = (0..3)
        .map(|r| Entity {
            id: format!("r-{r}"),
            tags: rand_tags(rng, 3),
        })
        .collect();
    let res0 = resources.first().cloned().unwrap_or_else(|| Entity {
        id: "r-0".to_string(),
        tags: Vec::new(),
    });

    let auth_bindings = if rng.flip() {
        vec![AuthBinding {
            id: format!("ab-{i}"),
            ptype: "cap:a".to_string(),
            polarity: Polarity::Use,
            action: "act:0".to_string(),
            principal_filter: AttrExpr::atom("t0"),
        }]
    } else {
        Vec::new()
    };

    OracleRequest {
        agent_tree,
        invariants,
        promises,
        policies,
        auth_bindings,
        auth_queries: vec![
            AuthQuery {
                principal: delegator.clone(),
                action: "act:0".to_string(),
                resource: res0.clone(),
            },
            AuthQuery {
                principal: delegatee.clone(),
                action: "act:0".to_string(),
                resource: res0.clone(),
            },
        ],
        delegated_queries: vec![DelegatedQuery {
            delegator: delegator.clone(),
            delegatee,
            capability: Capability {
                root_policy_id: "root".to_string(),
                allowed_action: "act:0".to_string(),
                caveats: vec![rand_expr(rng, 1)],
            },
            action: "act:0".to_string(),
            resource: res0,
        }],
        blast_target: delegator,
        blast_action: "act:0".to_string(),
        all_resources: resources,
        sst_seed: format!("nested-{i}"),
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
    fn generator_exercises_tree_validity_resolve_progress_and_sst() {
        let a = generate_fuzzed_cases(42, 64);
        let b = generate_fuzzed_cases(42, 64);
        assert_eq!(a, b);
        let mut saw_true = false;
        let mut saw_false = false;
        for case in &a {
            let resp = eval_request(case);
            if resp.tree_valid {
                saw_true = true;
                // Empirical check of F-2 Type Soundness (Progress): valid tree MUST resolve!
                assert!(resp.resolved_scopes.is_some());
            } else {
                saw_false = true;
            }
            assert!(resp.sst_node_count > 0);
        }
        assert!(saw_true, "expected at least one valid fuzzed agent tree");
        assert!(saw_false, "expected at least one invalid fuzzed agent tree");
    }
}
