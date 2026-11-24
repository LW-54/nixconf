//! `B3` Scoped Binding, Budget Priority Tiering, Multi-Stratum Stratification,
//! and Recursive Non-Piercing `Agent` Tree Verification (100% usage-agnostic)
//! mirroring `Aky/Spec/Binding.lean`.

use serde::{Deserialize, Serialize};

use crate::agency::{
    Agent, Cardinality, ExteriorSurface, Polarity, Promise, Strength,
    count_matching_partition_handlers, critical_budget_demand, sibling_operational_view,
    superagent_conforms, total_budget_demand, total_budget_supply,
};
use crate::attr_expr::AttrExpr;
use crate::invariants::{PromiseInvariant, all_invariants_hold};

/// Declarative cross-stratum handler rule (`in_stratum < out_stratum`).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct HandlerRule {
    /// Unique handler identifier.
    pub id: String,
    /// Input stratum consumed by this handler.
    pub in_stratum: u64,
    /// Output stratum emitted by this handler.
    pub out_stratum: u64,
    /// Promises emitted at `out_stratum`.
    pub emitted: Vec<Promise>,
}

/// Structured binding violation diagnostic.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum BindingError {
    /// A `Soft` promise omitted its condition, degraded invariant, or probe.
    IncompleteSoftContract {
        /// Offending promise identifier.
        promise_id: String,
    },
    /// A mandatory `Hard` `Exclusive` requirement has zero or multiple matching offers.
    ExclusiveMismatch {
        /// Requirement promise identifier.
        promise_id: String,
        /// Required promise type.
        ptype: String,
        /// Required promise key.
        key: String,
        /// Actual count of matching offers found in scope.
        offer_count: usize,
    },
    /// A mandatory `Hard` `Broadcast` requirement has zero matching offers of `ptype`.
    MissingBroadcastProvider {
        /// Requirement promise identifier.
        promise_id: String,
        /// Required promise type.
        ptype: String,
    },
    /// Multiple `Exclusive` or `Partitioned` offers collided on the same `(ptype, key)`.
    DuplicateOffer {
        /// Colliding promise identifier.
        promise_id: String,
        /// Promise type.
        ptype: String,
        /// Colliding key.
        key: String,
        /// Number of duplicate offers.
        offer_count: usize,
    },
    /// Two or more `Partitioned` handlers matched the same offer tags.
    OverlappingPartitionHandlers {
        /// Offer promise identifier.
        promise_id: String,
        /// Promise type.
        ptype: String,
        /// Number of matching partition handlers.
        handler_count: usize,
    },
    /// A mandatory `Hard` `Partitioned` offer matched zero partition handlers in scope.
    UnhandledPartitionedOffer {
        /// Offer promise identifier.
        promise_id: String,
        /// Promise type.
        ptype: String,
        /// Offer key.
        key: String,
    },
    /// Total or critical-tier `Budgeted` demand exceeds available supply.
    BudgetExceeded {
        /// Promise type.
        ptype: String,
        /// Total available supply.
        supply: u64,
        /// Total demand across all consumers.
        total_demand: u64,
        /// Demand of priority-0 critical consumers.
        critical_demand: u64,
    },
}

fn count_matching_offers(ps: &[Promise], ptype: &str, key: &str) -> usize {
    ps.iter()
        .filter(|p| p.polarity == Polarity::Offer && p.ptype == ptype && p.key == key)
        .count()
}

fn count_matching_broadcast_offers(ps: &[Promise], ptype: &str) -> usize {
    ps.iter()
        .filter(|p| p.polarity == Polarity::Offer && p.ptype == ptype)
        .count()
}

/// Validates all `B3` scoped binding laws, returning structured diagnostics.
#[must_use]
pub fn validate_scope(ps: &[Promise]) -> Vec<BindingError> {
    let mut errors = Vec::new();
    for p in ps {
        if p.strength == Strength::Soft {
            let ok = p
                .soft_info
                .as_ref()
                .is_some_and(super::agency::SoftContract::is_complete);
            if !ok {
                errors.push(BindingError::IncompleteSoftContract {
                    promise_id: p.id.clone(),
                });
            }
        }
        match (p.cardinality, p.polarity, p.strength, p.mandatory) {
            (Cardinality::Exclusive, Polarity::Use, Strength::Hard, true) => {
                let count = count_matching_offers(ps, &p.ptype, &p.key);
                if count != 1 {
                    errors.push(BindingError::ExclusiveMismatch {
                        promise_id: p.id.clone(),
                        ptype: p.ptype.clone(),
                        key: p.key.clone(),
                        offer_count: count,
                    });
                }
            }
            (Cardinality::Exclusive, Polarity::Offer, _, _) => {
                let count = count_matching_offers(ps, &p.ptype, &p.key);
                if count > 1 {
                    errors.push(BindingError::DuplicateOffer {
                        promise_id: p.id.clone(),
                        ptype: p.ptype.clone(),
                        key: p.key.clone(),
                        offer_count: count,
                    });
                }
            }
            (Cardinality::Broadcast, Polarity::Use, Strength::Hard, true) => {
                if count_matching_broadcast_offers(ps, &p.ptype) == 0 {
                    errors.push(BindingError::MissingBroadcastProvider {
                        promise_id: p.id.clone(),
                        ptype: p.ptype.clone(),
                    });
                }
            }
            (Cardinality::Partitioned, Polarity::Offer, _, _) => {
                let offer_count = count_matching_offers(ps, &p.ptype, &p.key);
                if offer_count > 1 {
                    errors.push(BindingError::DuplicateOffer {
                        promise_id: p.id.clone(),
                        ptype: p.ptype.clone(),
                        key: p.key.clone(),
                        offer_count,
                    });
                }
                let handler_count = count_matching_partition_handlers(ps.iter(), &p.ptype, &p.tags);
                if handler_count > 1 {
                    errors.push(BindingError::OverlappingPartitionHandlers {
                        promise_id: p.id.clone(),
                        ptype: p.ptype.clone(),
                        handler_count,
                    });
                }
                if p.strength == Strength::Hard && p.mandatory && handler_count == 0 {
                    errors.push(BindingError::UnhandledPartitionedOffer {
                        promise_id: p.id.clone(),
                        ptype: p.ptype.clone(),
                        key: p.key.clone(),
                    });
                }
            }
            (Cardinality::Budgeted, Polarity::Use, _, _) => {
                let supply = total_budget_supply(ps.iter(), &p.ptype);
                let total_demand = total_budget_demand(ps.iter(), &p.ptype);
                let critical_demand = critical_budget_demand(ps.iter(), &p.ptype);
                if total_demand > supply || critical_demand > supply {
                    errors.push(BindingError::BudgetExceeded {
                        ptype: p.ptype.clone(),
                        supply,
                        total_demand,
                        critical_demand,
                    });
                }
            }
            _ => {}
        }
    }
    errors
}

