//! **Antikythera (`aky`)** — Zero-Nix CLI verifier, Cedar policy explainer,
//! stolen-device blast-radius analyzer, `S1` binding resolver, and Lean 4 DRT runner.

use std::collections::BTreeMap;
use std::fs;
use std::io::{BufRead, BufReader, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode, Stdio};
use std::time::Instant;

use aky_core::authority::{Decision, Entity, authorize, blast_radius};
use aky_core::drt::{OracleRequest, OracleResponse, eval_request, generate_fuzzed_cases};
use aky_core::fleet::{
    AgentManifest, FleetSpec, PolicyCatalog, ProfileManifest, resolve_target_bindings,
    superagent_to_oracle_request, verify_fleet,
};
use clap::{Parser, Subcommand};
use thiserror::Error;

/// Antikythera (`aky`) fleet boundary verification & introspection CLI.
#[derive(Debug, Parser)]
#[command(
    name = "aky",
    version,
    about = "Antikythera declarative fleet verifier"
)]
struct Cli {
    /// Root directory of the Antikythera repo (`agents/`, `profiles/`, `policies/`).
    #[arg(long, global = true, default_value = ".")]
    root: PathBuf,

    /// Emit machine-readable JSON output for CI & AI agents.
    #[arg(long, global = true)]
    json: bool,

    #[command(subcommand)]
    command: Cmd,
}

#[derive(Debug, Subcommand)]
enum Cmd {
    /// Verify all Dressed Superagents (stacks & root targets), budgets, state traits, and standalone agents.
    Check,
    /// Explain a Cedar L3+ authorization verdict including `determiningPolicies`.
    Explain {
        /// Principal ID from `policies/*.toml` or `agents/*/agent.toml`.
        principal: String,
        /// Action name (e.g., `read-secret`).
        action: String,
        /// Resource ID from `policies/*.toml`.
        resource: String,
    },
    /// Compute the exact sound-and-complete stolen-device blast radius for a principal.
    BlastRadius {
        /// Principal ID to audit.
        principal: String,
        /// Action name (defaults to `read-secret`).
        #[arg(default_value = "read-secret")]
        action: String,
    },
    /// Emit deterministic S1 `bound` + `persistent_paths` JSON for a root Dressed Superagent.
    Resolve {
        /// Root agent identifier (e.g., `astrolabe`).
        target: String,
    },
    /// Run AWS Cedar Differential Randomized Testing comparing `aky-core` against `aky-oracle`.
    Drt {
        /// Path to the compiled Lean 4 `aky-oracle` binary.
        #[arg(long)]
        oracle: PathBuf,
        /// Number of deterministic randomized fuzzed fleets to test in addition to real repo superagents.
        #[arg(long, default_value_t = 500)]
        cases: usize,
        /// Deterministic PRNG seed.
        #[arg(long, default_value_t = 0xA417_2026)]
        seed: u64,
    },
}

