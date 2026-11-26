//! `B3` Scoped Binding, Cedar Structural Auth & Recursive Tree Verifier.
//!
//! Mirrors `Baugr/Engine/Binding.lean` 1:1 (`F-3` dead `HandlerRule` pruned,
//! `F-6` atomic principal auth + tight tag-matched outbound sinks).

use serde::{Deserialize, Serialize};

use crate::agency::{
    Agent, Cardinality, ExteriorSurface, Polarity, Promise, Strength,
    count_matching_broadcast_handlers, count_matching_partition_handlers, critical_budget_demand,
    sibling_operational_view, superagent_conforms, total_budget_demand, total_budget_supply,
};
use crate::attr_expr::{AttrExpr, exact_tags_expr};
use crate::authority::{AuthPolicy, Entity, is_authorized};
use crate::invariants::{PromiseInvariant, all_invariants_hold};

const fn default_use() -> Polarity {
    Polarity::Use
}

const fn default_any() -> AttrExpr {
    AttrExpr::Any
}

/// Usage-agnostic structural Cedar `L3+` authorization binding (zero domain strings in core!).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AuthBinding {
    /// Unique auth-binding rule identifier.
    pub id: String,
    /// Promise contract type (`τ`) governed by Cedar policies.
    pub ptype: String,
    /// Promise polarity governed by this binding (defaults to `Use`).
    #[serde(default = "default_use")]
    pub polarity: Polarity,
    /// Cedar action name evaluated for matching promises.
    pub action: String,
    /// `AttrExpr` selecting which Agent or Superagent boundaries act as principals.
    #[serde(default = "default_any")]
    pub principal_filter: AttrExpr,
}

/// Structured Cedar structural authorization diagnostic.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum AuthBindingError {
    /// A governed promise inside a principal Agent or Superagent was denied by Cedar `L3+`.
    UnauthorizedPromise {
        /// Identifier of the [`AuthBinding`] rule.
        binding_id: String,
        /// Principal Agent or Superagent identifier.
        principal_id: String,
        /// Denied action.
        action: String,
        /// Offending promise identifier.
        promise_id: String,
        /// Governed resource key.
        key: String,
    },
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
    /// A mandatory `Hard` `Broadcast` requirement has zero matching offers satisfying `selector`.
    MissingBroadcastProvider {
        /// Requirement promise identifier.
        promise_id: String,
        /// Required promise type.
        ptype: String,
    },
    /// A mandatory `Hard` `Broadcast` offer matched zero broadcast subscribers in scope.
    UnhandledBroadcastOffer {
        /// Offer promise identifier.
        promise_id: String,
        /// Promise type.
        ptype: String,
        /// Offer key.
        key: String,
    },
    /// Multiple `Exclusive`, `Broadcast`, or `Partitioned` offers collided on the same `(ptype, key)`.
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

fn count_matching_broadcast_offers(ps: &[Promise], ptype: &str, sel: &AttrExpr) -> usize {
    ps.iter()
        .filter(|p| p.polarity == Polarity::Offer && p.ptype == ptype && sel.eval(&p.tags))
        .count()
}

