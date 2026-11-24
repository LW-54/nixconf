// Modular AWS Cedar VGD Differential Testing Runner (architecture/formal/drt/)
// Compares modular Rust engine (`engine/*`) bit-for-bit against 4-layer Lean 4 `nixconf-oracle`
// across concrete regression scenarios covering ALL 6 closed gaps + 2,000 randomized fuzzed fleets.

mod engine;
mod gen;
mod wire;

use std::io::Write;
use std::process::{Command, Stdio};
use std::time::Instant;

use engine::agency::superagent_conforms;
use engine::authority::{authorize, blast_radius, is_delegated_authorized};
use engine::binding::{is_scope_valid, validate_stratum_rules};
use engine::state::all_volumes_valid;
use gen::{concrete_nixconf_scenarios, gen_random_case, Rng};
use wire::{auth_response_json, testcase_json, TestCase};

fn eval_rust_json(tc: &TestCase) -> String {
    let conforms = superagent_conforms(&tc.conformance.exterior, &tc.conformance.children);
    let scope_valid = is_scope_valid(&tc.promises);
    let stratum_valid = validate_stratum_rules(&tc.stratum_rules);
    let auths: Vec<String> = tc
        .auth_queries
        .iter()
        .map(|q| auth_response_json(&authorize(&tc.policies, &q.principal, &q.action, &q.resource)))
        .collect();
    let dels: Vec<String> = tc
        .delegated_queries
        .iter()
        .map(|q| is_delegated_authorized(&tc.policies, &q.delegator, &q.delegatee, &q.capability, &q.action, &q.resource).to_string())
        .collect();
    let br: Vec<String> = blast_radius(&tc.policies, &tc.blast_target, &tc.blast_action, &tc.all_resources)
        .into_iter()
        .map(|id| format!(r#""{}""#, id))
        .collect();
    let state_valid = all_volumes_valid(&tc.substrate, &tc.volumes);
    format!(
        r#"{{"authResponses":[{}],"blastRadius":[{}],"conforms":{},"delegatedResults":[{}],"scopeValid":{},"stateValid":{},"stratumValid":{}}}"#,
        auths.join(","), br.join(","), conforms, dels.join(","), scope_valid, state_valid, stratum_valid
    )
}

fn main() {
    let oracle_bin = std::env::args().nth(1).expect("usage: drt <path-to-nixconf-oracle>");

    let scenarios = concrete_nixconf_scenarios();
    let mut cases: Vec<TestCase> = scenarios.iter().map(|s| s.tc.clone()).collect();
    let mut rng = Rng(0x2026_1124_CEDA_0002);
    for i in 0..2000 {
        cases.push(gen_random_case(&mut rng, i));
    }

    let mut ndjson = String::with_capacity(cases.len() * 2048);
    for tc in &cases {
        ndjson.push_str(&testcase_json(tc));
        ndjson.push('\n');
    }

    let t_rust = Instant::now();
    let rust_outputs: Vec<String> = cases.iter().map(eval_rust_json).collect();
    let rust_ms = t_rust.elapsed().as_secs_f64() * 1000.0;

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

    for (idx, sc) in scenarios.iter().enumerate() {
        assert_eq!(rust_outputs[idx], lean_outputs[idx], "DIVERGENCE on scenario {}", sc.name);
        assert!(rust_outputs[idx].contains(&format!(r#""conforms":{}"#, sc.conforms)));
        assert!(rust_outputs[idx].contains(&format!(r#""scopeValid":{}"#, sc.scope_valid)));
        assert!(rust_outputs[idx].contains(&format!(r#""stratumValid":{}"#, sc.stratum_valid)));
        assert!(rust_outputs[idx].contains(&format!(r#""stateValid":{}"#, sc.state_valid)));
        // Gap #4 verified: delegator(astrolabe) -> delegatee(agy) on prod-core MUST be false!
        assert!(rust_outputs[idx].contains(r#""delegatedResults":[false]"#));
        // Cedar determiningPolicies verified bit-for-bit!
        assert!(rust_outputs[idx].contains(r#""determiningPolicies":["forbid-untrusted-prod"]"#));
        println!("  [PASS] {:<42} => Lean4 == Rust (conforms={}, scope={}, stratum={}, state={})",
            sc.name, sc.conforms, sc.scope_valid, sc.stratum_valid, sc.state_valid);
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
        "\n[OK] Modular AWS Cedar VGD DRT PASSED: {} cases (5 concrete + 2000 fuzzed), 0 divergences!",
        cases.len()
    );
    println!(
        "     Throughput: Rust engine = {:.2} ms ({:.0} cases/s) | Lean 4 oracle = {:.2} ms ({:.0} cases/s)",
        rust_ms,
        cases.len() as f64 / (rust_ms / 1000.0),
        lean_ms,
        cases.len() as f64 / (lean_ms / 1000.0)
    );
}
