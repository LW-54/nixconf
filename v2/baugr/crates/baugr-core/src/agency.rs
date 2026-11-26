//! Fractal Uniform Agency & `P-Explicit` Interior Conformance (100% usage-agnostic)
//! mirroring `Baugr/Theory/Promise.lean` and `Baugr/Engine/Conformance.lean`.

use serde::{Deserialize, Serialize};

use crate::attr_expr::AttrExpr;

/// Direction of a Promise Theory statement (`+b` Offer vs. `-b` Use).
#[derive(Clone, Copy, PartialEq, Eq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Polarity {
    /// Positive promise (`+b`): capability offered by the promiser.
    Offer,
    /// Negative promise (`-b`): capability accepted/required by the promiser.
    Use,
}

/// Enforcement strength of a promise (`Hard` vs. conditional `Soft`).
#[derive(Clone, Copy, PartialEq, Eq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Strength {
    /// Statically or cryptographically enforced invariant.
    Hard,
    /// Conditional runtime promise governed by the Conditional Promise Law.
    Soft,
}

/// `B3` scoped binding cardinality semantics.
#[derive(Clone, Copy, PartialEq, Eq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Cardinality {
    /// Strict `1:1` unique provider per `(ptype, key)`.
    Exclusive,
    /// Commutative `M:N` pub-sub fan-out with `AttrExpr` filtering.
    Broadcast,
    /// Disjoint `N:K` attribute-predicate routing (`mandatory` offer requires `== 1` handler).
    Partitioned,
    /// Conservation budget (`∑ demands ≤ supply` + critical priority tiering).
    Budgeted,
}

/// Mandatory completeness payload for `Soft` conditional promises (`+b | C`).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SoftContract {
    /// Reference to the runtime condition (`-C`).
    pub condition_ref: String,
    /// Bounded degraded invariant when the condition is false.
    pub degraded_mode: String,
    /// Identifier of the tri-purpose assessment probe (`α`).
    pub probe_id: String,
}

impl SoftContract {
    /// Returns `true` iff all three Conditional Promise Law fields are non-empty.
    #[must_use]
    pub const fn is_complete(&self) -> bool {
        !self.condition_ref.is_empty()
            && !self.degraded_mode.is_empty()
            && !self.probe_id.is_empty()
    }
}

/// A typed Promise Theory statement inside a scope.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Promise {
    /// Unique identifier of this promise instance.
    pub id: String,
    /// Promise contract type (`τ`).
    pub ptype: String,
    /// Commutative aggregation key.
    pub key: String,
    /// Offer (`+b`) or Use (`-b`).
    pub polarity: Polarity,
    /// Static `Hard` or conditional `Soft`.
    pub strength: Strength,
    /// `B3` binding cardinality.
    pub cardinality: Cardinality,
    /// Whether an unbound `Hard` promise fails verification in a closed scope.
    pub mandatory: bool,
    /// Quantitative resource amount for `Budgeted` promises.
    pub amount: u64,
    /// Priority tier (`0` = critical survival tier).
    pub priority: u64,
    /// Acyclic stratification rank.
    pub stratum: u64,
    /// Attribute tags carried by this promise for routing & declarative invariants.
    pub tags: Vec<String>,
    /// `AttrExpr` routing selector for consumers.
    pub selector: AttrExpr,
    /// Required metadata when `strength == Strength::Soft`.
    pub soft_info: Option<SoftContract>,
}

/// Exterior boundary surface (`Π_ext`) of an Agent or Dressed Superagent.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ExteriorSurface {
    /// Unique agent identifier.
    pub agent_id: String,
    /// Promises exported across the boundary `Σ`.
    pub promises: Vec<Promise>,
    /// Factual entity attributes exported across `Σ`.
    pub attributes: Vec<String>,
}

/// Recursive Fractal Uniform Agent matching `Baugr.Theory.Agent` 1:1.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(tag = "kind", rename_all = "lowercase")]
pub enum Agent {
    /// Atomic agent with opaque interior content hash.
    Atomic {
        /// Exterior boundary surface (`Π_ext`).
        ext: ExteriorSurface,
        /// Content hash of the opaque interior.
        #[serde(rename = "interiorHash")]
        interior_hash: String,
    },
    /// Dressed Superagent with opaque encapsulation boundary `Σ`.
    Superagent {
        /// Exterior boundary surface (`Π_ext`).
        ext: ExteriorSurface,
        /// Direct contained child agents (`CONTAINS`).
        children: Vec<Self>,
    },
    /// Transparent reusable Profile (`P-Dual`) flattened into the enclosing scope.
    Profile {
        /// Sibling agent members.
        members: Vec<Self>,
    },
}

