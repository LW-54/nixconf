use crate::ci;
use serde_json::Value;
use std::fmt::Write as _;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{Instant, SystemTime, UNIX_EPOCH};

pub struct MetricsOpts {
    pub ci: bool,
    pub eval: bool,
    pub repo: Option<String>,
    pub limit: u32,
    pub attic_url: String,
    pub cachix_url: String,
    pub attic_dir: Option<PathBuf>,
    pub repo_dir: PathBuf,
    pub system: String,
    pub out: Option<PathBuf>,
}

fn prom_escape(s: &str) -> String {
    s.replace('\\', "\\\\")
        .replace('"', "\\\"")
        .replace('\n', "\\n")
}

fn probe_cache(url: &str) -> (bool, f64) {
    let target = format!("{}/nix-cache-info", url.trim_end_matches('/'));
    let out = Command::new("curl")
        .args([
            "-fsS",
            "--max-time",
            "8",
            "-o",
            "/dev/null",
            "-w",
            "%{time_total}",
            &target,
        ])
        .output();
    match out {
        Ok(o) if o.status.success() => {
            let secs = String::from_utf8_lossy(&o.stdout)
                .trim()
                .parse::<f64>()
                .unwrap_or(0.0);
            (true, secs)
        }
        _ => (false, 0.0),
    }
}

fn dir_size_and_count(root: &Path) -> (u64, u64) {
    let mut bytes = 0u64;
    let mut files = 0u64;
    let mut stack = vec![root.to_path_buf()];
    while let Some(dir) = stack.pop() {
        let Ok(entries) = fs::read_dir(&dir) else {
            continue;
        };
        for entry in entries.flatten() {
            let path = entry.path();
            let Ok(meta) = fs::symlink_metadata(&path) else {
                continue;
            };
            if meta.is_dir() {
                stack.push(path);
            } else if meta.is_file() {
                bytes = bytes.saturating_add(meta.len());
                files = files.saturating_add(1);
            }
        }
    }
    (bytes, files)
}

