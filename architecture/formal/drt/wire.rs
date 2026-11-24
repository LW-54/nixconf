// Mirrors Nixconf/Oracle/Protocol.lean (Thin JSON Wire Boundary for AWS Cedar DRT)

use crate::engine::agency::{Cardinality, ExteriorSurface, Polarity, Promise, Strength};
use crate::engine::attr_expr::AttrExpr;
use crate::engine::authority::{AuthPolicy, AuthResponse, Capability, Decision, Effect, Entity};
use crate::engine::binding::HandlerRule;
use crate::engine::state::{StateVolume, SubstrateCapabilities};

#[derive(Clone, Debug)]
pub struct AuthQuery {
    pub principal: Entity,
    pub action: String,
    pub resource: Entity,
}

#[derive(Clone, Debug)]
pub struct DelegatedQuery {
    pub delegator: Entity,
    pub delegatee: Entity,
    pub capability: Capability,
    pub action: String,
    pub resource: Entity,
}

#[derive(Clone, Debug)]
pub struct ConformanceCheck {
    pub exterior: ExteriorSurface,
    pub children: Vec<ExteriorSurface>,
}

#[derive(Clone, Debug)]
pub struct TestCase {
    pub conformance: ConformanceCheck,
    pub promises: Vec<Promise>,
    pub stratum_rules: Vec<HandlerRule>,
    pub policies: Vec<AuthPolicy>,
    pub auth_queries: Vec<AuthQuery>,
    pub delegated_queries: Vec<DelegatedQuery>,
    pub blast_target: Entity,
    pub blast_action: String,
    pub all_resources: Vec<Entity>,
    pub substrate: SubstrateCapabilities,
    pub volumes: Vec<StateVolume>,
}

