//! Fractal Uniform Agency & `P-Explicit` Interior Conformance mirroring `Aky/Spec/Agency.lean`.

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
    /// Factual entity attributes for Cedar/Biscuit `L3+` evaluation.
    pub attributes: Vec<String>,
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

/// Validates `P-Explicit` conformance of `ext` against its interior `children`, returning all errors.
#[must_use]
pub fn validate_superagent_conformance(
    ext: &ExteriorSurface,
    children: &[ExteriorSurface],
) -> Vec<BoundaryError> {
    let int_ps: Vec<&Promise> = children.iter().flat_map(|c| c.promises.iter()).collect();
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
            && !has_offer(&int_ps, &p.ptype, &p.key)
            && !has_use(&ext.promises, &p.ptype, &p.key)
        {
            errors.push(BoundaryError::LeakedRequirement {
                superagent: ext.agent_id.clone(),
                ptype: p.ptype.clone(),
                key: p.key.clone(),
            });
        }
    }
    errors
}

/// Boolean conformance predicate matching `Aky.Spec.superagentConforms`.
#[must_use]
pub fn superagent_conforms(ext: &ExteriorSurface, children: &[ExteriorSurface]) -> bool {
    validate_superagent_conformance(ext, children).is_empty()
}
