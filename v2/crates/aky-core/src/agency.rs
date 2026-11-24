//! Fractal Uniform Agency & `P-Explicit` Interior Conformance mirroring `Aky/Spec/Agency.lean`.

use serde::{Deserialize, Serialize};

use crate::attr_expr::AttrExpr;
use crate::state::{
    StateVolume, SubstrateCapabilities, is_backup_required, is_calm_safe, needs_local_persistence,
};

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
    /// Structurally or cryptographically enforced statically.
    Hard,
    /// Conditional runtime promise governed by the Conditional Promise Law.
    Soft,
}

/// `B3` scoped binding cardinality semantics.
#[derive(Clone, Copy, PartialEq, Eq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Cardinality {
    /// Strict `1:1` unique provider per key.
    Exclusive,
    /// Commutative `1:N` multi-observer binding.
    Broadcast,
    /// Disjoint `N:K` attribute-predicate routing.
    Partitioned,
    /// Conservation budget (`∑ demands ≤ supply` + critical priority tiering).
    Budgeted,
}

/// Mandatory completeness payload for `Soft` conditional promises (`+b | C`).
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SoftContract {
    /// Reference to the runtime condition (`-C`) such as `power:ac-plugged`.
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
    /// Whether an unsatisfied `Hard` Use is a build error.
    pub mandatory: bool,
    /// Quantitative resource amount for `Budgeted` promises.
    pub amount: u64,
    /// Priority tier (`0` = critical survival tier).
    pub priority: u64,
    /// Acyclic stratification rank.
    pub stratum: u64,
    /// Attribute tags carried by this promise for `Partitioned` matching.
    pub tags: Vec<String>,
    /// `AttrExpr` routing selector for `Partitioned` handlers.
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
    /// Factual entity attributes and substrate traits (`trait:*`) exported across `Σ`.
    pub attributes: Vec<String>,
    /// State volumes (`S2+`) exported across `Σ`.
    #[serde(default)]
    pub volumes: Vec<StateVolume>,
}

/// Recursive Fractal Uniform Agent (`ADR-0002`) with `P-Dual` (`ADR-0003`),
/// matching `Aky.Spec.Agent` 1:1.
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
    /// An exported `+b` offer has no backing interior child offer (lying boundary).
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
    /// Exterior budget demand plus internal supply fails to cover total child demand.
    UnderreportedBudget {
        /// Superagent identifier.
        superagent: String,
        /// Budget promise type (e.g., `"ram"`).
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
        /// Budget promise type (e.g., `"ram"`).
        ptype: String,
        /// Exterior critical-tier demand plus internal supply.
        ext_crit_plus_int_supply: u64,
        /// Sum of direct children's critical-tier demands.
        int_crit_demand: u64,
    },
    /// An exported exterior state volume has no matching backing child volume.
    UnbackedVolume {
        /// Superagent identifier.
        superagent: String,
        /// Unbacked volume identifier.
        volume_id: String,
    },
    /// A child volume requiring persistence or backup is neither discharged internally nor surfaced in `Π_ext`.
    LeakedVolume {
        /// Superagent identifier.
        superagent: String,
        /// Leaked volume identifier.
        volume_id: String,
    },
    /// A direct child volume violates Hellerstein's CALM monotonicity law.
    UnsafeVolume {
        /// Superagent identifier.
        superagent: String,
        /// Unsafe volume identifier.
        volume_id: String,
    },
}

/// Non-piercing exterior projection (`ADR-0006` C2: `Π_ext ⊥ Interior`),
/// mirroring `Aky.Spec.exteriorOf`.
#[must_use]
pub fn exterior_of(agent: &Agent) -> Vec<&ExteriorSurface> {
    match agent {
        Agent::Atomic { ext, .. } | Agent::Superagent { ext, .. } => vec![ext],
        Agent::Profile { members } => members.iter().flat_map(exterior_of).collect(),
    }
}

/// Operational view seen by external siblings inside a parent Superagent's scope,
/// mirroring `Aky.Spec.siblingOperationalView`.
#[must_use]
pub fn sibling_operational_view(children: &[Agent]) -> Vec<&ExteriorSurface> {
    children.iter().flat_map(exterior_of).collect()
}

/// Returns `true` iff `p` is a mandatory `Hard` Use promise.
#[must_use]
pub fn is_mandatory_hard_use(p: &Promise) -> bool {
    p.polarity == Polarity::Use && p.strength == Strength::Hard && p.mandatory
}

