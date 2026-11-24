// Deterministic DRT Test Generator & Concrete nixconf Fleet Regression Scenarios
// Exercises ALL 6 closed gaps: P-Explicit conformance, AttrExpr partitioned routing,
// priority-tier RAM budgets, multi-stratum rules, combined delegator+delegatee forbid,
// and open AttrExpr state traits + CALM.

use crate::engine::agency::{Cardinality, ExteriorSurface, Polarity, Promise, SoftContract, Strength};
use crate::engine::attr_expr::AttrExpr;
use crate::engine::authority::{AuthPolicy, Capability, Effect, Entity};
use crate::engine::binding::HandlerRule;
use crate::engine::state::{StateVolume, SubstrateCapabilities};
use crate::wire::{AuthQuery, ConformanceCheck, DelegatedQuery, TestCase};

pub struct Rng(pub u64);
impl Rng {
    fn next(&mut self) -> u64 {
        let mut x = self.0;
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        self.0 = x;
        x
    }
    fn bool(&mut self) -> bool { (self.next() & 1) == 1 }
    fn range(&mut self, n: u64) -> u64 { self.next() % n }
    fn pick<'a, T>(&mut self, xs: &'a [T]) -> &'a T { &xs[(self.next() as usize) % xs.len()] }
}

const AUTH_TAGS: &[&str] = &[
    "group:edge", "group:workstation", "posture:disk-encrypted",
    "posture:roaming-stealable", "posture:ephemeral", "actor:ai-agent",
    "tag:prod-core", "tag:personal", "visibility:public", "visibility:mesh",
];
const STATE_TAGS: &[&str] = &[
    "survives-reboot", "reconstructible", "monotonic",
    "multi-writer", "single-auth-writer", "backup-required", "external-owned",
];
const PTYPES: &[&str] = &["secret", "http-endpoint", "ram-mb", "metrics"];
const KEYS: &[&str] = &["k1", "k2", "k3"];
const ACTIONS: &[&str] = &["decrypt", "git-push", "remote-build"];

fn gen_expr(rng: &mut Rng, depth: u32) -> AttrExpr {
    if depth == 0 {
        return match rng.range(3) {
            0 => AttrExpr::Atom((*rng.pick(AUTH_TAGS)).to_string()),
            1 => AttrExpr::Any,
            _ => AttrExpr::NoneExpr,
        };
    }
    match rng.range(6) {
        0 => AttrExpr::Atom((*rng.pick(AUTH_TAGS)).to_string()),
        1 => AttrExpr::Union(Box::new(gen_expr(rng, depth - 1)), Box::new(gen_expr(rng, depth - 1))),
        2 => AttrExpr::Inter(Box::new(gen_expr(rng, depth - 1)), Box::new(gen_expr(rng, depth - 1))),
        3 => AttrExpr::Diff(Box::new(gen_expr(rng, depth - 1)), Box::new(gen_expr(rng, depth - 1))),
        4 => AttrExpr::Compl(Box::new(gen_expr(rng, depth - 1))),
        _ => AttrExpr::Any,
    }
}

fn gen_subset(rng: &mut Rng, universe: &[&str]) -> Vec<String> {
    universe.iter().filter(|_| rng.bool()).map(|s| s.to_string()).collect()
}

fn gen_promise(rng: &mut Rng, id: String, stratum: u64) -> Promise {
    let strength = if rng.bool() { Strength::Hard } else { Strength::Soft };
    let soft_info = if strength == Strength::Soft && rng.range(4) != 0 {
        Some(SoftContract {
            condition_ref: if rng.range(5) == 0 { "".into() } else { "mesh-up".into() },
            degraded_mode: "pause-sync".into(),
            probe_id: "probe-1".into(),
        })
    } else {
        None
    };
    Promise {
        id,
        ptype: (*rng.pick(PTYPES)).to_string(),
        key: (*rng.pick(KEYS)).to_string(),
        polarity: if rng.bool() { Polarity::Offer } else { Polarity::Use },
        strength,
        cardinality: match rng.range(4) {
            0 => Cardinality::Exclusive,
            1 => Cardinality::Broadcast,
            2 => Cardinality::Partitioned,
            _ => Cardinality::Budgeted,
        },
        mandatory: rng.bool(),
        amount: rng.range(4000),
        priority: rng.range(4),
        stratum,
        tags: gen_subset(rng, AUTH_TAGS),
        selector: gen_expr(rng, 1),
        soft_info,
    }
}