/// Structured diagnostic returned by `P-Explicit` interior conformance checking.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum BoundaryError {
    /// An exported `+b` offer has no backing interior child offer (or alters tags).
    UnbackedOffer {
        /// Superagent identifier.
        superagent: String,
        /// Unbacked promise type.
        ptype: String,
        /// Unbacked promise key.
        key: String,
    },
    /// A mandatory interior `-b` requirement is neither satisfied internally nor declared in `Π_ext`.
    LeakedRequirement {
        /// Superagent identifier.
        superagent: String,
        /// Leaked promise type.
        ptype: String,
        /// Leaked promise key.
        key: String,
    },
    /// A mandatory interior `Partitioned`/`Broadcast` `+b` offer has 0 interior handlers and is not exported.
    DroppedMandatoryOffer {
        /// Superagent identifier.
        superagent: String,
        /// Dropped promise type.
        ptype: String,
        /// Dropped promise key.
        key: String,
    },
    /// Exterior budget demand plus internal supply fails to cover total child demand.
    UnderreportedBudget {
        /// Superagent identifier.
        superagent: String,
        /// Budget promise type.
        ptype: String,
        /// Exterior declared demand plus internal supply.
        ext_plus_int_supply: u64,
        /// Sum of direct children's exterior demands.
        int_demand: u64,
    },
    /// Exterior critical-tier budget plus internal supply fails to cover critical child demand.
    UnderreportedCriticalBudget {
        /// Superagent identifier.
        superagent: String,
        /// Budget promise type.
        ptype: String,
        /// Exterior critical-tier demand plus internal supply.
        ext_crit_plus_int_supply: u64,
        /// Sum of direct children's critical-tier demands.
        int_crit_demand: u64,
    },
}

/// Non-piercing exterior projection (`Π_ext ⊥ Interior`), mirroring `Baugr.Theory.exteriorOf`.
#[must_use]
pub fn exterior_of(agent: &Agent) -> Vec<&ExteriorSurface> {
    match agent {
        Agent::Atomic { ext, .. } | Agent::Superagent { ext, .. } => vec![ext],
        Agent::Profile { members } => members.iter().flat_map(exterior_of).collect(),
    }
}

/// Operational view seen by external siblings inside a parent Superagent's scope.
#[must_use]
pub fn sibling_operational_view(children: &[Agent]) -> Vec<&ExteriorSurface> {
    children.iter().flat_map(exterior_of).collect()
}

/// Read-only `CONTAINS` agent ID traversal mirroring `Baugr.Theory.epistemicZoomIds`.
#[must_use]
pub fn epistemic_zoom_ids(agent: &Agent) -> Vec<String> {
    match agent {
        Agent::Atomic { ext, .. } => vec![ext.agent_id.clone()],
        Agent::Superagent { ext, children } => {
            let mut ids = vec![ext.agent_id.clone()];
            for ch in children {
                ids.extend(epistemic_zoom_ids(ch));
            }
            ids
        }
        Agent::Profile { members } => members.iter().flat_map(epistemic_zoom_ids).collect(),
    }
}

/// Returns `true` iff `p` is a mandatory `Hard` Use promise.
#[must_use]
pub fn is_mandatory_hard_use(p: &Promise) -> bool {
    p.polarity == Polarity::Use && p.strength == Strength::Hard && p.mandatory
}

/// Returns `true` iff `p` is a mandatory `Hard` `Partitioned` Offer promise.
#[must_use]
pub fn is_mandatory_hard_partitioned_offer(p: &Promise) -> bool {
    p.polarity == Polarity::Offer
        && p.strength == Strength::Hard
        && p.cardinality == Cardinality::Partitioned
        && p.mandatory
}

/// Returns `true` iff `p` is a mandatory `Hard` `Broadcast` Offer promise.
#[must_use]
pub fn is_mandatory_hard_broadcast_offer(p: &Promise) -> bool {
    p.polarity == Polarity::Offer
        && p.strength == Strength::Hard
        && p.cardinality == Cardinality::Broadcast
        && p.mandatory
}

/// Set equality over tag slices, mirroring `Baugr.Engine.sameTagSet`.
#[must_use]
pub fn same_tag_set(xs: &[String], ys: &[String]) -> bool {
    xs.iter().all(|x| ys.iter().any(|y| y == x)) && ys.iter().all(|y| xs.iter().any(|x| x == y))
}

