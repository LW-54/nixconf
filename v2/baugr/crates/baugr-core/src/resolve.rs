//! Executable Operational Promise Resolver (`F-2`) mirroring `Baugr/Engine/Resolve.lean` 1:1.
//!
//! DRT-locked to Lean 4's `resolveAgentTree`, whose Type Soundness (Progress & Preservation)
//! is mechanically proved by `Baugr.Engine.Thm.valid_agent_tree_resolves_safely`!

use serde::{Deserialize, Serialize};

use crate::agency::{
    Agent, Cardinality, Polarity, Promise, Strength, critical_budget_demand,
    sibling_operational_view, total_budget_demand, total_budget_supply,
};
use crate::binding::{inbound_from_exterior, outbound_from_exterior};

/// A single resolved `-b` use bound to its matching `+b` offer IDs in scope.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ResolvedUse {
    /// Identifier of the `-b` use promise.
    pub use_id: String,
    /// Promise contract type (`τ`).
    pub ptype: String,
    /// Promise key.
    pub key: String,
    /// Matched `+b` offer IDs in scope order.
    pub offer_ids: Vec<String>,
}

/// Resolved bindings for one Dressed Superagent scope.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ResolvedScope {
    /// Superagent identifier.
    pub agent_id: String,
    /// All resolved `-b` uses inside this scope.
    pub bindings: Vec<ResolvedUse>,
}

/// Resolves a single promise `p` against full scope `all_ps`,
/// mirroring `Baugr.Engine.resolveUse` 1:1.
#[must_use]
pub fn resolve_use(all_ps: &[Promise], p: &Promise) -> Option<Option<ResolvedUse>> {
    if p.polarity == Polarity::Offer {
        return Some(None);
    }
    match p.cardinality {
        Cardinality::Exclusive => {
            let matched: Vec<String> = all_ps
                .iter()
                .filter(|o| o.polarity == Polarity::Offer && o.ptype == p.ptype && o.key == p.key)
                .map(|o| o.id.clone())
                .collect();
            if p.strength == Strength::Hard && p.mandatory && matched.len() != 1 {
                None
            } else {
                Some(Some(ResolvedUse {
                    use_id: p.id.clone(),
                    ptype: p.ptype.clone(),
                    key: p.key.clone(),
                    offer_ids: matched,
                }))
            }
        }
        Cardinality::Broadcast => {
            let matched: Vec<String> = all_ps
                .iter()
                .filter(|o| {
                    o.polarity == Polarity::Offer && o.ptype == p.ptype && p.selector.eval(&o.tags)
                })
                .map(|o| o.id.clone())
                .collect();
            if p.strength == Strength::Hard && p.mandatory && matched.is_empty() {
                None
            } else {
                Some(Some(ResolvedUse {
                    use_id: p.id.clone(),
                    ptype: p.ptype.clone(),
                    key: p.key.clone(),
                    offer_ids: matched,
                }))
            }
        }
        Cardinality::Partitioned => {
            let matched: Vec<String> = all_ps
                .iter()
                .filter(|o| {
                    o.polarity == Polarity::Offer
                        && o.cardinality == Cardinality::Partitioned
                        && o.ptype == p.ptype
                        && p.selector.eval(&o.tags)
                })
                .map(|o| o.id.clone())
                .collect();
            Some(Some(ResolvedUse {
                use_id: p.id.clone(),
                ptype: p.ptype.clone(),
                key: p.key.clone(),
                offer_ids: matched,
            }))
        }
        Cardinality::Budgeted => {
            let dem = total_budget_demand(all_ps.iter(), &p.ptype);
            let sup = total_budget_supply(all_ps.iter(), &p.ptype);
            let crit = critical_budget_demand(all_ps.iter(), &p.ptype);
            if dem > sup || crit > sup {
                None
            } else {
                let matched: Vec<String> = all_ps
                    .iter()
                    .filter(|o| {
                        o.polarity == Polarity::Offer
                            && o.cardinality == Cardinality::Budgeted
                            && o.ptype == p.ptype
                    })
                    .map(|o| o.id.clone())
                    .collect();
                Some(Some(ResolvedUse {
                    use_id: p.id.clone(),
                    ptype: p.ptype.clone(),
                    key: p.key.clone(),
                    offer_ids: matched,
                }))
            }
        }
    }
}

/// Resolves every promise in `ps`, mirroring `Baugr.Engine.resolveScope` 1:1.
#[must_use]
pub fn resolve_scope(ps: &[Promise]) -> Option<Vec<ResolvedUse>> {
    let mut out = Vec::new();
    for p in ps {
        if let Some(ru) = resolve_use(ps, p)? {
            out.push(ru);
        }
    }
    Some(out)
}

/// Recursively resolves every Superagent scope in an `Agent` tree without piercing,
/// mirroring `Baugr.Engine.resolveAgentTree` 1:1.
#[must_use]
pub fn resolve_agent_tree(agent: &Agent) -> Option<Vec<ResolvedScope>> {
    match agent {
        Agent::Atomic { .. } => Some(Vec::new()),
        Agent::Superagent { ext, children } => {
            let int_ps: Vec<Promise> = sibling_operational_view(children)
                .into_iter()
                .flat_map(|s| s.promises.iter().cloned())
                .collect();
            let mut scope_ps = inbound_from_exterior(ext);
            scope_ps.extend(outbound_from_exterior(ext, &int_ps));
            scope_ps.extend(int_ps);
            let bindings = resolve_scope(&scope_ps)?;
            let mut child_scopes = Vec::new();
            for ch in children {
                child_scopes.extend(resolve_agent_tree(ch)?);
            }
            let mut scopes = Vec::with_capacity(child_scopes.len().saturating_add(1));
            scopes.push(ResolvedScope {
                agent_id: ext.agent_id.clone(),
                bindings,
            });
            scopes.extend(child_scopes);
            Some(scopes)
        }
        Agent::Profile { members } => {
            let mut scopes = Vec::new();
            for m in members {
                scopes.extend(resolve_agent_tree(m)?);
            }
            Some(scopes)
        }
    }
}