fn collect_ci_metrics(opts: &MetricsOpts, buf: &mut String) {
    let _ = writeln!(buf, "# HELP nixconf_ci_workflow_wall_seconds Latest completed GitHub Actions workflow wall-clock duration in seconds.");
    let _ = writeln!(buf, "# TYPE nixconf_ci_workflow_wall_seconds gauge");
    let _ = writeln!(buf, "# HELP nixconf_ci_workflow_runner_seconds Total cumulative runner seconds across all jobs in the latest workflow run.");
    let _ = writeln!(buf, "# TYPE nixconf_ci_workflow_runner_seconds gauge");
    let _ = writeln!(buf, "# HELP nixconf_ci_workflow_setup_seconds Cumulative setup/teardown seconds in the latest workflow run.");
    let _ = writeln!(buf, "# TYPE nixconf_ci_workflow_setup_seconds gauge");
    let _ = writeln!(buf, "# HELP nixconf_ci_workflow_work_seconds Cumulative build/test work seconds in the latest workflow run.");
    let _ = writeln!(buf, "# TYPE nixconf_ci_workflow_work_seconds gauge");
    let _ = writeln!(buf, "# HELP nixconf_ci_workflow_jobs Number of jobs in the latest workflow run.");
    let _ = writeln!(buf, "# TYPE nixconf_ci_workflow_jobs gauge");
    let _ = writeln!(buf, "# HELP nixconf_ci_workflow_success Whether the latest completed workflow run succeeded (1) or not (0).");
    let _ = writeln!(buf, "# TYPE nixconf_ci_workflow_success gauge");
    let _ = writeln!(buf, "# HELP nixconf_ci_job_duration_seconds Total duration of individual CI jobs in the latest workflow run.");
    let _ = writeln!(buf, "# TYPE nixconf_ci_job_duration_seconds gauge");
    let _ = writeln!(buf, "# HELP nixconf_ci_job_work_seconds Work duration (excluding runner setup) of individual CI jobs.");
    let _ = writeln!(buf, "# TYPE nixconf_ci_job_work_seconds gauge");

    match ci::collect(opts.repo.clone(), opts.limit, false) {
        Ok(report) => {
            for (wf_name, wf) in &report.workflows {
                let wf_esc = prom_escape(wf_name);
                let ok_val = if wf.conclusion == "success" { 1 } else { 0 };
                let _ = writeln!(buf, "nixconf_ci_workflow_wall_seconds{{workflow=\"{wf_esc}\"}} {:.3}", wf.wall_s);
                let _ = writeln!(buf, "nixconf_ci_workflow_runner_seconds{{workflow=\"{wf_esc}\"}} {:.3}", wf.total_runner_s);
                let _ = writeln!(buf, "nixconf_ci_workflow_setup_seconds{{workflow=\"{wf_esc}\"}} {:.3}", wf.setup_teardown_s);
                let _ = writeln!(buf, "nixconf_ci_workflow_work_seconds{{workflow=\"{wf_esc}\"}} {:.3}", wf.work_s);
                let _ = writeln!(buf, "nixconf_ci_workflow_jobs{{workflow=\"{wf_esc}\"}} {}", wf.job_count);
                let _ = writeln!(buf, "nixconf_ci_workflow_success{{workflow=\"{wf_esc}\"}} {ok_val}");

                for job in &wf.slowest_jobs {
                    if job.conclusion == "skipped" || job.run_s <= 0.0 {
                        continue;
                    }
                    let j_esc = prom_escape(&job.name);
                    let _ = writeln!(
                        buf,
                        "nixconf_ci_job_duration_seconds{{workflow=\"{wf_esc}\",job=\"{j_esc}\"}} {:.3}",
                        job.run_s
                    );
                    let _ = writeln!(
                        buf,
                        "nixconf_ci_job_work_seconds{{workflow=\"{wf_esc}\",job=\"{j_esc}\"}} {:.3}",
                        job.work_s
                    );
                }
            }
        }
        Err(err) => {
            eprintln!("nixprof metrics: GitHub Actions poll failed (continuing with cache probes): {err}");
        }
    }

    let _ = writeln!(buf, "# HELP nixconf_cache_probe_up Whether the binary cache responded HTTP 200 to nix-cache-info (1=up, 0=down).");
    let _ = writeln!(buf, "# TYPE nixconf_cache_probe_up gauge");
    let _ = writeln!(buf, "# HELP nixconf_cache_probe_latency_seconds Round-trip latency to fetch nix-cache-info from the binary cache.");
    let _ = writeln!(buf, "# TYPE nixconf_cache_probe_latency_seconds gauge");

    let caches = [
        ("attic", opts.attic_url.as_str()),
        ("cachix", opts.cachix_url.as_str()),
        ("nixos", "https://cache.nixos.org"),
    ];
    for (name, url) in caches {
        let (up, latency) = probe_cache(url);
        let _ = writeln!(buf, "nixconf_cache_probe_up{{cache=\"{name}\"}} {}", if up { 1 } else { 0 });
        if up {
            let _ = writeln!(buf, "nixconf_cache_probe_latency_seconds{{cache=\"{name}\"}} {:.6}", latency);
        }
    }

    if let Some(dir) = &opts.attic_dir {
        if dir.is_dir() {
            let (bytes, files) = dir_size_and_count(dir);
            let _ = writeln!(buf, "# HELP nixconf_attic_storage_bytes Total bytes stored on disk by Attic (/var/lib/atticd).");
            let _ = writeln!(buf, "# TYPE nixconf_attic_storage_bytes gauge");
            let _ = writeln!(buf, "nixconf_attic_storage_bytes {bytes}");
            let _ = writeln!(buf, "# HELP nixconf_attic_storage_files Total files stored on disk by Attic.");
            let _ = writeln!(buf, "# TYPE nixconf_attic_storage_files gauge");
            let _ = writeln!(buf, "nixconf_attic_storage_files {files}");
        }
    }
}

