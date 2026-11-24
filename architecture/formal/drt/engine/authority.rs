// Mirrors Nixconf/Spec/Authority.lean (Cedar AuthResponse + Biscuit Attenuation + Combined Delegation)

use super::attr_expr::AttrExpr;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Effect { Permit, Forbid }

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Decision { Allow, Deny }

#[derive(Clone, Debug)]
pub struct AuthPolicy {
    pub id: String,
    pub effect: Effect,
    pub action: String,
    pub principal_pred: AttrExpr,
    pub resource_pred: AttrExpr,
}

#[derive(Clone, Debug)]
pub struct Entity {
    pub id: String,
    pub tags: Vec<String>,
}

#[derive(Clone, Debug)]
pub struct AuthResponse {
    pub decision: Decision,
    pub determining_policies: Vec<String>,
}

#[derive(Clone, Debug)]
pub struct Capability {
    pub root_policy_id: String,
    pub allowed_action: String,
    pub caveats: Vec<AttrExpr>,
}

impl Capability {
    pub fn allows(&self, action: &str, resource: &Entity) -> bool {
        self.allowed_action == action && self.caveats.iter().all(|c| c.eval(&resource.tags))
    }
}

fn policy_matches(pol: &AuthPolicy, principal: &Entity, action: &str, resource: &Entity) -> bool {
    pol.action == action
        && pol.principal_pred.eval(&principal.tags)
        && pol.resource_pred.eval(&resource.tags)
}

pub fn authorize(policies: &[AuthPolicy], principal: &Entity, action: &str, resource: &Entity) -> AuthResponse {
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
            determining_policies: vec![],
        }
    }
}

pub fn is_authorized(policies: &[AuthPolicy], principal: &Entity, action: &str, resource: &Entity) -> bool {
    authorize(policies, principal, action, resource).decision == Decision::Allow
}

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
    is_authorized(policies, delegator, action, resource) && cap.allows(action, resource) && !delegatee_forbidden
}

pub fn blast_radius(policies: &[AuthPolicy], principal: &Entity, action: &str, resources: &[Entity]) -> Vec<String> {
    resources
        .iter()
        .filter(|r| is_authorized(policies, principal, action, r))
        .map(|r| r.id.clone())
        .collect()
}