#[derive(Debug, Error)]
enum CliError {
    #[error("I/O error at {path}: {source}")]
    Io {
        path: PathBuf,
        #[source]
        source: std::io::Error,
    },
    #[error("TOML parse error in {path}: {source}")]
    Toml {
        path: PathBuf,
        #[source]
        source: toml::de::Error,
    },
    #[error("JSON serialization error: {0}")]
    Json(#[from] serde_json::Error),
    #[error("unknown {kind}: {id}")]
    NotFound { kind: &'static str, id: String },
    #[error("Lean oracle process error: {0}")]
    Oracle(String),
}

fn read_toml<T: serde::de::DeserializeOwned>(path: &Path) -> Result<T, CliError> {
    let raw = fs::read_to_string(path).map_err(|source| CliError::Io {
        path: path.to_path_buf(),
        source,
    })?;
    toml::from_str(&raw).map_err(|source| CliError::Toml {
        path: path.to_path_buf(),
        source,
    })
}

fn load_fleet(root: &Path) -> Result<FleetSpec, CliError> {
    let mut agents = BTreeMap::new();
    let agents_dir = root.join("agents");
    if agents_dir.is_dir() {
        for entry in fs::read_dir(&agents_dir).map_err(|source| CliError::Io {
            path: agents_dir.clone(),
            source,
        })? {
            let entry = entry.map_err(|source| CliError::Io {
                path: agents_dir.clone(),
                source,
            })?;
            let path = entry.path();
            let manifest_path = if path.is_dir() {
                path.join("agent.toml")
            } else {
                path
            };
            if manifest_path.extension().and_then(|s| s.to_str()) == Some("toml")
                && manifest_path.is_file()
            {
                let agent: AgentManifest = read_toml(&manifest_path)?;
                agents.insert(agent.id.clone(), agent);
            }
        }
    }

    let mut profiles = BTreeMap::new();
    let profiles_dir = root.join("profiles");
    if profiles_dir.is_dir() {
        for entry in fs::read_dir(&profiles_dir).map_err(|source| CliError::Io {
            path: profiles_dir.clone(),
            source,
        })? {
            let entry = entry.map_err(|source| CliError::Io {
                path: profiles_dir.clone(),
                source,
            })?;
            let path = entry.path();
            if path.extension().and_then(|s| s.to_str()) == Some("toml") && path.is_file() {
                let prof: ProfileManifest = read_toml(&path)?;
                profiles.insert(prof.id.clone(), prof);
            }
        }
    }

    let mut policy_catalog = PolicyCatalog::default();
    let policies_dir = root.join("policies");
    if policies_dir.is_dir() {
        let mut policy_files: Vec<PathBuf> = Vec::new();
        for entry in fs::read_dir(&policies_dir).map_err(|source| CliError::Io {
            path: policies_dir.clone(),
            source,
        })? {
            let entry = entry.map_err(|source| CliError::Io {
                path: policies_dir.clone(),
                source,
            })?;
            let path = entry.path();
            if path.extension().and_then(|s| s.to_str()) == Some("toml") && path.is_file() {
                policy_files.push(path);
            }
        }
        policy_files.sort();
        for path in policy_files {
            let part: PolicyCatalog = read_toml(&path)?;
            policy_catalog.principals.extend(part.principals);
            policy_catalog.resources.extend(part.resources);
            policy_catalog.policies.extend(part.policies);
        }
    }

    Ok(FleetSpec {
        agents,
        profiles,
        policy_catalog,
    })
}

fn find_principal(fleet: &FleetSpec, id: &str) -> Result<Entity, CliError> {
    if let Some(p) = fleet.policy_catalog.principals.iter().find(|p| p.id == id) {
        return Ok(p.clone());
    }
    if let Some(a) = fleet.agents.get(id) {
        return Ok(Entity {
            id: a.id.clone(),
            tags: a.attributes.clone(),
        });
    }
    Err(CliError::NotFound {
        kind: "principal",
        id: id.to_string(),
    })
}

fn invoke_oracle(
    oracle_path: &Path,
    requests: &[(String, OracleRequest)],
) -> Result<(Vec<OracleResponse>, f64), CliError> {
    let t_lean = Instant::now();
    let mut child = Command::new(oracle_path)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| CliError::Oracle(format!("failed to spawn {}: {e}", oracle_path.display())))?;

    {
        let mut stdin = child
            .stdin
            .take()
            .ok_or_else(|| CliError::Oracle("missing oracle stdin".to_string()))?;
        for (_, req) in requests {
            let line = serde_json::to_string(req)?;
            writeln!(stdin, "{line}")
                .map_err(|e| CliError::Oracle(format!("write to oracle failed: {e}")))?;
        }
    }

    let stdout = child
        .stdout
        .take()
        .ok_or_else(|| CliError::Oracle("missing oracle stdout".to_string()))?;
    let mut lean_results: Vec<OracleResponse> = Vec::with_capacity(requests.len());
    for line in BufReader::new(stdout).lines() {
        let line = line.map_err(|e| CliError::Oracle(format!("read from oracle failed: {e}")))?;
        if !line.trim().is_empty() {
            let parsed: OracleResponse = serde_json::from_str(&line)?;
            lean_results.push(parsed);
        }
    }
    let status = child
        .wait()
        .map_err(|e| CliError::Oracle(format!("wait on oracle failed: {e}")))?;
    if !status.success() {
        return Err(CliError::Oracle(format!(
            "oracle exited with status {status}"
        )));
    }
    Ok((lean_results, t_lean.elapsed().as_secs_f64() * 1000.0))
}

fn run_drt(
    fleet: &FleetSpec,
    oracle_path: &Path,
    fuzzed_count: usize,
    seed: u64,
    as_json: bool,
) -> Result<bool, CliError> {
    let mut requests: Vec<(String, OracleRequest)> = Vec::new();
    let mut real_superagents: usize = 0;
    for aid in fleet.agents.keys() {
        if let Some(req) = superagent_to_oracle_request(fleet, aid) {
            real_superagents = real_superagents.saturating_add(1);
            requests.push((format!("superagent:{aid}"), req));
        }
    }
    for (idx, req) in generate_fuzzed_cases(seed, fuzzed_count)
        .into_iter()
        .enumerate()
    {
        requests.push((format!("fuzz:{idx}"), req));
    }

    let t_rust = Instant::now();
    let rust_results: Vec<OracleResponse> = requests.iter().map(|(_, r)| eval_request(r)).collect();
    let rust_ms = t_rust.elapsed().as_secs_f64() * 1000.0;

    let (lean_results, lean_ms) = invoke_oracle(oracle_path, &requests)?;

    if lean_results.len() != rust_results.len() {
        return Err(CliError::Oracle(format!(
            "response count mismatch: rust={} lean={}",
            rust_results.len(),
            lean_results.len()
        )));
    }

    let mut divergences: Vec<String> = Vec::new();
    for ((label, _), (r, l)) in requests
        .iter()
        .zip(rust_results.iter().zip(lean_results.iter()))
    {
        if r != l {
            divergences.push(format!("{label}: rust={r:?} lean={l:?}"));
        }
    }

    let passed = divergences.is_empty();
    if as_json {
        println!(
            "{}",
            serde_json::to_string_pretty(&serde_json::json!({
                "totalCases": requests.len(),
                "realSuperagents": real_superagents,
                "fuzzedCases": fuzzed_count,
                "divergences": divergences.len(),
                "rustMs": rust_ms,
                "leanMs": lean_ms,
                "passed": passed,
            }))?
        );
    } else {
        println!(
            "DRT: {}/{} cases matched bit-for-bit ({} real superagents + {} fuzzed) | Rust: {:.2} ms | Lean 4 oracle: {:.2} ms",
            requests.len().saturating_sub(divergences.len()),
            requests.len(),
            real_superagents,
            fuzzed_count,
            rust_ms,
            lean_ms
        );
        for d in divergences.iter().take(5) {
            eprintln!("  DIVERGENCE: {d}");
        }
    }

    Ok(passed)
}

fn run_check(fleet: &FleetSpec, elapsed_ms: f64, as_json: bool) -> Result<bool, CliError> {
    let report = verify_fleet(fleet);
    if as_json {
        println!("{}", serde_json::to_string_pretty(&report)?);
    } else {
        for sr in report.superagents.values() {
            let status = if sr.is_valid() { "PASS" } else { "FAIL" };
            let target_tag = sr.system.as_deref().unwrap_or("nested-superagent");
            println!(
                "[{status}] superagent={} ({target_tag}) children={} persisted={}",
                sr.agent_id,
                sr.direct_children.len(),
                sr.persistent_paths.len()
            );
            for m in &sr.missing_refs {
                eprintln!("  missing: {m}");
            }
            for b in &sr.binding_errors {
                eprintln!("  binding: {b:?}");
            }
            for c in &sr.boundary_errors {
                eprintln!("  boundary: {c:?}");
            }
            for s in &sr.state_errors {
                eprintln!("  state: {s:?}");
            }
            if !sr.tree_valid {
                eprintln!("  tree: recursive Agent tree verification failed");
            }
        }
        println!(
            "Standalone agents (X4): [{}] | verified in {elapsed_ms:.2} ms",
            report.standalone_agents.join(", ")
        );
    }
    Ok(report.is_valid())
}

fn run(cli: &Cli) -> Result<bool, CliError> {
    let t0 = Instant::now();
    let fleet = load_fleet(&cli.root)?;

    match &cli.command {
        Cmd::Check => run_check(&fleet, t0.elapsed().as_secs_f64() * 1000.0, cli.json),
        Cmd::Explain {
            principal,
            action,
            resource,
        } => {
            let p = find_principal(&fleet, principal)?;
            let r = fleet
                .policy_catalog
                .resources
                .iter()
                .find(|r| r.id == *resource)
                .ok_or_else(|| CliError::NotFound {
                    kind: "resource",
                    id: resource.clone(),
                })?;
            let resp = authorize(&fleet.policy_catalog.policies, &p, action, r);
            if cli.json {
                println!("{}", serde_json::to_string_pretty(&resp)?);
            } else {
                println!(
                    "Decision: {:?} | principal={} action={} resource={} | determining_policies={:?}",
                    resp.decision, p.id, action, r.id, resp.determining_policies
                );
            }
            Ok(resp.decision == Decision::Allow)
        }
        Cmd::BlastRadius { principal, action } => {
            let p = find_principal(&fleet, principal)?;
            let exposed = blast_radius(
                &fleet.policy_catalog.policies,
                &p,
                action,
                &fleet.policy_catalog.resources,
            );
            if cli.json {
                println!(
                    "{}",
                    serde_json::to_string_pretty(&serde_json::json!({
                        "principal": p.id,
                        "action": action,
                        "exposedResources": exposed,
                    }))?
                );
            } else {
                println!("Blast radius for {} ({}): {:?}", p.id, action, exposed);
            }
            Ok(true)
        }
        Cmd::Resolve { target } => {
            let resolved =
                resolve_target_bindings(&fleet, target).ok_or_else(|| CliError::NotFound {
                    kind: "root target",
                    id: target.clone(),
                })?;
            println!("{}", serde_json::to_string_pretty(&resolved)?);
            Ok(true)
        }
        Cmd::Drt {
            oracle,
            cases,
            seed,
        } => run_drt(&fleet, oracle, *cases, *seed, cli.json),
    }
}

fn main() -> ExitCode {
    let cli = Cli::parse();
    match run(&cli) {
        Ok(true) => ExitCode::SUCCESS,
        Ok(false) => ExitCode::FAILURE,
        Err(err) => {
            eprintln!("aky error: {err}");
            ExitCode::FAILURE
        }
    }
}