pub fn gen_random_case(rng: &mut Rng, idx: usize) -> TestCase {
    let n_p = (rng.range(6) + 1) as usize;
    let promises: Vec<Promise> = (0..n_p).map(|i| gen_promise(rng, format!("p{}_{}", idx, i), 0)).collect();

    let ext_promises: Vec<Promise> = (0..2).map(|i| gen_promise(rng, format!("ext{}_{}", idx, i), 0)).collect();
    let child_promises: Vec<Promise> = (0..3).map(|i| gen_promise(rng, format!("ch{}_{}", idx, i), 0)).collect();
    let conformance = ConformanceCheck {
        exterior: ExteriorSurface { agent_id: "obs".into(), promises: ext_promises, attributes: vec![] },
        children: vec![ExteriorSurface { agent_id: "child0".into(), promises: child_promises, attributes: vec![] }],
    };

    let n_rules = (rng.range(3) + 1) as usize;
    let stratum_rules: Vec<HandlerRule> = (0..n_rules).map(|i| {
        let in_s = rng.range(3);
        let out_s = rng.range(4);
        let emit_s = if rng.range(4) == 0 { in_s } else { out_s };
        HandlerRule {
            id: format!("r{}", i),
            in_stratum: in_s,
            out_stratum: out_s,
            emitted: vec![gen_promise(rng, format!("em{}_{}", idx, i), emit_s)],
        }
    }).collect();

    let n_pols = (rng.range(6) + 1) as usize;
    let policies: Vec<AuthPolicy> = (0..n_pols).map(|i| AuthPolicy {
        id: format!("pol{}", i),
        effect: if rng.range(3) == 0 { Effect::Forbid } else { Effect::Permit },
        action: (*rng.pick(ACTIONS)).to_string(),
        principal_pred: gen_expr(rng, 2),
        resource_pred: gen_expr(rng, 2),
    }).collect();

    let all_resources: Vec<Entity> = (0..4).map(|i| Entity {
        id: format!("res{}", i),
        tags: gen_subset(rng, AUTH_TAGS),
    }).collect();

    let auth_queries: Vec<AuthQuery> = (0..3).map(|i| AuthQuery {
        principal: Entity { id: format!("u{}", i), tags: gen_subset(rng, AUTH_TAGS) },
        action: (*rng.pick(ACTIONS)).to_string(),
        resource: rng.pick(&all_resources).clone(),
    }).collect();

    let delegated_queries: Vec<DelegatedQuery> = (0..2).map(|i| DelegatedQuery {
        delegator: Entity { id: format!("del{}", i), tags: gen_subset(rng, AUTH_TAGS) },
        delegatee: Entity { id: format!("sub{}", i), tags: gen_subset(rng, AUTH_TAGS) },
        capability: Capability {
            root_policy_id: "root".into(),
            allowed_action: (*rng.pick(ACTIONS)).to_string(),
            caveats: vec![gen_expr(rng, 1)],
        },
        action: (*rng.pick(ACTIONS)).to_string(),
        resource: rng.pick(&all_resources).clone(),
    }).collect();

    let volumes: Vec<StateVolume> = (0..3).map(|i| StateVolume {
        id: format!("vol{}", i),
        owner: "host".into(),
        traits: gen_subset(rng, STATE_TAGS),
    }).collect();

    TestCase {
        conformance,
        promises,
        stratum_rules,
        policies,
        auth_queries,
        delegated_queries,
        blast_target: Entity { id: "target".into(), tags: gen_subset(rng, AUTH_TAGS) },
        blast_action: (*rng.pick(ACTIONS)).to_string(),
        all_resources,
        substrate: SubstrateCapabilities {
            provides_durable_storage: rng.bool(),
            backup_provider_count: rng.range(3),
        },
        volumes,
    }
}

fn base_promise(id: &str, ptype: &str, key: &str, polarity: Polarity, cardinality: Cardinality) -> Promise {
    Promise {
        id: id.into(),
        ptype: ptype.into(),
        key: key.into(),
        polarity,
        strength: Strength::Hard,
        cardinality,
        mandatory: polarity == Polarity::Use,
        amount: 0,
        priority: 1,
        stratum: 0,
        tags: vec![],
        selector: AttrExpr::Any,
        soft_info: None,
    }
}