fn measure_nix_eval(repo_dir: &Path, attr: &str) -> Option<(f64, f64, u64)> {
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos();
    let stats_path = std::env::temp_dir().join(format!("nixprof-stats-{ts}.json"));
    let target = format!("git+file://{}#{attr}", repo_dir.display());

    let t0 = Instant::now();
    let status = Command::new("nix")
        .args(["eval", "--raw", "--no-eval-cache", &target])
        .env("NIX_SHOW_STATS", "1")
        .env("NIX_SHOW_STATS_PATH", &stats_path)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .status()
        .ok()?;
    let wall_s = t0.elapsed().as_secs_f64();

    let (cpu_s, alloc_bytes) = if let Ok(raw) = fs::read_to_string(&stats_path) {
        let v: Value = serde_json::from_str(&raw).unwrap_or(Value::Null);
        let cpu = v.get("cpuTime").and_then(Value::as_f64).unwrap_or(wall_s);
        let bytes = v
            .pointer("/gc/totalBytes")
            .and_then(Value::as_u64)
            .unwrap_or(0);
        (cpu, bytes)
    } else {
        (wall_s, 0)
    };
    let _ = fs::remove_file(&stats_path);

    if status.success() {
        Some((wall_s, cpu_s, alloc_bytes))
    } else {
        None
    }
}

fn eval_out_paths(flake_uri: &str, system: &str) -> Option<Vec<(String, String)>> {
    let expr = format!(
        "b: {{ eval_astrolabe = b.checks-eval-astrolabe.outPath; eval_x240 = b.checks-eval-x240.outPath; ci = b.packages-ci.outPath; docs = b.checks-docs.outPath; menu = b.packages-menu.outPath; }}"
    );
    let target = format!("{flake_uri}#legacyPackages.{system}.ciBuildables");
    let out = Command::new("nix")
        .args(["eval", "--no-eval-cache", "--json", "--apply", &expr, &target])
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    let v: Value = serde_json::from_slice(&out.stdout).ok()?;
    let obj = v.as_object()?;
    let mut pairs = Vec::new();
    for (k, val) in obj {
        if let Some(s) = val.as_str() {
            pairs.push((k.clone(), s.to_string()));
        }
    }
    pairs.sort();
    Some(pairs)
}

fn measure_readme_cache_leaks(repo_dir: &Path, system: &str) -> Option<usize> {
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos();
    let wt = std::env::temp_dir().join(format!("nixprof-wt-{ts}"));

    let add_ok = Command::new("git")
        .current_dir(repo_dir)
        .args(["worktree", "add", "--detach", "-q"])
        .arg(&wt)
        .arg("HEAD")
        .status()
        .ok()?
        .success();
    if !add_ok {
        return None;
    }

    let uri = format!("git+file://{}", wt.display());
    let result = (|| {
        let before = eval_out_paths(&uri, system)?;
        let readme = wt.join("README.md");
        let orig = fs::read_to_string(&readme).ok()?;
        fs::write(&readme, format!("{orig}\n<!-- nixprof-cache-probe -->\n")).ok()?;
        let after = eval_out_paths(&uri, system)?;

        let mut changed_non_docs = 0usize;
        for ((k1, v1), (_, v2)) in before.iter().zip(after.iter()) {
            if v1 != v2 && k1 != "docs" {
                changed_non_docs += 1;
            }
        }
        Some(changed_non_docs)
    })();

    let _ = Command::new("git")
        .current_dir(repo_dir)
        .args(["worktree", "remove", "--force"])
        .arg(&wt)
        .status();
    let _ = fs::remove_dir_all(&wt);

    result
}