/// Boolean scope validity predicate matching `Aky.Spec.isScopeValid`.
#[must_use]
pub fn is_scope_valid(ps: &[Promise]) -> bool {
    validate_scope(ps).is_empty()
}

/// Projects a Dressed Superagent's exterior `-b` promises into inbound `+b` supplies
/// inside its interior scope, mirroring `Aky.Spec.inboundFromExterior` 1:1.
#[must_use]
pub fn inbound_from_exterior(ext: &ExteriorSurface) -> Vec<Promise> {
    ext.promises
        .iter()
        .filter(|p| p.polarity == Polarity::Use)
        .map(|p| {
            let mut inbound = p.clone();
            inbound.id = format!("{}:inbound:{}", ext.agent_id, p.id);
            inbound.polarity = Polarity::Offer;
            inbound.stratum = 0;
            inbound
        })
        .collect()
}

/// Dual projection: synthesizes one non-overlapping outbound `-b` sink per `Partitioned`
/// `ptype` exported on `ext`, mirroring `Aky.Spec.outboundFromExterior` 1:1.
#[must_use]
pub fn outbound_from_exterior(ext: &ExteriorSurface, int_ps: &[Promise]) -> Vec<Promise> {
    let mut exported_ptypes: Vec<String> = Vec::new();
    for p in &ext.promises {
        if p.polarity == Polarity::Offer
            && p.cardinality == Cardinality::Partitioned
            && !exported_ptypes.contains(&p.ptype)
        {
            exported_ptypes.push(p.ptype.clone());
        }
    }
    exported_ptypes
        .into_iter()
        .map(|pt| {
            let not_handled = int_ps
                .iter()
                .filter(|h| {
                    h.polarity == Polarity::Use
                        && h.cardinality == Cardinality::Partitioned
                        && h.ptype == pt
                })
                .fold(AttrExpr::Any, |acc, h| {
                    AttrExpr::inter(acc, AttrExpr::compl(h.selector.clone()))
                });
            Promise {
                id: format!("{}:outbound:{pt}", ext.agent_id),
                ptype: pt.clone(),
                key: pt,
                polarity: Polarity::Use,
                strength: Strength::Hard,
                cardinality: Cardinality::Partitioned,
                mandatory: false,
                amount: 0,
                priority: 0,
                stratum: 0,
                tags: Vec::new(),
                selector: not_handled,
                soft_info: None,
            }
        })
        .collect()
}

/// Recursive Fractal Uniform Agent Tree Verifier (100% usage-agnostic TCB),
/// mirroring `Aky.Spec.checkAgentTree` 1:1.
#[must_use]
pub fn check_agent_tree(invs: &[PromiseInvariant], agent: &Agent) -> bool {
    match agent {
        Agent::Atomic { ext, .. } => all_invariants_hold(invs, &ext.promises),
        Agent::Superagent { ext, children } => {
            let int_ps: Vec<Promise> = sibling_operational_view(children)
                .into_iter()
                .flat_map(|surf| surf.promises.iter().cloned())
                .collect();
            let mut scope_ps = inbound_from_exterior(ext);
            scope_ps.extend(outbound_from_exterior(ext, &int_ps));
            scope_ps.extend(int_ps);
            all_invariants_hold(invs, &ext.promises)
                && superagent_conforms(ext, children)
                && is_scope_valid(&scope_ps)
                && children.iter().all(|c| check_agent_tree(invs, c))
        }
        Agent::Profile { members } => members.iter().all(|m| check_agent_tree(invs, m)),
    }
}

/// Validates strict acyclic multi-stratum monotonicity (`in_stratum < out_stratum`).
#[must_use]
pub fn validate_stratum_rules(rules: &[HandlerRule]) -> bool {
    rules.iter().all(|r| {
        r.in_stratum < r.out_stratum && r.emitted.iter().all(|p| p.stratum == r.out_stratum)
    })
}
