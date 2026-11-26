//! **Baugr (`baugr`)** — Pure, zero-Nix, usage-agnostic Promise Theory & Semantic Spacetime
//! compiler CLI, Cedar policy explainer, `S1` binding resolver, and Lean 4 DRT runner.
//!
//! Supports arbitrary repeatable `--root <dir>` overlays with recursive `agents/**` discovery
//! so organizational folders and cross-repo agent libraries compose fractally with zero barriers.

use std::collections::BTreeMap;
use std::fs;
use std::io::{BufRead, BufReader, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode, Stdio};
use std::time::Instant;

use baugr_core::authority::{Decision, Entity, authorize, blast_radius};
use baugr_core::drt::{OracleRequest, OracleResponse, eval_request, generate_fuzzed_cases};
use baugr_core::fleet::{
    AgentManifest, FleetSpec, PolicyCatalog, ProfileManifest, derive_principals, derive_resources,
    project_policy_matrix, resolve_target_bindings, superagent_to_oracle_request, verify_fleet,
};
use baugr_core::spacetime::{StType, edge_counts, project_fleet_sst, reverse_impact_cone};
use clap::{Parser, Subcommand};
use thiserror::Error;

/// Baugr usage-agnostic Promise Theory & Semantic Spacetime compiler CLI.
#[derive(Debug, Parser)]
#[command(
    name = "baugr",
    version,
    about = "Baugr Promise Theory & Semantic Spacetime verifier"
)]
struct Cli {
    /// One or more root directories containing `agents/`, `profiles/`, and/or `policies/`.
    /// Overlays merge in order (later roots override matching IDs; `agents/**` discovered recursively).
    #[arg(long = "root", global = true)]
    roots: Vec<PathBuf>,

    /// Emit machine-readable JSON output for Unix pipes, CI & AI agents.
    #[arg(long, global = true)]
    json: bool,

    #[command(subcommand)]
    command: Cmd,
}