pub struct ScenarioExpect {
    pub name: &'static str,
    pub tc: TestCase,
    pub conforms: bool,
    pub scope_valid: bool,
    pub stratum_valid: bool,
    pub state_valid: bool,
}

pub fn concrete_nixconf_scenarios() -> Vec<ScenarioExpect> {
    let policies = vec![
        AuthPolicy {
            id: "permit-edge-prod".into(),
            effect: Effect::Permit,
            action: "decrypt".into(),
            principal_pred: AttrExpr::Inter(
                Box::new(AttrExpr::Atom("group:edge".into())),
                Box::new(AttrExpr::Atom("posture:disk-encrypted".into())),
            ),
            resource_pred: AttrExpr::Atom("tag:prod-core".into()),
        },
        AuthPolicy {
            id: "forbid-untrusted-prod".into(),
            effect: Effect::Forbid,
            action: "decrypt".into(),
            principal_pred: AttrExpr::Union(
                Box::new(AttrExpr::Atom("posture:roaming-stealable".into())),
                Box::new(AttrExpr::Union(
                    Box::new(AttrExpr::Atom("actor:ai-agent".into())),
                    Box::new(AttrExpr::Atom("posture:ephemeral".into())),
                )),
            ),
            resource_pred: AttrExpr::Atom("tag:prod-core".into()),
        },
        AuthPolicy {
            id: "permit-workstation-personal".into(),
            effect: Effect::Permit,
            action: "decrypt".into(),
            principal_pred: AttrExpr::Diff(
                Box::new(AttrExpr::Inter(
                    Box::new(AttrExpr::Atom("group:workstation".into())),
                    Box::new(AttrExpr::Atom("posture:disk-encrypted".into())),
                )),
                Box::new(AttrExpr::Atom("actor:ai-agent".into())),
            ),
            resource_pred: AttrExpr::Atom("tag:personal".into()),
        },
    ];

    let astrolabe = Entity { id: "astrolabe".into(), tags: vec!["group:edge".into(), "posture:disk-encrypted".into()] };
    let chromebook = Entity { id: "chromebook".into(), tags: vec!["group:workstation".into(), "posture:disk-encrypted".into(), "posture:roaming-stealable".into()] };
    let agy = Entity { id: "agy".into(), tags: vec!["actor:ai-agent".into()] };
    let sec_vw = Entity { id: "vaultwarden-db-key".into(), tags: vec!["tag:prod-core".into()] };
    let sec_wifi = Entity { id: "wifi-eduroam".into(), tags: vec!["tag:personal".into()] };

    // Valid P-Explicit Observability Superagent (swapping Grafana -> Perses preserves Pi_ext!)
    let obs_ext = ExteriorSurface {
        agent_id: "observability".into(),
        promises: vec![
            base_promise("obs-http", "http-endpoint", "dashboards", Polarity::Offer, Cardinality::Partitioned),
            base_promise("obs-vol", "durable-vol", "tsdb", Polarity::Use, Cardinality::Exclusive),
        ],
        attributes: vec![],
    };
    let obs_child = ExteriorSurface {
        agent_id: "perses-and-vm".into(),
        promises: vec![
            base_promise("c-http", "http-endpoint", "dashboards", Polarity::Offer, Cardinality::Partitioned),
            base_promise("c-vol", "durable-vol", "tsdb", Polarity::Use, Cardinality::Exclusive),
        ],
        attributes: vec![],
    };

    // Valid astrolabe promises: 2 disjoint partitioned Caddy proxies (public vs mesh) + priority RAM budget
    let mut vw_route = base_promise("vw-route", "http-endpoint", "vault.ex", Polarity::Offer, Cardinality::Partitioned);
    vw_route.tags = vec!["visibility:public".into()];
    let mut caddy_pub = base_promise("caddy-pub", "http-endpoint", "*", Polarity::Use, Cardinality::Partitioned);
    caddy_pub.selector = AttrExpr::Atom("visibility:public".into());
    let mut caddy_mesh = base_promise("caddy-mesh", "http-endpoint", "*", Polarity::Use, Cardinality::Partitioned);
    caddy_mesh.selector = AttrExpr::Atom("visibility:mesh".into());
    let mut ram_sup = base_promise("host-ram", "ram-mb", "host", Polarity::Offer, Cardinality::Budgeted);
    ram_sup.amount = 11000;
    let mut vw_ram = base_promise("vw-ram", "ram-mb", "vw", Polarity::Use, Cardinality::Budgeted);
    vw_ram.amount = 400;
    vw_ram.priority = 0; // Critical edge tier!
    let mut obs_ram = base_promise("obs-ram", "ram-mb", "obs", Polarity::Use, Cardinality::Budgeted);
    obs_ram.amount = 1600;
    obs_ram.priority = 3;

    let mut derived_port = base_promise("caddy-port-443", "tcp-port", "443", Polarity::Offer, Cardinality::Exclusive);
    derived_port.stratum = 1;

    let healthy = TestCase {
        conformance: ConformanceCheck { exterior: obs_ext, children: vec![obs_child] },
        promises: vec![vw_route, caddy_pub, caddy_mesh, ram_sup, vw_ram, obs_ram],
        stratum_rules: vec![HandlerRule {
            id: "caddy-http-to-tcp".into(),
            in_stratum: 0,
            out_stratum: 1,
            emitted: vec![derived_port],
        }],
        policies,
        auth_queries: vec![
            AuthQuery { principal: astrolabe.clone(), action: "decrypt".into(), resource: sec_vw.clone() },
            AuthQuery { principal: agy.clone(), action: "decrypt".into(), resource: sec_vw.clone() },
        ],
        // Gap #4 test: astrolabe (authorized!) delegates prod-core capability to agy (forbidden!) -> MUST BE FALSE!
        delegated_queries: vec![
            DelegatedQuery {
                delegator: astrolabe.clone(),
                delegatee: agy.clone(),
                capability: Capability { root_policy_id: "r".into(), allowed_action: "decrypt".into(), caveats: vec![AttrExpr::Atom("tag:prod-core".into())] },
                action: "decrypt".into(),
                resource: sec_vw.clone(),
            },
        ],
        blast_target: chromebook,
        blast_action: "decrypt".into(),
        all_resources: vec![sec_vw, sec_wifi],
        substrate: SubstrateCapabilities { provides_durable_storage: true, backup_provider_count: 1 },
        volumes: vec![
            StateVolume { id: "vaultwarden-db".into(), owner: "astrolabe".into(), traits: vec!["survives-reboot".into(), "single-auth-writer".into(), "backup-required".into()] },
            StateVolume { id: "vm-tsdb".into(), owner: "astrolabe".into(), traits: vec!["survives-reboot".into(), "single-auth-writer".into(), "monotonic".into()] },
            StateVolume { id: "wsl-win-mnt".into(), owner: "wsl".into(), traits: vec!["survives-reboot".into(), "external-owned".into()] },
        ],
    };

    // Gap #1 failure: Superagent leaks an undeclared interior `-b: postgres` requirement!
    let mut leaked_dep = healthy.clone();
    leaked_dep.conformance.children[0].promises.push(base_promise("leak-pg", "database", "pg", Polarity::Use, Cardinality::Exclusive));

    // Gap #2a failure: Overlapping partitioned proxy selectors both match `visibility:public`!
    let mut overlap_proxy = healthy.clone();
    overlap_proxy.promises[2].selector = AttrExpr::Atom("visibility:public".into());

    // Gap #2b failure: Cyclic handler rule (`in_stratum = 1, out_stratum = 1`)!
    let mut cyclic_stratum = healthy.clone();
    cyclic_stratum.stratum_rules[0].in_stratum = 1;

    // Gap #3 failure: Open-trait Live-ISO deploying durable Vaultwarden (`survives-reboot`, not reconstructible/external)!
    let mut live_iso_bad = healthy.clone();
    live_iso_bad.substrate.provides_durable_storage = false;

    vec![
        ScenarioExpect { name: "astrolabe-full-healthy", tc: healthy, conforms: true, scope_valid: true, stratum_valid: true, state_valid: true },
        ScenarioExpect { name: "gap1-p-explicit-leaked-dep-caught", tc: leaked_dep, conforms: false, scope_valid: true, stratum_valid: true, state_valid: true },
        ScenarioExpect { name: "gap2a-partitioned-proxy-overlap-caught", tc: overlap_proxy, conforms: true, scope_valid: false, stratum_valid: true, state_valid: true },
        ScenarioExpect { name: "gap2b-cyclic-stratum-rule-caught", tc: cyclic_stratum, conforms: true, scope_valid: true, stratum_valid: false, state_valid: true },
        ScenarioExpect { name: "gap3-open-trait-live-iso-durable-caught", tc: live_iso_bad, conforms: true, scope_valid: true, stratum_valid: true, state_valid: false },
    ]
}
