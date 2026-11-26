//! Cedar `L3+` Authorization (`forbid`-overrides-`permit`, `Default-Deny`),
//! Biscuit Monotonic Attenuation, Combined Delegation, and Blast-Radius Calculation
//! mirroring `Baugr/Engine/Authority.lean`.

use serde::{Deserialize, Serialize};

use crate::attr_expr::AttrExpr;

/// Effect of an authorization policy statement.
#[derive(Clone, Copy, PartialEq, Eq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Effect {
    /// Grants authorization unless overridden by a matching `Forbid`.
    Permit,
    /// Unconditionally denies authorization (dominates all `Permit`s).
    Forbid,
}

/// Final authorization decision returned by `authorize`.
#[derive(Clone, Copy, PartialEq, Eq, Debug, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Decision {
    /// Access permitted.
    Allow,
    /// Access denied.
    Deny,
}

/// Cedar-style Boolean set-algebra policy over entity attributes.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AuthPolicy {
    /// Unique policy identifier (reported in `determining_policies`).
    pub id: String,
    /// `Permit` or `Forbid`.
    pub effect: Effect,
    /// Governed action name.
    pub action: String,
    /// Boolean attribute predicate selecting matching principals.
    pub principal_pred: AttrExpr,
    /// Boolean attribute predicate selecting matching resources.
    pub resource_pred: AttrExpr,
}

/// An addressable principal or resource carrying factual attribute tags.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Entity {
    /// Unique entity identifier.
    pub id: String,
    /// Factual attribute tags.
    pub tags: Vec<String>,
}

/// Structured Cedar authorization verdict including diagnostic `determining_policies`.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AuthResponse {
    /// Final `Allow` or `Deny` decision.
    pub decision: Decision,
    /// Exact policy IDs responsible for this decision (empty under default-deny).
    pub determining_policies: Vec<String>,
}

/// Offline-attenuatable Biscuit-style delegated capability token.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Capability {
    /// Identifier of the root policy or authority grant.
    pub root_policy_id: String,
    /// Action permitted by this capability.
    pub allowed_action: String,
    /// Conjunction of narrowing caveats (`AttrExpr`) appended monotonically.
    pub caveats: Vec<AttrExpr>,
}

impl Capability {
    /// Evaluates whether this capability permits `action` on `resource`.
    #[must_use]
    pub fn allows(&self, action: &str, resource: &Entity) -> bool {
        self.allowed_action == action && self.caveats.iter().all(|c| c.eval(&resource.tags))
    }

    /// Monotonically attenuates this capability by appending a narrowing caveat.
    #[must_use]
    pub fn attenuate(&self, caveat: AttrExpr) -> Self {
        let mut next = self.clone();
        next.caveats.push(caveat);
        next
    }
}

fn policy_matches(pol: &AuthPolicy, principal: &Entity, action: &str, resource: &Entity) -> bool {
    pol.action == action
        && pol.principal_pred.eval(&principal.tags)
        && pol.resource_pred.eval(&resource.tags)
}

/// Evaluates Cedar `Default-Deny` + `Forbid`-dominance authorization.
#[must_use]
pub fn authorize(
    policies: &[AuthPolicy],
    principal: &Entity,
    action: &str,
    resource: &Entity,
) -> AuthResponse {
    let permits: Vec<&AuthPolicy> = policies
        .iter()
        .filter(|p| p.effect == Effect::Permit && policy_matches(p, principal, action, resource))
        .collect();
    let forbids: Vec<&AuthPolicy> = policies
        .iter()
        .filter(|p| p.effect == Effect::Forbid && policy_matches(p, principal, action, resource))
        .collect();

    if !forbids.is_empty() {
        AuthResponse {
            decision: Decision::Deny,
            determining_policies: forbids.into_iter().map(|p| p.id.clone()).collect(),
        }
    } else if !permits.is_empty() {
        AuthResponse {
            decision: Decision::Allow,
            determining_policies: permits.into_iter().map(|p| p.id.clone()).collect(),
        }
    } else {
        AuthResponse {
            decision: Decision::Deny,
            determining_policies: Vec::new(),
        }
    }
}

/// Convenience boolean wrapper around [`authorize`].
#[must_use]
pub fn is_authorized(
    policies: &[AuthPolicy],
    principal: &Entity,
    action: &str,
    resource: &Entity,
) -> bool {
    authorize(policies, principal, action, resource).decision == Decision::Allow
}

/// Evaluates combined cross-boundary delegation (respects BOTH delegator policy AND delegatee `forbid`!).
#[must_use]
pub fn is_delegated_authorized(
    policies: &[AuthPolicy],
    delegator: &Entity,
    delegatee: &Entity,
    cap: &Capability,
    action: &str,
    resource: &Entity,
) -> bool {
    let delegatee_forbidden = policies
        .iter()
        .any(|p| p.effect == Effect::Forbid && policy_matches(p, delegatee, action, resource));
    is_authorized(policies, delegator, action, resource)
        && cap.allows(action, resource)
        && !delegatee_forbidden
}

/// Computes the exact sound-and-complete blast radius (all resources `principal` can access).
#[must_use]
pub fn blast_radius(
    policies: &[AuthPolicy],
    principal: &Entity,
    action: &str,
    resources: &[Entity],
) -> Vec<String> {
    resources
        .iter()
        .filter(|r| is_authorized(policies, principal, action, r))
        .map(|r| r.id.clone())
        .collect()
}