#[derive(Debug, Subcommand)]
enum Cmd {
    /// Verify all Dressed Superagents, atomic principals, B3 scopes, and declarative invariants.
    Check,
    /// Explain a Cedar L3+ authorization verdict including `determiningPolicies`.
    Explain {
        /// Principal ID from `policies/*.toml` or `agents/**/agent.toml`.
        principal: String,
        /// Action name.
        action: String,
        /// Resource ID.
        resource: String,
    },
    /// Compute the exact sound-and-complete blast radius for a principal & action.
    BlastRadius {
        /// Principal ID to audit.
        principal: String,
        /// Action name.
        action: String,
    },
    /// Project deterministic Cedar L3+ authorization matrix for an action across all principals & resources.
    Project {
        /// Action name to project.
        action: String,
    },
    /// Project the 4-link Semantic Spacetime γ(3,4) graph and optional causal impact cone.
    Graph {
        /// Optional node ID whose reverse operational `FOLLOWS` impact cone should be computed.
        #[arg(long)]
        impact: Option<String>,
        /// Maximum traversal depth for impact cone (default: 8).
        #[arg(long, default_value_t = 8)]
        depth: usize,
    },
    /// Emit deterministic S1 `bound` JSON for any Dressed Superagent.
    Resolve {
        /// Superagent identifier.
        target: String,
    },
    /// Run AWS Cedar Differential Randomized Testing comparing `baugr-core` against `baugr-oracle`.
    Drt {
        /// Path to the compiled Lean 4 `baugr-oracle` binary.
        #[arg(long)]
        oracle: PathBuf,
        /// Number of deterministic randomized fuzzed cases to test in addition to real superagents.
        #[arg(long, default_value_t = 500)]
        cases: usize,
        /// Deterministic PRNG seed.
        #[arg(long, default_value_t = 0xBA09_2026)]
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

/// Recursively collects all `agent.toml` (or standalone `*.toml`) manifests in sorted order.
fn walk_agents_dir(
    dir: &Path,
    agents: &mut BTreeMap<String, AgentManifest>,
) -> Result<(), CliError> {
    if !dir.is_dir() {
        return Ok(());
    }
    let mut entries: Vec<PathBuf> = fs::read_dir(dir)
        .map_err(|source| CliError::Io {
            path: dir.to_path_buf(),
            source,
        })?
        .collect::<Result<Vec<_>, _>>()
        .map_err(|source| CliError::Io {
            path: dir.to_path_buf(),
            source,
        })?
        .into_iter()
        .map(|e| e.path())
        .collect();
    entries.sort();

    for path in entries {
        if path.is_dir() {
            let candidate = path.join("agent.toml");
            if candidate.is_file() {
                let agent: AgentManifest = read_toml(&candidate)?;
                agents.insert(agent.id.clone(), agent);
            } else {
                walk_agents_dir(&path, agents)?;
            }
        } else if path.extension().and_then(|s| s.to_str()) == Some("toml")
            && path.file_name().and_then(|s| s.to_str()) != Some("agent.toml")
        {
            let agent: AgentManifest = read_toml(&path)?;
            agents.insert(agent.id.clone(), agent);
        }
    }
    Ok(())
}

fn walk_toml_files(dir: &Path, out: &mut Vec<PathBuf>) -> Result<(), CliError> {
    if !dir.is_dir() {
        return Ok(());
    }
    let mut entries: Vec<PathBuf> = fs::read_dir(dir)
        .map_err(|source| CliError::Io {
            path: dir.to_path_buf(),
            source,
        })?
        .collect::<Result<Vec<_>, _>>()
        .map_err(|source| CliError::Io {
            path: dir.to_path_buf(),
            source,
        })?
        .into_iter()
        .map(|e| e.path())
        .collect();
    entries.sort();

    for path in entries {
        if path.is_dir() {
            walk_toml_files(&path, out)?;
        } else if path.extension().and_then(|s| s.to_str()) == Some("toml") {
            out.push(path);
        }
    }
    Ok(())
}

fn load_fleet(roots: &[PathBuf]) -> Result<FleetSpec, CliError> {
    let default_root = [PathBuf::from(".")];
    let effective_roots: &[PathBuf] = if roots.is_empty() {
        &default_root
    } else {
        roots
    };

    let mut agents = BTreeMap::new();
    let mut profiles = BTreeMap::new();
    let mut policy_catalog = PolicyCatalog::default();

    for root in effective_roots {
        walk_agents_dir(&root.join("agents"), &mut agents)?;

        let mut profile_files = Vec::new();
        walk_toml_files(&root.join("profiles"), &mut profile_files)?;
        for path in profile_files {
            let prof: ProfileManifest = read_toml(&path)?;
            profiles.insert(prof.id.clone(), prof);
        }

        let mut policy_files = Vec::new();
        walk_toml_files(&root.join("policies"), &mut policy_files)?;
        for path in policy_files {
            let part: PolicyCatalog = read_toml(&path)?;
            policy_catalog.principals.extend(part.principals);
            policy_catalog.resources.extend(part.resources);
            policy_catalog.policies.extend(part.policies);
            policy_catalog.auth_bindings.extend(part.auth_bindings);
            policy_catalog.invariants.extend(part.invariants);
        }
    }

    Ok(FleetSpec {
        agents,
        profiles,
        policy_catalog,
    })
}

fn find_principal(fleet: &FleetSpec, id: &str) -> Result<Entity, CliError> {
    derive_principals(fleet)
        .into_iter()
        .find(|p| p.id == id)
        .ok_or_else(|| CliError::NotFound {
            kind: "principal",
            id: id.to_string(),
        })
}

fn find_resource(fleet: &FleetSpec, id: &str) -> Result<Entity, CliError> {
    derive_resources(fleet, None)
        .into_iter()
        .find(|r| r.id == id)
        .ok_or_else(|| CliError::NotFound {
            kind: "resource",
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
            "DRT: {}/{} cases matched bit-for-bit ({} real superagents + {} fuzzed | checker+resolve+SST+Cedar) | Rust: {:.2} ms | Lean 4 oracle: {:.2} ms",
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
            println!(
                "[{status}] superagent={} children={}",
                sr.agent_id,
                sr.direct_children.len()
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
            for inv in &sr.invariant_errors {
                eprintln!("  invariant: {inv:?}");
            }
            for auth in &sr.auth_errors {
                eprintln!("  auth: {auth:?}");
            }
            if !sr.tree_valid {
                eprintln!("  tree: recursive Agent tree verification failed");
            }
        }
        for inv in &report.atomic_invariant_errors {
            eprintln!("  atomic-invariant: {inv:?}");
        }
        for auth in &report.atomic_auth_errors {
            eprintln!("  atomic-auth: {auth:?}");
        }
        println!(
            "Self-contained agents: [{}] | verified in {elapsed_ms:.2} ms",
            report.self_contained_agents.join(", ")
        );
    }
    Ok(report.is_valid())
}

fn run(cli: &Cli) -> Result<bool, CliError> {
    let t0 = Instant::now();
    let fleet = load_fleet(&cli.roots)?;

    match &cli.command {
        Cmd::Check => run_check(&fleet, t0.elapsed().as_secs_f64() * 1000.0, cli.json),
        Cmd::Explain {
            principal,
            action,
            resource,
        } => {
            let p = find_principal(&fleet, principal)?;
            let r = find_resource(&fleet, resource)?;
            let resp = authorize(&fleet.policy_catalog.policies, &p, action, &r);
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
            let all_resources = derive_resources(&fleet, Some(action));
            let exposed = blast_radius(&fleet.policy_catalog.policies, &p, action, &all_resources);
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
        Cmd::Project { action } => {
            let matrix = project_policy_matrix(&fleet, action);
            if cli.json {
                println!("{}", serde_json::to_string_pretty(&matrix)?);
            } else {
                for (principal_id, res_ids) in &matrix {
                    println!("{principal_id} ({action}) => [{}]", res_ids.join(", "));
                }
            }
            Ok(true)
        }
        Cmd::Graph { impact, depth } => {
            let graph = project_fleet_sst(&fleet);
            let counts = edge_counts(&graph);
            let impact_nodes = impact
                .as_deref()
                .map(|node| reverse_impact_cone(&graph, *depth, node));
            if cli.json {
                println!(
                    "{}",
                    serde_json::to_string_pretty(&serde_json::json!({
                        "nodes": graph.nodes.len(),
                        "edges": graph.edges.len(),
                        "counts": counts,
                        "impactCone": impact_nodes,
                        "graph": graph,
                    }))?
                );
            } else {
                println!(
                    "SST γ(3,4): nodes={} edges={} | CONTAINS={} FOLLOWS={} EXPRESSES={} NEAR={}",
                    graph.nodes.len(),
                    graph.edges.len(),
                    counts.get(&StType::Contains).copied().unwrap_or(0),
                    counts.get(&StType::Follows).copied().unwrap_or(0),
                    counts.get(&StType::Expresses).copied().unwrap_or(0),
                    counts.get(&StType::Near).copied().unwrap_or(0),
                );
                if let (Some(node), Some(cone)) = (impact.as_deref(), impact_nodes) {
                    println!("Impact cone ({node}): [{}]", cone.join(", "));
                }
            }
            Ok(true)
        }
        Cmd::Resolve { target } => {
            let resolved =
                resolve_target_bindings(&fleet, target).ok_or_else(|| CliError::NotFound {
                    kind: "superagent",
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
            eprintln!("baugr error: {err}");
            ExitCode::FAILURE
        }
    }
}
