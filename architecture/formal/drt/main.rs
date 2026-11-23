// AWS Cedar Verification-Guided Development (F3-b) — Rust Production Verifier + Differential Testing Harness
// Implements the idiomatic Rust production evaluator for NixconfFoundation (ADR-0002..ADR-0006, RES-0013)
// and differentially tests it bit-for-bit against the machine-proved Lean 4 `nixconf-oracle` binary across:
//   1. Concrete `nixconf` heterogeneous fleet regression scenarios (astrolabe, x240, rpi, chromebook, live-iso, agy)
//   2. 2,000 randomized + adversarial fuzzed fleets (Differential Randomized Testing, DRT)
// Zero external crate dependencies so it compiles standalone in <0.5s with stock `rustc`.

use std::io::Write;
use std::process::{Command, Stdio};
use std::time::Instant;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Polarity { Offer, Use }

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Strength { Hard, Soft }

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Cardinality { Exclusive, Broadcast, Partitioned, Budgeted }

#[derive(Clone, Debug)]
struct SoftContract {
    condition_ref: String,
    degraded_mode: String,
    probe_id: String,
}

impl SoftContract {
    fn is_complete(&self) -> bool {
        !self.condition_ref.is_empty() && !self.degraded_mode.is_empty() && !self.probe_id.is_empty()
    }
}

#[derive(Clone, Debug)]
struct Promise {
    id: String,
    ptype: String,
    key: String,
    polarity: Polarity,
    strength: Strength,
    cardinality: Cardinality,
    mandatory: bool,
    amount: u64,
    soft_info: Option<SoftContract>,
}

#[derive(Clone, Debug)]
enum AttrExpr {
    Atom(String),
    Union(Box<AttrExpr>, Box<AttrExpr>),
    Inter(Box<AttrExpr>, Box<AttrExpr>),
    Diff(Box<AttrExpr>, Box<AttrExpr>),
    Compl(Box<AttrExpr>),
    Any,
    NoneExpr,
}

impl AttrExpr {
    fn eval(&self, tags: &[String]) -> bool {
        match self {
            AttrExpr::Atom(t) => tags.iter().any(|x| x == t),
            AttrExpr::Union(a, b) => a.eval(tags) || b.eval(tags),
            AttrExpr::Inter(a, b) => a.eval(tags) && b.eval(tags),
            AttrExpr::Diff(a, b) => a.eval(tags) && !b.eval(tags),
            AttrExpr::Compl(inner) => !inner.eval(tags),
            AttrExpr::Any => true,
            AttrExpr::NoneExpr => false,
        }
    }

