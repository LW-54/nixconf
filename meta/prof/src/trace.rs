use crate::flamegraph::{
    merge_and_analyze_folded, write_speedscope_json, write_svg_flamegraph, ProfileSummary,
};
use crate::shim::NixInvocationRecord;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::env;
use std::fs;
use std::os::unix::fs::symlink;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::{Instant, SystemTime, UNIX_EPOCH};

pub struct TraceOpts {
    pub cold: bool,
    pub freq: u32,
    pub out: Option<PathBuf>,
    pub name: String,
    pub svg: bool,
    pub speedscope: bool,
    pub quiet: bool,
    pub verbose_nix: bool,
    pub cmd: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ResourceUsage {
    pub user_cpu_s: f64,
    pub sys_cpu_s: f64,
    pub max_rss_mb: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BuildSpanSummary {
    pub kind: String,
    pub target: String,
    pub duration_s: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TraceReport {
    pub report_type: String,
    pub name: String,
    pub timestamp: u64,
    pub command: Vec<String>,
    pub exit_code: i32,
    pub wall_s: f64,
    pub rusage: ResourceUsage,
    pub nix_invocation_count: usize,
    pub nix_total_wall_s: f64,
    pub nix_total_cpu_s: f64,
    pub nix_total_gc_s: f64,
    pub nix_total_alloc_mb: f64,
    pub nix_total_fn_calls: u64,
    pub phase_totals_s: HashMap<String, f64>,
    pub slowest_activities: Vec<BuildSpanSummary>,
    pub invocations: Vec<NixInvocationRecord>,
    pub eval_profile: ProfileSummary,
    pub artifacts: HashMap<String, String>,
}

fn find_in_path(binary: &str) -> Option<PathBuf> {
    let path_var = env::var_os("PATH")?;
    for dir in env::split_paths(&path_var) {
        let candidate = dir.join(binary);
        if candidate.is_file() {
            return Some(candidate);
        }
    }
    None
}

fn get_children_rusage() -> ResourceUsage {
    unsafe {
        let mut ru: libc::rusage = std::mem::zeroed();
        if libc::getrusage(libc::RUSAGE_CHILDREN, &mut ru) == 0 {
            let user_s = ru.ru_utime.tv_sec as f64 + (ru.ru_utime.tv_usec as f64 / 1_000_000.0);
            let sys_s = ru.ru_stime.tv_sec as f64 + (ru.ru_stime.tv_usec as f64 / 1_000_000.0);
            // On Linux ru_maxrss is in KiB
            let rss_mb = (ru.ru_maxrss as f64) / 1024.0;
            return ResourceUsage {
                user_cpu_s: (user_s * 10000.0).round() / 10000.0,
                sys_cpu_s: (sys_s * 10000.0).round() / 10000.0,
                max_rss_mb: (rss_mb * 10.0).round() / 10.0,
            };
        }
    }
    ResourceUsage {
        user_cpu_s: 0.0,
        sys_cpu_s: 0.0,
        max_rss_mb: 0.0,
    }
}

fn git_root_string() -> String {
    Command::new("git")
        .args(["rev-parse", "--show-toplevel"])
        .output()
        .ok()
        .filter(|o| o.status.success())
        .map(|o| String::from_utf8_lossy(&o.stdout).trim().to_string())
        .unwrap_or_default()
}

pub fn run(opts: TraceOpts) -> Result<i32, String> {
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    let out_dir = match opts.out {
        Some(p) => p,
        None => PathBuf::from(format!(".bench/traces/{}-{ts}", opts.name)),
    };
    fs::create_dir_all(&out_dir).map_err(|e| format!("create output dir: {e}"))?;

    let shim_dir = out_dir.join(".shim");
    fs::create_dir_all(&shim_dir).map_err(|e| format!("create shim dir: {e}"))?;

    let current_exe = env::current_exe().map_err(|e| format!("current_exe: {e}"))?;
    let nix_shim_path = shim_dir.join("nix");
    let _ = fs::remove_file(&nix_shim_path);
    symlink(&current_exe, &nix_shim_path).map_err(|e| format!("symlink nix shim: {e}"))?;

    let real_nix = find_in_path("nix")
        .map(|p| p.to_string_lossy().into_owned())
        .unwrap_or_else(|| "nix".to_string());

    let orig_path = env::var("PATH").unwrap_or_default();
    let new_path = format!("{}:{}", shim_dir.to_string_lossy(), orig_path);

    let origin_ms = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs_f64()
        * 1000.0;

    let prog = &opts.cmd[0];
    let prog_args = &opts.cmd[1..];

    let t0 = Instant::now();
    let status = Command::new(prog)
        .args(prog_args)
        .env("PATH", new_path)
        .env("NIXPROF_SESSION_DIR", &out_dir)
        .env("NIXPROF_REAL_NIX", &real_nix)
        .env("NIXPROF_ORIGIN_MS", format!("{origin_ms:.3}"))
        .env("NIXPROF_FREQ", opts.freq.to_string())
        .env("NIXPROF_COLD", if opts.cold { "1" } else { "0" })
        .env(
            "NIXPROF_VERBOSE_NIX",
            if opts.verbose_nix { "1" } else { "0" },
        )
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .map_err(|e| format!("failed to execute `{prog}`: {e}"))?;
    let wall_s = t0.elapsed().as_secs_f64();
    let exit_code = status.code().unwrap_or(1);
    let rusage = get_children_rusage();

    // Clean up shim symlink directory
    let _ = fs::remove_dir_all(&shim_dir);

    // Collect all intercepted nix invocations
    let inv_dir = out_dir.join("invocations");
    let mut invocations: Vec<NixInvocationRecord> = Vec::new();
    if inv_dir.exists() {
        let mut entries: Vec<PathBuf> = fs::read_dir(&inv_dir)
            .map_err(|e| format!("read invocations dir: {e}"))?
            .filter_map(Result::ok)
            .map(|e| e.path())
            .filter(|p| {
                p.file_name()
                    .and_then(|n| n.to_str())
                    .map(|n| n.ends_with(".meta.json"))
                    .unwrap_or(false)
            })
            .collect();
        entries.sort();
        for p in entries {
            if let Ok(raw) = fs::read_to_string(&p) {
                if let Ok(rec) = serde_json::from_str::<NixInvocationRecord>(&raw) {
                    invocations.push(rec);
                }
            }
        }
    }

    // Aggregate stats & phase totals
    let mut nix_total_wall_s = 0.0;
    let mut nix_total_cpu_s = 0.0;
    let mut nix_total_gc_s = 0.0;
    let mut nix_total_alloc_mb = 0.0;
    let mut nix_total_fn_calls = 0u64;
    let mut phase_totals_ms: HashMap<String, f64> = HashMap::new();
    let mut all_spans: Vec<BuildSpanSummary> = Vec::new();
    let mut profile_paths: Vec<PathBuf> = Vec::new();

    for inv in &invocations {
        nix_total_wall_s += inv.wall_s;
        if let Some(st) = &inv.stats {
            nix_total_cpu_s += st.cpu_s;
            nix_total_gc_s += st.gc_s;
            nix_total_alloc_mb += st.total_alloc_mb;
            nix_total_fn_calls += st.nr_function_calls;
        }
        for (k, v) in &inv.phase_totals_ms {
            *phase_totals_ms.entry(k.clone()).or_insert(0.0) += *v;
        }
        for act in &inv.activities {
            if act.duration_ms >= 20.0
                && matches!(
                    act.kind.as_str(),
                    "build" | "substitute" | "copyPath" | "fetchTree" | "fileTransfer"
                )
            {
                all_spans.push(BuildSpanSummary {
                    kind: act.kind.clone(),
                    target: act.drv.clone().unwrap_or_else(|| act.text.clone()),
                    duration_s: (act.duration_ms / 10.0).round() / 100.0,
                });
            }
        }
        if let Some(pf) = &inv.profile_file {
            let p = PathBuf::from(pf);
            if p.exists() {
                profile_paths.push(p);
            }
        }
    }

    all_spans.sort_by(|a, b| b.duration_s.total_cmp(&a.duration_s));
    all_spans.truncate(20);

    let phase_totals_s: HashMap<String, f64> = phase_totals_ms
        .into_iter()
        .map(|(k, v)| (k, (v / 10.0).round() / 100.0))
        .collect();

    let repo_root = git_root_string();
    let pf_refs: Vec<&Path> = profile_paths.iter().map(PathBuf::as_path).collect();
    let (folded_lines, eval_profile) = merge_and_analyze_folded(&pf_refs, &repo_root);

    let mut artifacts: HashMap<String, String> = HashMap::new();

    if !folded_lines.is_empty() {
        let folded_out = out_dir.join("eval.folded");
        fs::write(&folded_out, folded_lines.join("\n") + "\n")
            .map_err(|e| format!("write folded: {e}"))?;
        artifacts.insert(
            "folded".into(),
            folded_out.to_string_lossy().into_owned(),
        );

        if opts.svg {
            let svg_out = out_dir.join("eval-flamegraph.svg");
            write_svg_flamegraph(
                &folded_lines,
                &format!("nixprof eval flamegraph: {}", opts.name),
                &svg_out,
            )?;
            artifacts.insert("svg".into(), svg_out.to_string_lossy().into_owned());
        }
    }

    if opts.speedscope && (!invocations.is_empty() || !folded_lines.is_empty()) {
        let ss_out = out_dir.join("timeline.speedscope.json");
        write_speedscope_json(
            &opts.name,
            wall_s * 1000.0,
            &invocations,
            &folded_lines,
            opts.freq,
            &ss_out,
        )?;
        artifacts.insert("speedscope".into(), ss_out.to_string_lossy().into_owned());
    }

    let report_path = out_dir.join("report.json");
    artifacts.insert("report".into(), report_path.to_string_lossy().into_owned());

    let report = TraceReport {
        report_type: "trace".into(),
        name: opts.name.clone(),
        timestamp: ts,
        command: opts.cmd.clone(),
        exit_code,
        wall_s: (wall_s * 10000.0).round() / 10000.0,
        rusage,
        nix_invocation_count: invocations.len(),
        nix_total_wall_s: (nix_total_wall_s * 10000.0).round() / 10000.0,
        nix_total_cpu_s: (nix_total_cpu_s * 10000.0).round() / 10000.0,
        nix_total_gc_s: (nix_total_gc_s * 10000.0).round() / 10000.0,
        nix_total_alloc_mb: (nix_total_alloc_mb * 10.0).round() / 10.0,
        nix_total_fn_calls,
        phase_totals_s,
        slowest_activities: all_spans,
        invocations,
        eval_profile,
        artifacts,
    };

    let json = serde_json::to_string_pretty(&report).map_err(|e| format!("serialize report: {e}"))?;
    fs::write(&report_path, json).map_err(|e| format!("write report: {e}"))?;

    if !opts.quiet {
        print_trace_summary(&report);
    }

    Ok(exit_code)
}

fn bar(frac: f64, width: usize) -> String {
    let filled = ((frac.clamp(0.0, 1.0)) * (width as f64)).round() as usize;
    format!("{}{}", "█".repeat(filled), "░".repeat(width.saturating_sub(filled)))
}

fn print_trace_summary(r: &TraceReport) {
    eprintln!("\n══════════════════════════════════════════════════════════════════════════════");
    eprintln!(
        " nixprof trace: {}  |  wall={:.2}s  exit={}  cpu={:.2}s+{:.2}s  rss={:.0}MB",
        r.name, r.wall_s, r.exit_code, r.rusage.user_cpu_s, r.rusage.sys_cpu_s, r.rusage.max_rss_mb
    );
    eprintln!("══════════════════════════════════════════════════════════════════════════════");

    if !r.invocations.is_empty() {
        eprintln!(
            "\n[Nix Invocations: {}  |  sum_wall={:.2}s  eval_cpu={:.2}s  gc={:.2}s  alloc={:.0}MB  fn_calls={}]",
            r.nix_invocation_count,
            r.nix_total_wall_s,
            r.nix_total_cpu_s,
            r.nix_total_gc_s,
            r.nix_total_alloc_mb,
            r.nix_total_fn_calls
        );
        for inv in &r.invocations {
            let frac = if r.wall_s > 0.0 {
                inv.wall_s / r.wall_s
            } else {
                0.0
            };
            let cmd_preview: String = inv
                .args
                .iter()
                .take(5)
                .cloned()
                .collect::<Vec<_>>()
                .join(" ");
            let alloc_str = inv
                .stats
                .as_ref()
                .map(|s| format!("cpu={:.2}s gc={:.0}% alloc={:.0}MB", s.cpu_s, s.gc_fraction * 100.0, s.total_alloc_mb))
                .unwrap_or_default();
            eprintln!(
                "  #{:02} {:6.2}s {} nix {}  ({})",
                inv.id,
                inv.wall_s,
                bar(frac, 16),
                cmd_preview,
                alloc_str
            );
        }
    }

    if !r.phase_totals_s.is_empty() {
        let mut phases: Vec<(&String, &f64)> = r.phase_totals_s.iter().collect();
        phases.sort_by(|a, b| b.1.total_cmp(a.1));
        eprintln!("\n[Nix Activity Phase Totals (cumulative across parallel ops)]");
        for (k, v) in phases.iter().take(10) {
            if **v >= 0.01 {
                eprintln!("  {:<18} {:7.2}s", k, v);
            }
        }
    }

    if !r.slowest_activities.is_empty() {
        eprintln!("\n[Slowest Individual Builds / Substitutions / Copies]");
        for sp in r.slowest_activities.iter().take(10) {
            eprintln!("  {:6.2}s  [{:<10}] {}", sp.duration_s, sp.kind, sp.target);
        }
    }

    if r.eval_profile.total_samples > 0 {
        eprintln!(
            "\n[Nix Eval Flamegraph Breakdown ({} samples)]",
            r.eval_profile.total_samples
        );
        eprintln!("  By area (self% / incl%):");
        for a in r.eval_profile.by_area.iter().take(10) {
            eprintln!(
                "    {:<28} self={:5.1}% {} incl={:5.1}%",
                a.area,
                a.self_pct,
                bar(a.self_pct / 100.0, 14),
                a.incl_pct
            );
        }
        eprintln!("  Top self frames:");
        for f in r.eval_profile.top_self.iter().take(10) {
            eprintln!("    {:5.1}%  {}", f.pct, f.frame);
        }
    }

    eprintln!("\n[Artifacts]");
    let mut keys: Vec<&String> = r.artifacts.keys().collect();
    keys.sort();
    for k in keys {
        eprintln!("  {:<12}: {}", k, r.artifacts[k]);
    }
}