fn has_offer(ps: &[&Promise], ptype: &str, key: &str) -> bool {
    ps.iter()
        .any(|p| p.polarity == Polarity::Offer && p.ptype == ptype && p.key == key)
}

fn has_backing_offer(ps: &[&Promise], ext_offer: &Promise) -> bool {
    if matches!(
        ext_offer.cardinality,
        Cardinality::Partitioned | Cardinality::Broadcast
    ) {
        ps.iter().any(|o| {
            o.polarity == Polarity::Offer
                && o.cardinality == ext_offer.cardinality
                && o.ptype == ext_offer.ptype
                && o.key == ext_offer.key
                && same_tag_set(&o.tags, &ext_offer.tags)
        })
    } else {
        has_offer(ps, &ext_offer.ptype, &ext_offer.key)
    }
}

fn has_backing_use(ps: &[Promise], int_use: &Promise) -> bool {
    ps.iter().any(|u| {
        u.polarity == Polarity::Use
            && u.ptype == int_use.ptype
            && u.key == int_use.key
            && (int_use.tags.is_empty() || same_tag_set(&u.tags, &int_use.tags))
    })
}

/// Counts `Partitioned` consumers whose `AttrExpr` selector matches `offer_tags`.
#[must_use]
pub fn count_matching_partition_handlers<'a>(
    ps: impl IntoIterator<Item = &'a Promise>,
    ptype: &str,
    offer_tags: &[String],
) -> usize {
    ps.into_iter()
        .filter(|h| {
            h.polarity == Polarity::Use
                && h.cardinality == Cardinality::Partitioned
                && h.ptype == ptype
                && h.selector.eval(offer_tags)
        })
        .count()
}

/// Counts `Broadcast` subscribers whose `AttrExpr` selector matches `offer_tags`.
#[must_use]
pub fn count_matching_broadcast_handlers<'a>(
    ps: impl IntoIterator<Item = &'a Promise>,
    ptype: &str,
    offer_tags: &[String],
) -> usize {
    ps.into_iter()
        .filter(|h| {
            h.polarity == Polarity::Use
                && h.cardinality == Cardinality::Broadcast
                && h.ptype == ptype
                && h.selector.eval(offer_tags)
        })
        .count()
}

/// Returns `true` iff use promise `p` is satisfied by offers inside `int_ps`.
#[must_use]
pub fn is_internally_satisfied(int_ps: &[&Promise], p: &Promise) -> bool {
    match p.cardinality {
        Cardinality::Partitioned => int_ps.iter().any(|o| {
            o.polarity == Polarity::Offer
                && o.cardinality == Cardinality::Partitioned
                && o.ptype == p.ptype
                && p.selector.eval(&o.tags)
        }),
        Cardinality::Broadcast => int_ps.iter().any(|o| {
            o.polarity == Polarity::Offer && o.ptype == p.ptype && p.selector.eval(&o.tags)
        }),
        Cardinality::Exclusive | Cardinality::Budgeted => has_offer(int_ps, &p.ptype, &p.key),
    }
}

/// Sum of `Budgeted` `+b` supply for `ptype`.
#[must_use]
pub fn total_budget_supply<'a>(ps: impl IntoIterator<Item = &'a Promise>, ptype: &str) -> u64 {
    ps.into_iter()
        .filter(|p| {
            p.polarity == Polarity::Offer
                && p.cardinality == Cardinality::Budgeted
                && p.ptype == ptype
        })
        .fold(0_u64, |acc, p| acc.saturating_add(p.amount))
}

/// Sum of `Budgeted` `-b` demand for `ptype`.
#[must_use]
pub fn total_budget_demand<'a>(ps: impl IntoIterator<Item = &'a Promise>, ptype: &str) -> u64 {
    ps.into_iter()
        .filter(|p| {
            p.polarity == Polarity::Use
                && p.cardinality == Cardinality::Budgeted
                && p.ptype == ptype
        })
        .fold(0_u64, |acc, p| acc.saturating_add(p.amount))
}

/// Sum of critical-tier (`priority == 0`) `Budgeted` `-b` demand for `ptype`.
#[must_use]
pub fn critical_budget_demand<'a>(ps: impl IntoIterator<Item = &'a Promise>, ptype: &str) -> u64 {
    ps.into_iter()
        .filter(|p| {
            p.polarity == Polarity::Use
                && p.cardinality == Cardinality::Budgeted
                && p.ptype == ptype
                && p.priority == 0
        })
        .fold(0_u64, |acc, p| acc.saturating_add(p.amount))
}