fn has_offer(ps: &[&Promise], ptype: &str, key: &str) -> bool {
    ps.iter()
        .any(|p| p.polarity == Polarity::Offer && p.ptype == ptype && p.key == key)
}

fn has_use(ps: &[Promise], ptype: &str, key: &str) -> bool {
    ps.iter()
        .any(|p| p.polarity == Polarity::Use && p.ptype == ptype && p.key == key)
}

fn is_internally_satisfied(int_ps: &[&Promise], p: &Promise) -> bool {
    match p.cardinality {
        Cardinality::Partitioned => int_ps.iter().any(|o| {
            o.polarity == Polarity::Offer
                && o.cardinality == Cardinality::Partitioned
                && o.ptype == p.ptype
                && p.selector.eval(&o.tags)
        }),
        Cardinality::Broadcast => int_ps
            .iter()
            .any(|o| o.polarity == Polarity::Offer && o.ptype == p.ptype),
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

/// Derives substrate capabilities strictly from direct children's exterior surfaces
/// (zero interior piercing), mirroring `Aky.Spec.deriveSubstrate`.
#[must_use]
pub fn derive_substrate(int_surfaces: &[&ExteriorSurface]) -> SubstrateCapabilities {
    let has_durable = int_surfaces
        .iter()
        .flat_map(|s| s.attributes.iter())
        .any(|a| a == "trait:durable");
    let has_ephemeral = int_surfaces
        .iter()
        .flat_map(|s| s.attributes.iter())
        .any(|a| a == "trait:ephemeral");
    let backup_count = int_surfaces
        .iter()
        .flat_map(|s| s.promises.iter())
        .filter(|p| p.polarity == Polarity::Offer && p.ptype == "backup:provider")
        .count();
    SubstrateCapabilities {
        provides_durable_storage: has_durable && !has_ephemeral,
        backup_provider_count: u64::try_from(backup_count).unwrap_or(u64::MAX),
    }
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

fn check_volume_conformance(
    ext: &ExteriorSurface,
    int_vols: &[&StateVolume],
    int_sub: &SubstrateCapabilities,
    errors: &mut Vec<BoundaryError>,
) {
    for ev in &ext.volumes {
        if !int_vols.iter().any(|v| v.id == ev.id) {
            errors.push(BoundaryError::UnbackedVolume {
                superagent: ext.agent_id.clone(),
                volume_id: ev.id.clone(),
            });
        }
    }
    for v in int_vols {
        if !is_calm_safe(&v.traits) {
            errors.push(BoundaryError::UnsafeVolume {
                superagent: ext.agent_id.clone(),
                volume_id: v.id.clone(),
            });
        }
        if needs_local_persistence(&v.traits)
            && !int_sub.provides_durable_storage
            && !ext
                .volumes
                .iter()
                .any(|ev| ev.id == v.id && needs_local_persistence(&ev.traits))
        {
            errors.push(BoundaryError::LeakedVolume {
                superagent: ext.agent_id.clone(),
                volume_id: v.id.clone(),
            });
        }
        if is_backup_required(&v.traits)
            && int_sub.backup_provider_count == 0
            && !ext
                .volumes
                .iter()
                .any(|ev| ev.id == v.id && is_backup_required(&ev.traits))
        {
            errors.push(BoundaryError::LeakedVolume {
                superagent: ext.agent_id.clone(),
                volume_id: v.id.clone(),
            });
        }
    }
}

/// Validates `P-Explicit` conformance of `ext` against its interior `children`
/// (observing strictly `exterior_of` of direct children — zero interior piercing!).
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
    let int_vols: Vec<&StateVolume> = int_surfaces.iter().flat_map(|c| c.volumes.iter()).collect();
    let int_sub = derive_substrate(&int_surfaces);

    let mut errors = Vec::new();
    for p in &ext.promises {
        if p.polarity == Polarity::Offer && !has_offer(&int_ps, &p.ptype, &p.key) {
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
            && !has_use(&ext.promises, &p.ptype, &p.key)
        {
            errors.push(BoundaryError::LeakedRequirement {
                superagent: ext.agent_id.clone(),
                ptype: p.ptype.clone(),
                key: p.key.clone(),
            });
        }
    }
    check_budget_conformance(ext, &int_ps, &mut errors);
    check_volume_conformance(ext, &int_vols, &int_sub, &mut errors);
    errors
}

/// Boolean conformance predicate matching `Aky.Spec.checkSuperagentConformance ... == []`.
#[must_use]
pub fn superagent_conforms(ext: &ExteriorSurface, children: &[Agent]) -> bool {
    validate_superagent_conformance(ext, children).is_empty()
}