fn validate_partitioned_offer(ps: &[Promise], p: &Promise, errors: &mut Vec<BindingError>) {
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

fn validate_promise(ps: &[Promise], p: &Promise, errors: &mut Vec<BindingError>) {
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
            if count_matching_broadcast_offers(ps, &p.ptype, &p.selector) == 0 {
                errors.push(BindingError::MissingBroadcastProvider {
                    promise_id: p.id.clone(),
                    ptype: p.ptype.clone(),
                });
            }
        }
        (Cardinality::Broadcast, Polarity::Offer, _, _) => {
            let offer_count = count_matching_offers(ps, &p.ptype, &p.key);
            if offer_count > 1 {
                errors.push(BindingError::DuplicateOffer {
                    promise_id: p.id.clone(),
                    ptype: p.ptype.clone(),
                    key: p.key.clone(),
                    offer_count,
                });
            }
            let handler_count = count_matching_broadcast_handlers(ps.iter(), &p.ptype, &p.tags);
            if p.strength == Strength::Hard && p.mandatory && handler_count == 0 {
                errors.push(BindingError::UnhandledBroadcastOffer {
                    promise_id: p.id.clone(),
                    ptype: p.ptype.clone(),
                    key: p.key.clone(),
                });
            }
        }
        (Cardinality::Partitioned, Polarity::Offer, _, _) => {
            validate_partitioned_offer(ps, p, errors);
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

/// Validates all `B3` scoped binding laws, returning structured diagnostics.
#[must_use]
pub fn validate_scope(ps: &[Promise]) -> Vec<BindingError> {
    let mut errors = Vec::new();
    for p in ps {
        validate_promise(ps, p, &mut errors);
    }
    errors
}

/// Boolean scope validity predicate matching `Baugr.Engine.isScopeValid`.
#[must_use]
pub fn is_scope_valid(ps: &[Promise]) -> bool {
    validate_scope(ps).is_empty()
}

/// Validates structural Cedar `L3+` authorization rules for any principal Agent or Superagent,
/// mirroring `Baugr.Engine.validateScopeAuth` 1:1.
#[must_use]
pub fn validate_scope_auth(
    policies: &[AuthPolicy],
    bindings: &[AuthBinding],
    principal: &Entity,
    ps: &[Promise],
) -> Vec<AuthBindingError> {
    let mut errors = Vec::new();
    for ab in bindings {
        if !ab.principal_filter.eval(&principal.tags) {
            continue;
        }
        for p in ps {
            if p.ptype == ab.ptype && p.polarity == ab.polarity {
                let res = Entity {
                    id: p.key.clone(),
                    tags: p.tags.clone(),
                };
                if !is_authorized(policies, principal, &ab.action, &res) {
                    errors.push(AuthBindingError::UnauthorizedPromise {
                        binding_id: ab.id.clone(),
                        principal_id: principal.id.clone(),
                        action: ab.action.clone(),
                        promise_id: p.id.clone(),
                        key: p.key.clone(),
                    });
                }
            }
        }
    }
    errors
}

/// Boolean structural authorization predicate matching `Baugr.Engine.isScopeAuthValid`.
#[must_use]
pub fn is_scope_auth_valid(
    policies: &[AuthPolicy],
    bindings: &[AuthBinding],
    principal: &Entity,
    ps: &[Promise],
) -> bool {
    validate_scope_auth(policies, bindings, principal, ps).is_empty()
}

/// Projects a Dressed Superagent's exterior `-b` promises into inbound `+b` supplies
/// inside its interior scope, mirroring `Baugr.Engine.inboundFromExterior` 1:1.
#[must_use]
pub fn inbound_from_exterior(ext: &ExteriorSurface) -> Vec<Promise> {
    ext.promises
        .iter()
        .filter(|p| p.polarity == Polarity::Use)
        .map(|p| {
            let mut inbound = p.clone();
            inbound.id = format!("{}:inbound:{}", ext.agent_id, p.id);
            inbound.polarity = Polarity::Offer;
            inbound.mandatory = false;
            inbound.stratum = 0;
            inbound
        })
        .collect()
}

/// Disjunction of exact tag conjunctions across a slice of exported offers,
/// mirroring `Baugr.Engine.unionTagsExpr` 1:1 (`F-6`).
#[must_use]
pub fn union_tags_expr(ps: &[&Promise]) -> AttrExpr {
    ps.iter().fold(AttrExpr::NoneExpr, |acc, p| {
        AttrExpr::union(acc, exact_tags_expr(&p.tags))
    })
}

/// Tightened dual outbound projection mirroring `Baugr.Engine.outboundFromExterior` 1:1 (`F-6`).
#[must_use]
pub fn outbound_from_exterior(ext: &ExteriorSurface, int_ps: &[Promise]) -> Vec<Promise> {
    let mut part_ptypes: Vec<String> = Vec::new();
    let mut bcast_ptypes: Vec<String> = Vec::new();
    for p in &ext.promises {
        if p.polarity == Polarity::Offer {
            if p.cardinality == Cardinality::Partitioned && !part_ptypes.contains(&p.ptype) {
                part_ptypes.push(p.ptype.clone());
            } else if p.cardinality == Cardinality::Broadcast && !bcast_ptypes.contains(&p.ptype) {
                bcast_ptypes.push(p.ptype.clone());
            }
        }
    }
    let mut sinks: Vec<Promise> = part_ptypes
        .into_iter()
        .map(|pt| {
            let matching_exported: Vec<&Promise> = ext
                .promises
                .iter()
                .filter(|p| {
                    p.polarity == Polarity::Offer
                        && p.cardinality == Cardinality::Partitioned
                        && p.ptype == pt
                })
                .collect();
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
                id: format!("{}:outbound:part:{pt}", ext.agent_id),
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
                selector: AttrExpr::inter(not_handled, union_tags_expr(&matching_exported)),
                soft_info: None,
            }
        })
        .collect();
    sinks.extend(bcast_ptypes.into_iter().map(|pt| {
        let matching_exported: Vec<&Promise> = ext
            .promises
            .iter()
            .filter(|p| {
                p.polarity == Polarity::Offer
                    && p.cardinality == Cardinality::Broadcast
                    && p.ptype == pt
            })
            .collect();
        Promise {
            id: format!("{}:outbound:bcast:{pt}", ext.agent_id),
            ptype: pt.clone(),
            key: pt,
            polarity: Polarity::Use,
            strength: Strength::Hard,
            cardinality: Cardinality::Broadcast,
            mandatory: false,
            amount: 0,
            priority: 0,
            stratum: 0,
            tags: Vec::new(),
            selector: union_tags_expr(&matching_exported),
            soft_info: None,
        }
    }));
    sinks
}

/// Recursive Fractal Uniform Agent tree verifier mirroring `Baugr.Engine.checkAgentTree` 1:1
/// (including `F-6` Cedar principal auth on BOTH `Agent::Atomic` and `Agent::Superagent`!).
#[must_use]
pub fn check_agent_tree(
    invs: &[PromiseInvariant],
    policies: &[AuthPolicy],
    auth_bindings: &[AuthBinding],
    agent: &Agent,
) -> bool {
    match agent {
        Agent::Atomic { ext, .. } => {
            let principal = Entity {
                id: ext.agent_id.clone(),
                tags: ext.attributes.clone(),
            };
            all_invariants_hold(invs, &ext.promises)
                && is_scope_auth_valid(policies, auth_bindings, &principal, &ext.promises)
        }
        Agent::Superagent { ext, children } => {
            let int_ps: Vec<Promise> = sibling_operational_view(children)
                .into_iter()
                .flat_map(|s| s.promises.iter().cloned())
                .collect();
            let mut scope_ps = inbound_from_exterior(ext);
            scope_ps.extend(outbound_from_exterior(ext, &int_ps));
            scope_ps.extend(int_ps.iter().cloned());
            let principal = Entity {
                id: ext.agent_id.clone(),
                tags: ext.attributes.clone(),
            };
            all_invariants_hold(invs, &ext.promises)
                && superagent_conforms(ext, children)
                && is_scope_valid(&scope_ps)
                && is_scope_auth_valid(policies, auth_bindings, &principal, &int_ps)
                && children
                    .iter()
                    .all(|c| check_agent_tree(invs, policies, auth_bindings, c))
        }
        Agent::Profile { members } => members
            .iter()
            .all(|m| check_agent_tree(invs, policies, auth_bindings, m)),
    }
}