fn check_budget_conformance(
    ext: &ExteriorSurface,
    int_ps: &[&Promise],
    errors: &mut Vec<BoundaryError>,
) {
    for p in int_ps {
        if p.polarity == Polarity::Use && p.cardinality == Cardinality::Budgeted {
            let int_sup = total_budget_supply(int_ps.iter().copied(), &p.ptype);
            let int_dem = total_budget_demand(int_ps.iter().copied(), &p.ptype);
            let int_crit = critical_budget_demand(int_ps.iter().copied(), &p.ptype);
            let ext_dem = total_budget_demand(ext.promises.iter(), &p.ptype);
            let ext_crit = critical_budget_demand(ext.promises.iter(), &p.ptype);
            let total_cov = ext_dem.saturating_add(int_sup);
            if total_cov < int_dem {
                errors.push(BoundaryError::UnderreportedBudget {
                    superagent: ext.agent_id.clone(),
                    ptype: p.ptype.clone(),
                    ext_plus_int_supply: total_cov,
                    int_demand: int_dem,
                });
            }
            let crit_cov = ext_crit.saturating_add(int_sup);
            if crit_cov < int_crit {
                errors.push(BoundaryError::UnderreportedCriticalBudget {
                    superagent: ext.agent_id.clone(),
                    ptype: p.ptype.clone(),
                    ext_crit_plus_int_supply: crit_cov,
                    int_crit_demand: int_crit,
                });
            }
        }
    }
}

/// Validates `P-Explicit` conformance of `ext` against its interior `children`.
#[must_use]
pub fn validate_superagent_conformance(
    ext: &ExteriorSurface,
    children: &[Agent],
) -> Vec<BoundaryError> {
    let int_surfaces = sibling_operational_view(children);
    let int_ps: Vec<&Promise> = int_surfaces
        .iter()
        .flat_map(|c| c.promises.iter())
        .collect();
    let ext_ps_refs: Vec<&Promise> = ext.promises.iter().collect();

    let mut errors = Vec::new();
    for p in &ext.promises {
        if p.polarity == Polarity::Offer && !has_backing_offer(&int_ps, p) {
            errors.push(BoundaryError::UnbackedOffer {
                superagent: ext.agent_id.clone(),
                ptype: p.ptype.clone(),
                key: p.key.clone(),
            });
        }
    }
    for p in &int_ps {
        if is_mandatory_hard_use(p)
            && !is_internally_satisfied(&int_ps, p)
            && !has_backing_use(&ext.promises, p)
        {
            errors.push(BoundaryError::LeakedRequirement {
                superagent: ext.agent_id.clone(),
                ptype: p.ptype.clone(),
                key: p.key.clone(),
            });
        }
        let dropped_part = is_mandatory_hard_partitioned_offer(p)
            && count_matching_partition_handlers(int_ps.iter().copied(), &p.ptype, &p.tags) == 0;
        let dropped_bcast = is_mandatory_hard_broadcast_offer(p)
            && count_matching_broadcast_handlers(int_ps.iter().copied(), &p.ptype, &p.tags) == 0;
        if (dropped_part || dropped_bcast) && !has_backing_offer(&ext_ps_refs, p) {
            errors.push(BoundaryError::DroppedMandatoryOffer {
                superagent: ext.agent_id.clone(),
                ptype: p.ptype.clone(),
                key: p.key.clone(),
            });
        }
    }
    check_budget_conformance(ext, &int_ps, &mut errors);
    errors
}

/// Boolean conformance predicate matching `Baugr.Engine.checkSuperagentConformance ... == []`.
#[must_use]
pub fn superagent_conforms(ext: &ExteriorSurface, children: &[Agent]) -> bool {
    validate_superagent_conformance(ext, children).is_empty()
}

/// Scope-emergent portability check matching `Baugr.Engine.canComposeInScope`.
#[must_use]
pub fn can_compose_in_scope(ambient: &ExteriorSurface, ext: &ExteriorSurface) -> bool {
    let amb_refs: Vec<&Promise> = ambient.promises.iter().collect();
    ext.promises
        .iter()
        .all(|p| !is_mandatory_hard_use(p) || is_internally_satisfied(&amb_refs, p))
}