fn str_list_json(xs: &[String]) -> String {
    let items: Vec<String> = xs.iter().map(|s| format!(r#""{}""#, s)).collect();
    format!("[{}]", items.join(","))
}

pub fn attr_expr_json(e: &AttrExpr) -> String {
    match e {
        AttrExpr::Atom(t) => format!(r#"{{"kind":"atom","tag":"{}"}}"#, t),
        AttrExpr::Union(a, b) => format!(r#"{{"kind":"union","left":{},"right":{}}}"#, attr_expr_json(a), attr_expr_json(b)),
        AttrExpr::Inter(a, b) => format!(r#"{{"kind":"inter","left":{},"right":{}}}"#, attr_expr_json(a), attr_expr_json(b)),
        AttrExpr::Diff(a, b) => format!(r#"{{"kind":"diff","left":{},"right":{}}}"#, attr_expr_json(a), attr_expr_json(b)),
        AttrExpr::Compl(i) => format!(r#"{{"kind":"compl","inner":{}}}"#, attr_expr_json(i)),
        AttrExpr::Any => r#"{"kind":"any"}"#.to_string(),
        AttrExpr::NoneExpr => r#"{"kind":"none"}"#.to_string(),
    }
}

fn promise_json(p: &Promise) -> String {
    let pol = match p.polarity { Polarity::Offer => "offer", Polarity::Use => "use" };
    let st = match p.strength { Strength::Hard => "hard", Strength::Soft => "soft" };
    let card = match p.cardinality {
        Cardinality::Exclusive => "exclusive",
        Cardinality::Broadcast => "broadcast",
        Cardinality::Partitioned => "partitioned",
        Cardinality::Budgeted => "budgeted",
    };
    let si = match &p.soft_info {
        None => "null".to_string(),
        Some(sc) => format!(
            r#"{{"conditionRef":"{}","degradedMode":"{}","probeId":"{}"}}"#,
            sc.condition_ref, sc.degraded_mode, sc.probe_id
        ),
    };
    format!(
        r#"{{"id":"{}","ptype":"{}","key":"{}","polarity":"{}","strength":"{}","cardinality":"{}","mandatory":{},"amount":{},"priority":{},"stratum":{},"tags":{},"selector":{},"softInfo":{}}}"#,
        p.id, p.ptype, p.key, pol, st, card, p.mandatory, p.amount, p.priority, p.stratum,
        str_list_json(&p.tags), attr_expr_json(&p.selector), si
    )
}

fn exterior_json(ext: &ExteriorSurface) -> String {
    let ps: Vec<String> = ext.promises.iter().map(promise_json).collect();
    format!(
        r#"{{"agentId":"{}","promises":[{}],"attributes":{}}}"#,
        ext.agent_id, ps.join(","), str_list_json(&ext.attributes)
    )
}

fn rule_json(r: &HandlerRule) -> String {
    let ps: Vec<String> = r.emitted.iter().map(promise_json).collect();
    format!(
        r#"{{"id":"{}","inStratum":{},"outStratum":{},"emitted":[{}]}}"#,
        r.id, r.in_stratum, r.out_stratum, ps.join(",")
    )
}

fn entity_json(e: &Entity) -> String {
    format!(r#"{{"id":"{}","tags":{}}}"#, e.id, str_list_json(&e.tags))
}

fn policy_json(pol: &AuthPolicy) -> String {
    let eff = match pol.effect { Effect::Permit => "permit", Effect::Forbid => "forbid" };
    format!(
        r#"{{"id":"{}","effect":"{}","action":"{}","principalPred":{},"resourcePred":{}}}"#,
        pol.id, eff, pol.action, attr_expr_json(&pol.principal_pred), attr_expr_json(&pol.resource_pred)
    )
}

fn cap_json(cap: &Capability) -> String {
    let cs: Vec<String> = cap.caveats.iter().map(attr_expr_json).collect();
    format!(
        r#"{{"rootPolicyId":"{}","allowedAction":"{}","caveats":[{}]}}"#,
        cap.root_policy_id, cap.allowed_action, cs.join(",")
    )
}

fn volume_json(v: &StateVolume) -> String {
    format!(r#"{{"id":"{}","owner":"{}","traits":{}}}"#, v.id, v.owner, str_list_json(&v.traits))
}

pub fn testcase_json(tc: &TestCase) -> String {
    let children: Vec<String> = tc.conformance.children.iter().map(exterior_json).collect();
    let ps: Vec<String> = tc.promises.iter().map(promise_json).collect();
    let rules: Vec<String> = tc.stratum_rules.iter().map(rule_json).collect();
    let pols: Vec<String> = tc.policies.iter().map(policy_json).collect();
    let aqs: Vec<String> = tc.auth_queries.iter().map(|q| {
        format!(r#"{{"principal":{},"action":"{}","resource":{}}}"#, entity_json(&q.principal), q.action, entity_json(&q.resource))
    }).collect();
    let dqs: Vec<String> = tc.delegated_queries.iter().map(|q| {
        format!(
            r#"{{"delegator":{},"delegatee":{},"capability":{},"action":"{}","resource":{}}}"#,
            entity_json(&q.delegator), entity_json(&q.delegatee), cap_json(&q.capability), q.action, entity_json(&q.resource)
        )
    }).collect();
    let res: Vec<String> = tc.all_resources.iter().map(entity_json).collect();
    let vols: Vec<String> = tc.volumes.iter().map(volume_json).collect();
    format!(
        r#"{{"conformance":{{"exterior":{},"children":[{}]}},"promises":[{}],"stratumRules":[{}],"policies":[{}],"authQueries":[{}],"delegatedQueries":[{}],"blastTarget":{},"blastAction":"{}","allResources":[{}],"substrate":{{"providesDurableStorage":{},"backupProviderCount":{}}},"volumes":[{}]}}"#,
        exterior_json(&tc.conformance.exterior), children.join(","),
        ps.join(","), rules.join(","), pols.join(","), aqs.join(","), dqs.join(","),
        entity_json(&tc.blast_target), tc.blast_action, res.join(","),
        tc.substrate.provides_durable_storage, tc.substrate.backup_provider_count,
        vols.join(",")
    )
}

pub fn auth_response_json(r: &AuthResponse) -> String {
    let dec = match r.decision { Decision::Allow => "allow", Decision::Deny => "deny" };
    format!(r#"{{"decision":"{}","determiningPolicies":{}}}"#, dec, str_list_json(&r.determining_policies))
}