fn collect_eval_metrics(opts: &MetricsOpts, buf: &mut String) {
    let repo_dir = fs::canonicalize(&opts.repo_dir).unwrap_or_else(|_| opts.repo_dir.clone());
    if !repo_dir.join("flake.nix").is_file() {
        eprintln!(
            "nixprof metrics: skipping --eval (no flake.nix at {})",
            repo_dir.display()
        );
        return;
    }

    let sys = &opts.system;
    let targets = [
        ("checks.schemas", format!("checks.{sys}.schemas.outPath")),
        ("checks.eval-astrolabe", format!("checks.{sys}.eval-astrolabe.outPath")),
        ("checks.eval-x240", format!("checks.{sys}.eval-x240.outPath")),
        ("packages.ci", format!("packages.{sys}.ci.outPath")),
        ("packages.docs", format!("packages.{sys}.docs.outPath")),
    ];

    let _ = writeln!(buf, "# HELP nixconf_eval_wall_seconds Uncached Nix evaluation wall-clock time in seconds.");
    let _ = writeln!(buf, "# TYPE nixconf_eval_wall_seconds gauge");
    let _ = writeln!(buf, "# HELP nixconf_eval_cpu_seconds Uncached Nix evaluation CPU time in seconds.");
    let _ = writeln!(buf, "# TYPE nixconf_eval_cpu_seconds gauge");
    let _ = writeln!(buf, "# HELP nixconf_eval_alloc_bytes Total bytes allocated by Nix evaluator during uncached eval.");
    let _ = writeln!(buf, "# TYPE nixconf_eval_alloc_bytes gauge");

    for (label, attr) in &targets {
        if let Some((wall, cpu, bytes)) = measure_nix_eval(&repo_dir, attr) {
            let _ = writeln!(buf, "nixconf_eval_wall_seconds{{target=\"{label}\"}} {wall:.3}");
            let _ = writeln!(buf, "nixconf_eval_cpu_seconds{{target=\"{label}\"}} {cpu:.3}");
            let _ = writeln!(buf, "nixconf_eval_alloc_bytes{{target=\"{label}\"}} {bytes}");
        }
    }

    if let Some(leaks) = measure_readme_cache_leaks(&repo_dir, sys) {
        let _ = writeln!(buf, "# HELP nixconf_cache_invalidated_non_docs_drvs Number of non-docs derivations invalidated by a README.md edit (0 = healthy isolation).");
        let _ = writeln!(buf, "# TYPE nixconf_cache_invalidated_non_docs_drvs gauge");
        let _ = writeln!(buf, "nixconf_cache_invalidated_non_docs_drvs{{mutation=\"readme\"}} {leaks}");
    }
}

pub fn run(opts: MetricsOpts) -> Result<i32, String> {
    let do_ci = opts.ci || !opts.eval;
    let do_eval = opts.eval;

    let mut buf = String::with_capacity(4096);
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    if do_ci {
        collect_ci_metrics(&opts, &mut buf);
    }
    if do_eval {
        collect_eval_metrics(&opts, &mut buf);
    }

    let _ = writeln!(buf, "# HELP nixconf_perf_metrics_timestamp_seconds Unix timestamp of last nixprof metrics collection.");
    let _ = writeln!(buf, "# TYPE nixconf_perf_metrics_timestamp_seconds gauge");
    let _ = writeln!(buf, "nixconf_perf_metrics_timestamp_seconds {ts}");

    match &opts.out {
        Some(path) => {
            if let Some(parent) = path.parent() {
                fs::create_dir_all(parent).map_err(|e| format!("mkdir {}: {e}", parent.display()))?;
            }
            let tmp = path.with_extension("prom.tmp");
            fs::write(&tmp, &buf).map_err(|e| format!("write {}: {e}", tmp.display()))?;
            let _ = fs::set_permissions(&tmp, fs::Permissions::from_mode(0o644));
            fs::rename(&tmp, path).map_err(|e| format!("rename to {}: {e}", path.display()))?;
        }
        None => {
            print!("{buf}");
        }
    }

    Ok(0)
}
