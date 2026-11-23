use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::HashMap;
use std::env;
use std::fs::{self, OpenOptions};
use std::io::{BufRead, BufReader, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::{SystemTime, UNIX_EPOCH};

/// Nix internal-json activity types (from Nix libutil/logging.hh)
pub fn activity_type_name(code: i64) -> &'static str {
    match code {
        0 => "unknown",
        100 => "copyPath",
        101 => "fileTransfer",
        102 => "realise",
        103 => "copyPaths",
        104 => "builds",
        105 => "build",
        106 => "optimiseStore",
        107 => "verifyPaths",
        108 => "substitute",
        109 => "queryPathInfo",
        110 => "postBuildHook",
        111 => "buildWaiting",
        112 => "fetchTree",
        _ => "other",
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NixActivity {
    pub id: u64,
    pub parent: u64,
    pub kind: String,
    pub text: String,
    pub drv: Option<String>,
    pub start_ms: f64,
    pub end_ms: f64,
    pub duration_ms: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct NixStatsSummary {
    pub cpu_s: f64,
    pub gc_s: f64,
    pub gc_fraction: f64,
    pub gc_cycles: u64,
    pub heap_mb: f64,
    pub total_alloc_mb: f64,
    pub nr_function_calls: u64,
    pub nr_thunks: u64,
    pub nr_primop_calls: u64,
    pub nr_op_updates: u64,
    pub nr_op_update_values_copied: u64,
    pub list_concats: u64,
    pub nr_lookups: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NixInvocationRecord {
    pub id: u64,
    pub pid: u32,
    pub subcommand: String,
    pub args: Vec<String>,
    pub cwd: String,
    pub start_ms: f64,
    pub end_ms: f64,
    pub wall_s: f64,
    pub exit_code: i32,
    pub stats: Option<NixStatsSummary>,
    pub profile_file: Option<String>,
    pub activities: Vec<NixActivity>,
    pub phase_totals_ms: HashMap<String, f64>,
}

fn now_ms_since(origin_ms: f64) -> f64 {
    let dur = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default();
    dur.as_secs_f64() * 1000.0 - origin_ms
}

fn next_invocation_id(session_dir: &Path) -> u64 {
    let counter_dir = session_dir.join("counters");
    let _ = fs::create_dir_all(&counter_dir);
    for idx in 1..100_000u64 {
        let marker = counter_dir.join(format!("{idx:05}"));
        if OpenOptions::new().write(true).create_new(true).open(&marker).is_ok() {
            return idx;
        }
    }
    99999
}

fn find_subcommand(args: &[String]) -> Option<(usize, String)> {
    let mut i = 0;
    while i < args.len() {
        let a = &args[i];
        if a == "--" {
            return None;
        }
        if a.starts_with('-') {
            // Skip known flags that take a separate argument
            if matches!(
                a.as_str(),
                "--option" | "--extra-experimental-features" | "--experimental-features" | "--store" | "--eval-store" | "-I" | "--arg" | "--argstr" | "--override-input" | "--log-format"
            ) {
                if a == "--option" || a == "--arg" || a == "--argstr" || a == "--override-input" {
                    i += 3;
                } else {
                    i += 2;
                }
                continue;
            }
            i += 1;
            continue;
        }
        return Some((i, a.clone()));
    }
    None
}

fn subcommand_supports_eval_profiler(sub: &str) -> bool {
    matches!(
        sub,
        "eval" | "build" | "flake" | "run" | "develop" | "shell" | "fmt" | "search" | "path-info"
    )
}

fn subcommand_supports_internal_json(sub: &str) -> bool {
    !matches!(sub, "repl" | "edit" | "help" | "doctor")
}

fn parse_nix_stats(path: &Path) -> Option<NixStatsSummary> {
    let raw = fs::read_to_string(path).ok()?;
    let v: Value = serde_json::from_str(&raw).ok()?;
    Some(NixStatsSummary {
        cpu_s: v.get("cpuTime").and_then(Value::as_f64).unwrap_or(0.0),
        gc_s: v
            .pointer("/time/gc")
            .and_then(Value::as_f64)
            .unwrap_or(0.0),
        gc_fraction: v
            .pointer("/time/gcFraction")
            .and_then(Value::as_f64)
            .unwrap_or(0.0),
        gc_cycles: v
            .pointer("/gc/cycles")
            .and_then(Value::as_u64)
            .unwrap_or(0),
        heap_mb: v
            .pointer("/gc/heapSize")
            .and_then(Value::as_f64)
            .unwrap_or(0.0)
            / (1024.0 * 1024.0),
        total_alloc_mb: v
            .pointer("/gc/totalBytes")
            .and_then(Value::as_f64)
            .unwrap_or(0.0)
            / (1024.0 * 1024.0),
        nr_function_calls: v.get("nrFunctionCalls").and_then(Value::as_u64).unwrap_or(0),
        nr_thunks: v.get("nrThunks").and_then(Value::as_u64).unwrap_or(0),
        nr_primop_calls: v.get("nrPrimOpCalls").and_then(Value::as_u64).unwrap_or(0),
        nr_op_updates: v.get("nrOpUpdates").and_then(Value::as_u64).unwrap_or(0),
        nr_op_update_values_copied: v
            .get("nrOpUpdateValuesCopied")
            .and_then(Value::as_u64)
            .unwrap_or(0),
        list_concats: v
            .pointer("/list/concats")
            .and_then(Value::as_u64)
            .unwrap_or(0),
        nr_lookups: v.get("nrLookups").and_then(Value::as_u64).unwrap_or(0),
    })
}

fn extract_drv_from_fields(fields: &[Value], text: &str) -> Option<String> {
    for f in fields {
        if let Some(s) = f.as_str() {
            if s.starts_with("/nix/store/") {
                return Some(
                    Path::new(s)
                        .file_name()
                        .map(|n| n.to_string_lossy().into_owned())
                        .unwrap_or_else(|| s.to_string()),
                );
            }
        }
    }
    if let Some(idx) = text.find("/nix/store/") {
        let rest = &text[idx..];
        let tok = rest
            .split(|c: char| c.is_whitespace() || c == '\'' || c == '"')
            .next()
            .unwrap_or("");
        if !tok.is_empty() {
            return Some(
                Path::new(tok)
                    .file_name()
                    .map(|n| n.to_string_lossy().into_owned())
                    .unwrap_or_else(|| tok.to_string()),
            );
        }
    }
    None
}

pub fn run_shim() -> i32 {
    let session_dir = PathBuf::from(env::var("NIXPROF_SESSION_DIR").unwrap_or_default());
    let real_nix = env::var("NIXPROF_REAL_NIX").unwrap_or_else(|_| "nix".to_string());
    let origin_ms: f64 = env::var("NIXPROF_ORIGIN_MS")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(0.0);
    let freq = env::var("NIXPROF_FREQ").unwrap_or_else(|_| "500".to_string());
    let cold = env::var("NIXPROF_COLD").map(|v| v == "1").unwrap_or(false);
    let verbose_nix = env::var("NIXPROF_VERBOSE_NIX")
        .map(|v| v == "1")
        .unwrap_or(false);

    let orig_args: Vec<String> = env::args().skip(1).collect();
    let inv_id = next_invocation_id(&session_dir);
    let inv_dir = session_dir.join("invocations");
    let _ = fs::create_dir_all(&inv_dir);

    let stats_path = inv_dir.join(format!("inv-{inv_id:04}.stats.json"));
    let profile_path = inv_dir.join(format!("inv-{inv_id:04}.folded"));
    let meta_path = inv_dir.join(format!("inv-{inv_id:04}.meta.json"));

    let sub_info = find_subcommand(&orig_args);
    let subcommand = sub_info
        .as_ref()
        .map(|(_, s)| s.clone())
        .unwrap_or_else(|| "unknown".to_string());

    let inject_eval = subcommand_supports_eval_profiler(&subcommand);
    let inject_json = subcommand_supports_internal_json(&subcommand)
        && !orig_args.iter().any(|a| a == "--log-format");

    // Build augmented argument list, inserting flags safely before any `--`
    let mut final_args: Vec<String> = Vec::with_capacity(orig_args.len() + 12);
    let split_pos = orig_args
        .iter()
        .position(|a| a == "--")
        .unwrap_or(orig_args.len());

    final_args.extend_from_slice(&orig_args[..split_pos]);

    if inject_json {
        final_args.push("--log-format".into());
        final_args.push("internal-json".into());
    }
    if inject_eval {
        if cold && !orig_args.iter().any(|a| a == "--no-eval-cache") {
            final_args.push("--no-eval-cache".into());
        }
        final_args.push("--option".into());
        final_args.push("eval-profiler".into());
        final_args.push("flamegraph".into());
        final_args.push("--option".into());
        final_args.push("eval-profiler-frequency".into());
        final_args.push(freq);
        final_args.push("--option".into());
        final_args.push("eval-profile-file".into());
        final_args.push(profile_path.to_string_lossy().into_owned());
    }

    if split_pos < orig_args.len() {
        final_args.extend_from_slice(&orig_args[split_pos..]);
    }

    let start_ms = now_ms_since(origin_ms);
    let mut cmd = Command::new(&real_nix);
    cmd.args(&final_args)
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(if inject_json {
            Stdio::piped()
        } else {
            Stdio::inherit()
        });

    if inject_eval {
        cmd.env("NIX_SHOW_STATS", "1");
        cmd.env("NIX_SHOW_STATS_PATH", &stats_path);
    }

    let mut child = match cmd.spawn() {
        Ok(c) => c,
        Err(e) => {
            eprintln!("nixprof shim: failed to exec {real_nix}: {e}");
            return 127;
        }
    };

    let child_pid = child.id();
    let mut active: HashMap<u64, (u64, String, String, Option<String>, f64)> = HashMap::new();
    let mut finished_activities: Vec<NixActivity> = Vec::new();
    let mut phase_totals_ms: HashMap<String, f64> = HashMap::new();

    if let Some(stderr) = child.stderr.take() {
        let reader = BufReader::new(stderr);
        let mut err_out = std::io::stderr();
        for line in reader.lines().map_while(Result::ok) {
            if let Some(json_part) = line.strip_prefix("@nix ") {
                if let Ok(v) = serde_json::from_str::<Value>(json_part) {
                    let action = v.get("action").and_then(Value::as_str).unwrap_or("");
                    let ts = now_ms_since(origin_ms);
                    match action {
                        "start" => {
                            let id = v.get("id").and_then(Value::as_u64).unwrap_or(0);
                            let parent = v.get("parent").and_then(Value::as_u64).unwrap_or(0);
                            let ty = v.get("type").and_then(Value::as_i64).unwrap_or(0);
                            let kind = activity_type_name(ty).to_string();
                            let text = v
                                .get("text")
                                .and_then(Value::as_str)
                                .unwrap_or("")
                                .to_string();
                            let fields = v
                                .get("fields")
                                .and_then(Value::as_array)
                                .cloned()
                                .unwrap_or_default();
                            let drv = extract_drv_from_fields(&fields, &text);
                            active.insert(id, (parent, kind, text, drv, ts));
                        }
                        "stop" => {
                            let id = v.get("id").and_then(Value::as_u64).unwrap_or(0);
                            if let Some((parent, kind, text, drv, s_ms)) = active.remove(&id) {
                                let dur = (ts - s_ms).max(0.0);
                                *phase_totals_ms.entry(kind.clone()).or_insert(0.0) += dur;
                                finished_activities.push(NixActivity {
                                    id,
                                    parent,
                                    kind,
                                    text,
                                    drv,
                                    start_ms: s_ms,
                                    end_ms: ts,
                                    duration_ms: dur,
                                });
                            }
                        }
                        "msg" => {
                            let level = v.get("level").and_then(Value::as_u64).unwrap_or(3);
                            let msg = v.get("msg").and_then(Value::as_str).unwrap_or("");
                            // Forward errors (0) and warnings (1), or everything if verbose
                            if level <= 1 || verbose_nix {
                                let _ = writeln!(err_out, "{msg}");
                            }
                        }
                        _ => {}
                    }
                }
            } else {
                // Always forward real tool stderr (e.g. from `nix run` target program!)
                let _ = writeln!(err_out, "{line}");
            }
        }
    }

    let status = child.wait();
    let end_ms = now_ms_since(origin_ms);
    let exit_code = status.map(|s| s.code().unwrap_or(1)).unwrap_or(1);

    // Close any unclosed activities at invocation end
    for (id, (parent, kind, text, drv, s_ms)) in active {
        let dur = (end_ms - s_ms).max(0.0);
        *phase_totals_ms.entry(kind.clone()).or_insert(0.0) += dur;
        finished_activities.push(NixActivity {
            id,
            parent,
            kind,
            text,
            drv,
            start_ms: s_ms,
            end_ms,
            duration_ms: dur,
        });
    }

    let stats = if stats_path.exists() {
        parse_nix_stats(&stats_path)
    } else {
        None
    };

    let record = NixInvocationRecord {
        id: inv_id,
        pid: child_pid,
        subcommand,
        args: orig_args,
        cwd: env::current_dir()
            .map(|p| p.to_string_lossy().into_owned())
            .unwrap_or_default(),
        start_ms,
        end_ms,
        wall_s: ((end_ms - start_ms).max(0.0)) / 1000.0,
        exit_code,
        stats,
        profile_file: if profile_path.exists() {
            Some(profile_path.to_string_lossy().into_owned())
        } else {
            None
        },
        activities: finished_activities,
        phase_totals_ms,
    };

    if let Ok(json) = serde_json::to_string_pretty(&record) {
        let _ = fs::write(&meta_path, json);
    }

    exit_code
}
