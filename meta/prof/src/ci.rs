use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::BTreeMap;
use std::env;
use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct JobSummary {
    pub name: String,
    #[serde(default)]
    pub conclusion: String,
    #[serde(default)]
    pub failed_steps: Vec<String>,
    pub queue_s: f64,
    pub run_s: f64,
    pub setup_s: f64,
    pub work_s: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WorkflowSummary {
    pub run_id: u64,
    #[serde(default)]
    pub conclusion: String,
    pub job_count: usize,
    pub wall_s: f64,
    pub total_runner_s: f64,
    pub setup_teardown_s: f64,
    pub work_s: f64,
    pub slowest_jobs: Vec<JobSummary>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CiReport {
    pub report_type: String,
    pub timestamp: u64,
    pub repo: String,
    pub workflows: BTreeMap<String, WorkflowSummary>,
}

fn detect_repo_slug() -> Result<String, String> {
    let out = Command::new("git")
        .args(["remote", "get-url", "origin"])
        .output()
        .map_err(|e| format!("git remote: {e}"))?;
    let raw = String::from_utf8_lossy(&out.stdout).trim().to_string();
    let cleaned = raw
        .trim_end_matches(".git")
        .trim_start_matches("https://github.com/")
        .trim_start_matches("http://github.com/")
        .trim_start_matches("git@github.com:")
        .to_string();
    if cleaned.contains('/') {
        Ok(cleaned)
    } else {
        Err(format!("could not parse GitHub owner/repo from remote `{raw}`; pass --repo"))
    }
}

fn curl_json(url: &str) -> Result<Value, String> {
    let mut cmd = Command::new("curl");
    cmd.args([
        "-fsSL",
        "-H",
        "Accept: application/vnd.github+json",
        "-H",
        "User-Agent: nixprof",
    ]);
    if let Ok(tok) = env::var("GH_TOKEN").or_else(|_| env::var("GITHUB_TOKEN")) {
        if !tok.is_empty() {
            cmd.args(["-H", &format!("Authorization: Bearer {tok}")]);
        }
    }
    cmd.arg(url);
    let out = cmd.output().map_err(|e| format!("curl failed: {e}"))?;
    if !out.status.success() {
        return Err(format!(
            "GitHub API error for {url}: {}",
            String::from_utf8_lossy(&out.stderr)
        ));
    }
    serde_json::from_slice(&out.stdout).map_err(|e| format!("parse json: {e}"))
}

/// Minimal ISO-8601 UTC parser (YYYY-MM-DDTHH:MM:SSZ) -> epoch seconds
fn parse_iso_utc(s: &str) -> Option<f64> {
    if s.len() < 19 {
        return None;
    }
    let y: i64 = s.get(0..4)?.parse().ok()?;
    let m: i64 = s.get(5..7)?.parse().ok()?;
    let d: i64 = s.get(8..10)?.parse().ok()?;
    let hh: i64 = s.get(11..13)?.parse().ok()?;
    let mm: i64 = s.get(14..16)?.parse().ok()?;
    let ss: i64 = s.get(17..19)?.parse().ok()?;
    // Howard Hinnant civil-from-days inverse
    let y_adj = y - if m <= 2 { 1 } else { 0 };
    let era = if y_adj >= 0 { y_adj } else { y_adj - 399 } / 400;
    let yoe = y_adj - era * 400;
    let mp = m + if m > 2 { -3 } else { 9 };
    let doy = (153 * mp + 2) / 5 + d - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    let days = era * 146097 + doe - 719468;
    Some((days * 86400 + hh * 3600 + mm * 60 + ss) as f64)
}

fn is_setup_step(name: &str) -> bool {
    matches!(
        name,
        "Set up job"
            | "Checkout repository"
            | "Cache Nix fetcher & eval cache"
            | "Post Cache Nix fetcher & eval cache"
            | "Install Nix"
            | "Setup Cachix"
            | "Post Setup Cachix"
            | "Post Checkout repository"
            | "Complete job"
            | "Enable KVM permissions"
            | "Compute cooldown key"
            | "Check install tier cooldown cache"
            | "Post Check install tier cooldown cache"
            | "Detect disk configuration changes"
    )
}

pub fn collect(repo: Option<String>, limit: u32, verbose: bool) -> Result<CiReport, String> {
    let slug = match repo {
        Some(r) => r,
        None => detect_repo_slug()?,
    };
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    let runs_val = curl_json(&format!(
        "https://api.github.com/repos/{slug}/actions/runs?per_page={limit}"
    ))?;

    let mut latest_by_wf: BTreeMap<String, (u64, String)> = BTreeMap::new();
    if let Some(runs) = runs_val.get("workflow_runs").and_then(Value::as_array) {
        for r in runs {
            let status = r.get("status").and_then(Value::as_str).unwrap_or("");
            let concl = r.get("conclusion").and_then(Value::as_str).unwrap_or(status);
            let name = r.get("name").and_then(Value::as_str).unwrap_or("");
            let id = r.get("id").and_then(Value::as_u64).unwrap_or(0);
            if status == "completed" && !name.is_empty() && !latest_by_wf.contains_key(name) {
                latest_by_wf.insert(name.to_string(), (id, concl.to_string()));
            }
        }
    }

    let mut workflows = BTreeMap::new();
    for (wf_name, (run_id, wf_conclusion)) in latest_by_wf {
        let jobs_val = curl_json(&format!(
            "https://api.github.com/repos/{slug}/actions/runs/{run_id}/jobs?per_page=100"
        ))?;
        let jobs = jobs_val
            .get("jobs")
            .and_then(Value::as_array)
            .cloned()
            .unwrap_or_default();

        let mut min_start: Option<f64> = None;
        let mut max_end: Option<f64> = None;
        let mut total_runner_s = 0.0;
        let mut setup_teardown_s = 0.0;
        let mut work_s = 0.0;
        let mut rows = Vec::new();

        for j in &jobs {
            let jname = j.get("name").and_then(Value::as_str).unwrap_or("").to_string();
            let jconcl = j
                .get("conclusion")
                .and_then(Value::as_str)
                .unwrap_or("unknown")
                .to_string();
            let jc = j.get("created_at").and_then(Value::as_str).and_then(parse_iso_utc);
            let js = j.get("started_at").and_then(Value::as_str).and_then(parse_iso_utc);
            let je = j.get("completed_at").and_then(Value::as_str).and_then(parse_iso_utc);

            if let Some(s) = js {
                min_start = Some(min_start.map_or(s, |cur| cur.min(s)));
            }
            if let Some(e) = je {
                max_end = Some(max_end.map_or(e, |cur| cur.max(e)));
            }
            let run_s = match (js, je) {
                (Some(s), Some(e)) => (e - s).max(0.0),
                _ => 0.0,
            };
            let queue_s = match (jc, js) {
                (Some(c), Some(s)) => (s - c).max(0.0),
                _ => 0.0,
            };
            total_runner_s += run_s;

            let mut j_setup = 0.0;
            let mut j_work = 0.0;
            let mut failed_steps = Vec::new();
            if let Some(steps) = j.get("steps").and_then(Value::as_array) {
                for st in steps {
                    let sname = st.get("name").and_then(Value::as_str).unwrap_or("");
                    let sconcl = st.get("conclusion").and_then(Value::as_str).unwrap_or("");
                    if sconcl == "failure" {
                        failed_steps.push(sname.to_string());
                    }
                    let ss = st.get("started_at").and_then(Value::as_str).and_then(parse_iso_utc);
                    let se = st.get("completed_at").and_then(Value::as_str).and_then(parse_iso_utc);
                    let sd = match (ss, se) {
                        (Some(a), Some(b)) => (b - a).max(0.0),
                        _ => 0.0,
                    };
                    if is_setup_step(sname) {
                        j_setup += sd;
                    } else {
                        j_work += sd;
                    }
                }
            }
            setup_teardown_s += j_setup;
            work_s += j_work;

            rows.push(JobSummary {
                name: jname,
                conclusion: jconcl,
                failed_steps,
                queue_s,
                run_s,
                setup_s: j_setup,
                work_s: j_work,
            });
        }

        rows.sort_by(|a, b| b.run_s.total_cmp(&a.run_s));
        let wall_s = match (min_start, max_end) {
            (Some(a), Some(b)) => (b - a).max(0.0),
            _ => 0.0,
        };

        if verbose {
            eprintln!(
                "\n=== {} (run #{} [{}]) ===\n  jobs={} | wall={:.0}s | total_runner={:.1} min (setup={:.0}s, work={:.0}s)",
                wf_name,
                run_id,
                wf_conclusion,
                jobs.len(),
                wall_s,
                total_runner_s / 60.0,
                setup_teardown_s,
                work_s
            );
            for j in rows.iter().take(10) {
                let fail_note = if j.failed_steps.is_empty() {
                    String::new()
                } else {
                    format!("  FAILED: {}", j.failed_steps.join(", "))
                };
                eprintln!(
                    "  - {:<36} [{:<9}] run={:5.0}s (setup={:3.0}s, work={:4.0}s, queue={:2.0}s){}",
                    j.name, j.conclusion, j.run_s, j.setup_s, j.work_s, j.queue_s, fail_note
                );
            }
        }

        workflows.insert(
            wf_name,
            WorkflowSummary {
                run_id,
                conclusion: wf_conclusion,
                job_count: jobs.len(),
                wall_s,
                total_runner_s,
                setup_teardown_s,
                work_s,
                slowest_jobs: rows.into_iter().take(15).collect(),
            },
        );
    }

    Ok(CiReport {
        report_type: "ci".into(),
        timestamp: ts,
        repo: slug,
        workflows,
    })
}

pub fn run(repo: Option<String>, limit: u32, out: Option<PathBuf>) -> Result<i32, String> {
    let report = collect(repo, limit, true)?;
    let ts = report.timestamp;

    let out_path = out.unwrap_or_else(|| PathBuf::from(format!(".bench/results/ci-{ts}.json")));
    if let Some(p) = out_path.parent() {
        fs::create_dir_all(p).map_err(|e| format!("mkdir: {e}"))?;
    }
    let json = serde_json::to_string_pretty(&report).map_err(|e| format!("serialize: {e}"))?;
    fs::write(&out_path, json).map_err(|e| format!("write: {e}"))?;
    eprintln!("\nCI report saved to: {}", out_path.display());

    Ok(0)
}
