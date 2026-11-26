//! Generic Declarative `AttrExpr` Promise Invariants (100% usage-agnostic)
//! mirroring `Baugr/Engine/Invariants.lean`.

use serde::{Deserialize, Serialize};

use crate::agency::Promise;
use crate::attr_expr::AttrExpr;

/// A declarative rule forbidding any promise matching `ptype` (or `"*"`) whose tags satisfy `forbid_tags`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PromiseInvariant {
    /// Unique invariant rule identifier.
    pub id: String,
    /// Target promise type (`"*"` applies to all promises).
    pub ptype: String,
    /// Boolean `AttrExpr` predicate over `promise.tags` whose match signals a violation.
    pub forbid_tags: AttrExpr,
}

/// Structured invariant violation diagnostic.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct InvariantError {
    /// Identifier of the violated [`PromiseInvariant`].
    pub invariant_id: String,
    /// Identifier of the offending [`Promise`].
    pub promise_id: String,
    /// Promise type of the offending [`Promise`].
    pub ptype: String,
}

/// Returns `true` iff `inv` applies to `p`.
#[must_use]
pub fn invariant_applies(inv: &PromiseInvariant, p: &Promise) -> bool {
    inv.ptype == "*" || inv.ptype == p.ptype
}

/// Validates all declarative invariants against `ps`, returning every violation.
#[must_use]
pub fn validate_invariants(invs: &[PromiseInvariant], ps: &[Promise]) -> Vec<InvariantError> {
    let mut errors = Vec::new();
    for inv in invs {
        for p in ps {
            if invariant_applies(inv, p) && inv.forbid_tags.eval(&p.tags) {
                errors.push(InvariantError {
                    invariant_id: inv.id.clone(),
                    promise_id: p.id.clone(),
                    ptype: p.ptype.clone(),
                });
            }
        }
    }
    errors
}

/// Boolean invariant predicate matching `Baugr.Engine.allInvariantsHold`.
#[must_use]
pub fn all_invariants_hold(invs: &[PromiseInvariant], ps: &[Promise]) -> bool {
    validate_invariants(invs, ps).is_empty()
}