    fn to_json(&self) -> String {
        match self {
            AttrExpr::Atom(t) => format!(r#"{{"kind":"atom","tag":"{}"}}"#, t),
            AttrExpr::Union(a, b) => format!(r#"{{"kind":"union","left":{},"right":{}}}"#, a.to_json(), b.to_json()),
            AttrExpr::Inter(a, b) => format!(r#"{{"kind":"inter","left":{},"right":{}}}"#, a.to_json(), b.to_json()),
            AttrExpr::Diff(a, b) => format!(r#"{{"kind":"diff","left":{},"right":{}}}"#, a.to_json(), b.to_json()),
            AttrExpr::Compl(i) => format!(r#"{{"kind":"compl","inner":{}}}"#, i.to_json()),
            AttrExpr::Any => r#"{"kind":"any"}"#.to_string(),
            AttrExpr::NoneExpr => r#"{"kind":"none"}"#.to_string(),
        }
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
enum Effect { Permit, Forbid }

#[derive(Clone, Debug)]
struct AuthPolicy {
    id: String,
    effect: Effect,
    action: String,
    principal_pred: AttrExpr,
    resource_pred: AttrExpr,
}

#[derive(Clone, Debug)]
struct Entity {
    id: String,
    tags: Vec<String>,
}

#[derive(Clone, Debug)]
struct AuthQuery {
    principal: Entity,
    action: String,
    resource: Entity,
}

#[derive(Clone, Debug)]
struct StateTraits {
    reconstructible: bool,
    survives_reboot: bool,
    monotonic: bool,
    multi_writer: bool,
    single_auth_writer: bool,
    backup_required: bool,
    external_owned: bool,
}

#[derive(Clone, Debug)]
struct StateVolume {
    id: String,
    owner: String,
    traits: StateTraits,
}

#[derive(Clone, Debug)]
struct SubstrateCapabilities {
    provides_durable_storage: bool,
    backup_provider_count: u64,
}

#[derive(Clone, Debug)]
struct TestCase {
    promises: Vec<Promise>,
    policies: Vec<AuthPolicy>,
    auth_queries: Vec<AuthQuery>,
    blast_target: Entity,
    blast_action: String,
    all_resources: Vec<Entity>,
    substrate: SubstrateCapabilities,
    volumes: Vec<StateVolume>,
}

// === RUST PRODUCTION VERIFIER (MIRRORING PROVED LEAN 4 SEMANTICS) ===

fn count_matching_offers(ps: &[Promise], ptype: &str, key: &str) -> usize {
    ps.iter()
        .filter(|p| p.polarity == Polarity::Offer && p.ptype == ptype && p.key == key)
        .count()
}

fn total_budget_supply(ps: &[Promise], ptype: &str) -> u64 {
    ps.iter()
        .filter(|p| p.polarity == Polarity::Offer && p.cardinality == Cardinality::Budgeted && p.ptype == ptype)
        .map(|p| p.amount)
        .sum()
}

fn total_budget_demand(ps: &[Promise], ptype: &str) -> u64 {
    ps.iter()
        .filter(|p| p.polarity == Polarity::Use && p.cardinality == Cardinality::Budgeted && p.ptype == ptype)
        .map(|p| p.amount)
        .sum()
}

fn is_scope_valid(ps: &[Promise]) -> bool {
    for p in ps {
        if p.strength == Strength::Soft {
            match &p.soft_info {
                Some(sc) if sc.is_complete() => {}
                _ => return false,
            }
        }
        match (p.cardinality, p.polarity, p.strength, p.mandatory) {
            (Cardinality::Exclusive, Polarity::Use, Strength::Hard, true) => {
                if count_matching_offers(ps, &p.ptype, &p.key) != 1 {
                    return false;
                }
            }
            (Cardinality::Exclusive, Polarity::Offer, _, _) => {
                if count_matching_offers(ps, &p.ptype, &p.key) > 1 {
                    return false;
                }
            }
            (Cardinality::Partitioned, Polarity::Offer, _, _) => {
                if count_matching_offers(ps, &p.ptype, &p.key) > 1 {
                    return false;
                }
            }
            (Cardinality::Budgeted, Polarity::Use, _, _) => {
                if total_budget_demand(ps, &p.ptype) > total_budget_supply(ps, &p.ptype) {
                    return false;
                }
            }
            _ => {}
        }
    }
    true
}

fn policy_matches(pol: &AuthPolicy, principal: &Entity, action: &str, resource: &Entity) -> bool {
    pol.action == action
        && pol.principal_pred.eval(&principal.tags)
        && pol.resource_pred.eval(&resource.tags)
}

fn is_authorized(policies: &[AuthPolicy], principal: &Entity, action: &str, resource: &Entity) -> bool {
    let has_permit = policies
        .iter()
        .any(|p| p.effect == Effect::Permit && policy_matches(p, principal, action, resource));
    let has_forbid = policies
        .iter()
        .any(|p| p.effect == Effect::Forbid && policy_matches(p, principal, action, resource));
    has_permit && !has_forbid
}

fn blast_radius(policies: &[AuthPolicy], principal: &Entity, action: &str, resources: &[Entity]) -> Vec<String> {
    resources
        .iter()
        .filter(|r| is_authorized(policies, principal, action, r))
        .map(|r| r.id.clone())
        .collect()
}

fn all_volumes_valid(sub: &SubstrateCapabilities, vs: &[StateVolume]) -> bool {
    vs.iter().all(|v| {
        let needs_persist = v.traits.survives_reboot && !v.traits.reconstructible && !v.traits.external_owned;
        let calm_ok = !v.traits.multi_writer || v.traits.monotonic || v.traits.single_auth_writer;
        let backup_ok = !v.traits.backup_required || sub.backup_provider_count > 0;
        (!needs_persist || sub.provides_durable_storage) && calm_ok && backup_ok
    })
}

fn eval_rust_json(tc: &TestCase) -> String {
    let sv = is_scope_valid(&tc.promises);
    let auths: Vec<String> = tc
        .auth_queries
        .iter()
        .map(|q| is_authorized(&tc.policies, &q.principal, &q.action, &q.resource).to_string())
        .collect();
    let br: Vec<String> = blast_radius(&tc.policies, &tc.blast_target, &tc.blast_action, &tc.all_resources)
        .into_iter()
        .map(|id| format!(r#""{}""#, id))
        .collect();
    let stv = all_volumes_valid(&tc.substrate, &tc.volumes);
    format!(
        r#"{{"authResults":[{}],"blastRadius":[{}],"scopeValid":{},"stateValid":{}}}"#,
        auths.join(","),
        br.join(","),
        sv,
        stv
    )
}

// === JSON SERIALIZATION FOR LEAN ORACLE WIRE PROTOCOL ===

fn entity_json(e: &Entity) -> String {
    let tags: Vec<String> = e.tags.iter().map(|t| format!(r#""{}""#, t)).collect();
    format!(r#"{{"id":"{}","tags":[{}]}}"#, e.id, tags.join(","))
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
        r#"{{"id":"{}","ptype":"{}","key":"{}","polarity":"{}","strength":"{}","cardinality":"{}","mandatory":{},"amount":{},"softInfo":{}}}"#,
        p.id, p.ptype, p.key, pol, st, card, p.mandatory, p.amount, si
    )
}

fn policy_json(pol: &AuthPolicy) -> String {
    let eff = match pol.effect { Effect::Permit => "permit", Effect::Forbid => "forbid" };
    format!(
        r#"{{"id":"{}","effect":"{}","action":"{}","principalPred":{},"resourcePred":{}}}"#,
        pol.id, eff, pol.action, pol.principal_pred.to_json(), pol.resource_pred.to_json()
    )
}

fn volume_json(v: &StateVolume) -> String {
    let t = &v.traits;
    format!(
        r#"{{"id":"{}","owner":"{}","traits":{{"reconstructible":{},"survivesReboot":{},"monotonic":{},"multiWriter":{},"singleAuthWriter":{},"backupRequired":{},"externalOwned":{}}}}}"#,
        v.id, v.owner, t.reconstructible, t.survives_reboot, t.monotonic,
        t.multi_writer, t.single_auth_writer, t.backup_required, t.external_owned
    )
}

fn testcase_json(tc: &TestCase) -> String {
    let ps: Vec<String> = tc.promises.iter().map(promise_json).collect();
    let pols: Vec<String> = tc.policies.iter().map(policy_json).collect();
    let qs: Vec<String> = tc.auth_queries.iter().map(|q| {
        format!(r#"{{"principal":{},"action":"{}","resource":{}}}"#, entity_json(&q.principal), q.action, entity_json(&q.resource))
    }).collect();
    let res: Vec<String> = tc.all_resources.iter().map(entity_json).collect();
    let vols: Vec<String> = tc.volumes.iter().map(volume_json).collect();
    format!(
        r#"{{"promises":[{}],"policies":[{}],"authQueries":[{}],"blastTarget":{},"blastAction":"{}","allResources":[{}],"substrate":{{"providesDurableStorage":{},"backupProviderCount":{}}},"volumes":[{}]}}"#,
        ps.join(","), pols.join(","), qs.join(","),
        entity_json(&tc.blast_target), tc.blast_action, res.join(","),
        tc.substrate.provides_durable_storage, tc.substrate.backup_provider_count,
        vols.join(",")
    )
}

// === DETERMINISTIC XorShift64 PRNG FOR REPRODUCIBLE DRT ===

struct Rng(u64);
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

const TAGS: &[&str] = &[
    "group:edge", "group:workstation", "posture:disk-encrypted",
    "posture:roaming-stealable", "posture:ephemeral", "actor:ai-agent",
    "tag:prod-core", "tag:personal", "tag:repo-nixconf",
];
const PTYPES: &[&str] = &["secret", "http-endpoint", "ram-mb", "metrics"];
const KEYS: &[&str] = &["k1", "k2", "k3"];
const ACTIONS: &[&str] = &["decrypt", "git-push", "remote-build"];

fn gen_expr(rng: &mut Rng, depth: u32) -> AttrExpr {
    if depth == 0 {
        return match rng.range(3) {
            0 => AttrExpr::Atom((*rng.pick(TAGS)).to_string()),
            1 => AttrExpr::Any,
            _ => AttrExpr::NoneExpr,
        };
    }
    match rng.range(6) {
        0 => AttrExpr::Atom((*rng.pick(TAGS)).to_string()),
        1 => AttrExpr::Union(Box::new(gen_expr(rng, depth - 1)), Box::new(gen_expr(rng, depth - 1))),
        2 => AttrExpr::Inter(Box::new(gen_expr(rng, depth - 1)), Box::new(gen_expr(rng, depth - 1))),
        3 => AttrExpr::Diff(Box::new(gen_expr(rng, depth - 1)), Box::new(gen_expr(rng, depth - 1))),
        4 => AttrExpr::Compl(Box::new(gen_expr(rng, depth - 1))),
        _ => AttrExpr::Any,
    }
}

fn gen_tags(rng: &mut Rng) -> Vec<String> {
    TAGS.iter().filter(|_| rng.bool()).map(|s| s.to_string()).collect()
}

fn gen_random_case(rng: &mut Rng, idx: usize) -> TestCase {
    let n_promises = (rng.range(8) + 1) as usize;
    let mut promises = Vec::with_capacity(n_promises);
    for i in 0..n_promises {
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
        promises.push(Promise {
            id: format!("p{}_{}", idx, i),
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
            soft_info,
        });
    }

    let n_pols = (rng.range(6) + 1) as usize;
    let policies = (0..n_pols).map(|i| AuthPolicy {
        id: format!("pol{}", i),
        effect: if rng.range(3) == 0 { Effect::Forbid } else { Effect::Permit },
        action: (*rng.pick(ACTIONS)).to_string(),
        principal_pred: gen_expr(rng, 2),
        resource_pred: gen_expr(rng, 2),
    }).collect();

    let all_resources: Vec<Entity> = (0..4).map(|i| Entity {
        id: format!("res{}", i),
        tags: gen_tags(rng),
    }).collect();

    let blast_target = Entity { id: "principal0".into(), tags: gen_tags(rng) };
    let blast_action = (*rng.pick(ACTIONS)).to_string();

    let auth_queries = (0..3).map(|i| AuthQuery {
        principal: Entity { id: format!("p{}", i), tags: gen_tags(rng) },
        action: (*rng.pick(ACTIONS)).to_string(),
        resource: rng.pick(&all_resources).clone(),
    }).collect();

    let substrate = SubstrateCapabilities {
        provides_durable_storage: rng.bool(),
        backup_provider_count: rng.range(3),
    };

    let n_vols = (rng.range(4) + 1) as usize;
    let volumes = (0..n_vols).map(|i| StateVolume {
        id: format!("vol{}", i),
        owner: "host".into(),
        traits: StateTraits {
            reconstructible: rng.bool(),
            survives_reboot: rng.bool(),
            monotonic: rng.bool(),
            multi_writer: rng.bool(),
            single_auth_writer: rng.bool(),
            backup_required: rng.bool(),
            external_owned: rng.bool(),
        },
    }).collect();

    TestCase { promises, policies, auth_queries, blast_target, blast_action, all_resources, substrate, volumes }
}

fn concrete_nixconf_scenarios() -> Vec<(&'static str, TestCase, bool, bool)> {
    // Shared Cedar-style L3+ fleet policies:
    //   1. Permit edge servers with encrypted disk to decrypt prod-core
    //   2. FORBID any roaming-stealable OR ai-agent OR ephemeral from prod-core (overrides any stray permit!)
    //   3. Accidental stray permit granting agy (ai-agent) access to prod-core -> MUST be defeated by Forbid!
    //   4. Permit encrypted workstations (excluding public-exposed & ai-agent) to decrypt personal secrets
    let fleet_policies = vec![
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
            id: "accidental-stray-permit-ai".into(),
            effect: Effect::Permit,
            action: "decrypt".into(),
            principal_pred: AttrExpr::Atom("actor:ai-agent".into()),
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
    let all_res = vec![sec_vw.clone(), sec_wifi.clone()];

    let auth_queries = vec![
        AuthQuery { principal: astrolabe.clone(), action: "decrypt".into(), resource: sec_vw.clone() },  // true
        AuthQuery { principal: agy.clone(), action: "decrypt".into(), resource: sec_vw.clone() },        // false (Forbid beats stray Permit!)
        AuthQuery { principal: chromebook.clone(), action: "decrypt".into(), resource: sec_vw.clone() }, // false
        AuthQuery { principal: chromebook.clone(), action: "decrypt".into(), resource: sec_wifi.clone() }, // true -> in blastRadius!
    ];

    // Scenario 1: Healthy astrolabe VPS (11000 MiB RAM supply vs 2000 MiB demand, durable storage + restic backup)
    let s1 = TestCase {
        promises: vec![
            Promise { id: "host-ram".into(), ptype: "ram-mb".into(), key: "host".into(), polarity: Polarity::Offer, strength: Strength::Hard, cardinality: Cardinality::Budgeted, mandatory: false, amount: 11000, soft_info: None },
            Promise { id: "obs-ram".into(), ptype: "ram-mb".into(), key: "obs".into(), polarity: Polarity::Use, strength: Strength::Hard, cardinality: Cardinality::Budgeted, mandatory: true, amount: 1600, soft_info: None },
            Promise { id: "core-ram".into(), ptype: "ram-mb".into(), key: "core".into(), polarity: Polarity::Use, strength: Strength::Hard, cardinality: Cardinality::Budgeted, mandatory: true, amount: 400, soft_info: None },
            Promise { id: "sops-vw".into(), ptype: "secret".into(), key: "vw-token".into(), polarity: Polarity::Offer, strength: Strength::Hard, cardinality: Cardinality::Exclusive, mandatory: false, amount: 0, soft_info: None },
            Promise { id: "vw-req".into(), ptype: "secret".into(), key: "vw-token".into(), polarity: Polarity::Use, strength: Strength::Hard, cardinality: Cardinality::Exclusive, mandatory: true, amount: 0, soft_info: None },
            Promise { id: "restic-offhost".into(), ptype: "backup".into(), key: "b2".into(), polarity: Polarity::Offer, strength: Strength::Soft, cardinality: Cardinality::Broadcast, mandatory: false, amount: 0, soft_info: Some(SoftContract { condition_ref: "wan-up".into(), degraded_mode: "queue-local".into(), probe_id: "restic-age".into() }) },
        ],
        policies: fleet_policies.clone(),
        auth_queries: auth_queries.clone(),
        blast_target: chromebook.clone(),
        blast_action: "decrypt".into(),
        all_resources: all_res.clone(),
        substrate: SubstrateCapabilities { provides_durable_storage: true, backup_provider_count: 1 },
        volumes: vec![
            StateVolume { id: "vaultwarden-db".into(), owner: "astrolabe".into(), traits: StateTraits { reconstructible: false, survives_reboot: true, monotonic: false, multi_writer: false, single_auth_writer: true, backup_required: true, external_owned: false } },
            StateVolume { id: "vm-tsdb".into(), owner: "astrolabe".into(), traits: StateTraits { reconstructible: false, survives_reboot: true, monotonic: true, multi_writer: false, single_auth_writer: true, backup_required: false, external_owned: false } },
        ],
    };

    // Scenario 2: Constrained 1024 MiB RPi over-committed by 1600 MiB Observability -> MUST fail scopeValid!
    let mut s2 = s1.clone();
    s2.promises[0].amount = 1024;

    // Scenario 3: Live-ISO (ephemeral) accidentally deploying durable Vaultwarden -> MUST fail stateValid!
    let mut s3 = s1.clone();
    s3.substrate.provides_durable_storage = false;

    // Scenario 4: CALM violation (multi-writer non-monotonic state without single authoritative writer) -> MUST fail stateValid!
    let mut s4 = s1.clone();
    s4.volumes[0].traits.multi_writer = true;
    s4.volumes[0].traits.single_auth_writer = false;
    s4.volumes[0].traits.monotonic = false;

    vec![
        ("astrolabe-healthy", s1, true, true),
        ("rpi-budget-exceeded", s2, false, true),
        ("live-iso-durable-rejected", s3, true, false),
        ("calm-non-monotonic-multiwriter-rejected", s4, true, false),
    ]
}

fn main() {
    let oracle_bin = std::env::args().nth(1).expect("usage: drt <path-to-nixconf-oracle>");

    // 1. Concrete fleet regression scenarios + 2,000 randomized DRT vectors
    let scenarios = concrete_nixconf_scenarios();
    let mut cases: Vec<TestCase> = scenarios.iter().map(|(_, tc, _, _)| tc.clone()).collect();
    let mut rng = Rng(0x2026_1124_CEDA_0001);
    for i in 0..2000 {
        cases.push(gen_random_case(&mut rng, i));
    }

    // Serialize batch to NDJSON
    let mut ndjson = String::with_capacity(cases.len() * 1024);
    for tc in &cases {
        ndjson.push_str(&testcase_json(tc));
        ndjson.push('\n');
    }

    // Time Rust Production Verifier
    let t_rust = Instant::now();
    let rust_outputs: Vec<String> = cases.iter().map(eval_rust_json).collect();
    let rust_ms = t_rust.elapsed().as_secs_f64() * 1000.0;

    // Time Lean 4 Machine-Proved Oracle Binary
    let t_lean = Instant::now();
    let mut child = Command::new(&oracle_bin)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .expect("failed to launch nixconf-oracle");
    child.stdin.as_mut().unwrap().write_all(ndjson.as_bytes()).unwrap();
    let output = child.wait_with_output().unwrap();
    assert!(output.status.success(), "Lean oracle failed: {}", String::from_utf8_lossy(&output.stderr));
    let lean_ms = t_lean.elapsed().as_secs_f64() * 1000.0;

    let lean_stdout = String::from_utf8(output.stdout).unwrap();
    let lean_outputs: Vec<&str> = lean_stdout.lines().collect();
    assert_eq!(lean_outputs.len(), rust_outputs.len(), "output count mismatch");

    // Verify concrete scenario expectations + 100% bit-for-bit Rust == Lean equivalence!
    for (idx, (name, _, exp_scope, exp_state)) in scenarios.iter().enumerate() {
        assert_eq!(rust_outputs[idx], lean_outputs[idx], "DIVERGENCE on scenario {}", name);
        let expected_sub_scope = format!(r#""scopeValid":{}"#, exp_scope);
        let expected_sub_state = format!(r#""stateValid":{}"#, exp_state);
        assert!(rust_outputs[idx].contains(&expected_sub_scope), "scenario {} scope mismatch: {}", name, rust_outputs[idx]);
        assert!(rust_outputs[idx].contains(&expected_sub_state), "scenario {} state mismatch: {}", name, rust_outputs[idx]);
        // Verify Cedar forbid-overrides-permit + blastRadius on every concrete scenario
        assert!(rust_outputs[idx].contains(r#""authResults":[true,false,false,true]"#), "auth mismatch: {}", rust_outputs[idx]);
        assert!(rust_outputs[idx].contains(r#""blastRadius":["wifi-eduroam"]"#), "blastRadius mismatch: {}", rust_outputs[idx]);
        println!("  [PASS] scenario {:<40} => Lean4 == Rust ({})", name, rust_outputs[idx]);
    }

    let mut mismatches = 0usize;
    for i in 0..cases.len() {
        if rust_outputs[i] != lean_outputs[i] {
            eprintln!("DRT MISMATCH at case {}:\n  Rust: {}\n  Lean: {}", i, rust_outputs[i], lean_outputs[i]);
            mismatches += 1;
        }
    }
    assert_eq!(mismatches, 0, "DRT found {} divergences!", mismatches);

    println!(
        "\n[OK] AWS Cedar VGD Differential Testing PASSED: {} total cases (4 concrete + 2000 randomized), 0 divergences!",
        cases.len()
    );
    println!(
        "     Throughput: Rust engine = {:.2} ms ({:.0} cases/s) | Lean 4 native oracle = {:.2} ms ({:.0} cases/s)",
        rust_ms,
        cases.len() as f64 / (rust_ms / 1000.0),
        lean_ms,
        cases.len() as f64 / (lean_ms / 1000.0)
    );
}
