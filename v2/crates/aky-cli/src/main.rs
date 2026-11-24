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
    AgentManifest, FleetSpec, HostManifest, PolicyCatalog, ProfileManifest, host_to_oracle_request,
    resolve_host_bindings, verify_fleet,
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
    /// Root directory of the Antikythera fleet (`agents/`, `profiles/`, `policies/`, `hosts/`).
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
    /// Verify all hosts, budgets, non-piercing boundaries, open state traits, and standalone agents.
    Check,
    /// Explain a Cedar L3+ authorization verdict including `determiningPolicies`.
    Explain {
        /// Principal ID from `policies/*.toml` or `hosts/*.toml`.
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
    /// Emit deterministic S1 `bound` + `persistent_paths` JSON for a host (CI equivalence test).
    Resolve {
        /// Host identifier.
        host: String,
    },
    /// Run AWS Cedar Differential Randomized Testing comparing `aky-core` against `aky-oracle`.
    Drt {
        /// Path to the compiled Lean 4 `aky-oracle` binary.
        #[arg(long)]
        oracle: PathBuf,
        /// Number of deterministic randomized fuzzed fleets to test in addition to real repo hosts.
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

    let mut hosts = BTreeMap::new();
    let hosts_dir = root.join("hosts");
    if hosts_dir.is_dir() {
        for entry in fs::read_dir(&hosts_dir).map_err(|source| CliError::Io {
            path: hosts_dir.clone(),
            source,
        })? {
            let entry = entry.map_err(|source| CliError::Io {
                path: hosts_dir.clone(),
                source,
            })?;
            let path = entry.path();
            if path.extension().and_then(|s| s.to_str()) == Some("toml") && path.is_file() {
                let host: HostManifest = read_toml(&path)?;
                hosts.insert(host.id.clone(), host);
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
        hosts,
        policy_catalog,
    })
}

fn find_principal(fleet: &FleetSpec, id: &str) -> Result<Entity, CliError> {
    if let Some(p) = fleet.policy_catalog.principals.iter().find(|p| p.id == id) {
        return Ok(p.clone());
    }
    if let Some(h) = fleet.hosts.get(id) {
        return Ok(Entity {
            id: h.id.clone(),
            tags: h.attributes.clone(),
        });
    }
    Err(CliError::NotFound {
        kind: "principal",
        id: id.to_string(),
    })
}

fn run_drt(
    fleet: &FleetSpec,
    oracle_path: &Path,
    fuzzed_count: usize,
    seed: u64,
    as_json: bool,
) -> Result<bool, CliError> {
    let mut requests: Vec<(String, OracleRequest)> = Vec::new();
    for hid in fleet.hosts.keys() {
        if let Some(req) = host_to_oracle_request(fleet, hid) {
            requests.push((format!("fleet:{hid}"), req));
        }
    }
    for (idx, req) in generate_fuzzed_cases(seed, fuzzed_count)
        .into_iter()
        .enumerate()
    {
        requests.push((format!("fuzz:{idx}"), req));
    }

    // 1. Evaluate all cases in Rust `aky-core`
    let t_rust = Instant::now();
    let rust_results: Vec<OracleResponse> = requests.iter().map(|(_, r)| eval_request(r)).collect();
    let rust_ms = t_rust.elapsed().as_secs_f64() * 1000.0;

    // 2. Stream exact same NDJSON frames through Lean 4 `aky-oracle`
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
        for (_, req) in &requests {
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
    let lean_ms = t_lean.elapsed().as_secs_f64() * 1000.0;

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
                "realHosts": fleet.hosts.len(),
                "fuzzedCases": fuzzed_count,
                "divergences": divergences.len(),
                "rustMs": rust_ms,
                "leanMs": lean_ms,
                "passed": passed,
            }))?
        );
    } else {
        println!(
            "DRT: {}/{} cases matched bit-for-bit ({} real hosts + {} fuzzed) | Rust: {:.2} ms | Lean 4 oracle: {:.2} ms",
            requests.len().saturating_sub(divergences.len()),
            requests.len(),
            fleet.hosts.len(),
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
        for hr in report.hosts.values() {
            let status = if hr.is_valid() { "PASS" } else { "FAIL" };
            println!(
                "[{status}] host={} ({}) agents={} persisted={}",
                hr.host_id,
                hr.system,
                hr.resolved_agents.len(),
                hr.persistent_paths.len()
            );
            for m in &hr.missing_refs {
                eprintln!("  missing: {m}");
            }
            for b in &hr.binding_errors {
                eprintln!("  binding: {b:?}");
            }
            for c in &hr.boundary_errors {
                eprintln!("  boundary: {c:?}");
            }
            for s in &hr.state_errors {
                eprintln!("  state: {s:?}");
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
        Cmd::Resolve { host } => {
            let resolved =
                resolve_host_bindings(&fleet, host).ok_or_else(|| CliError::NotFound {
                    kind: "host",
                    id: host.clone(),
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
