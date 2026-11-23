use crate::trace::{self, TraceOpts};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::time::{Instant, SystemTime, UNIX_EPOCH};

pub struct BenchOpts {
    pub runs: u32,
    pub warmup: u32,
    pub cold: bool,
    pub out: Option<PathBuf>,
    pub commands: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchEntry {
    pub command: String,
    pub mean_s: f64,
    pub stddev_s: f64,
    pub median_s: f64,
    pub min_s: f64,
    pub max_s: f64,
    pub runs: Vec<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BenchReport {
    pub report_type: String,
    pub timestamp: u64,
    pub engine: String,
    pub entries: Vec<BenchEntry>,
}

fn has_hyperfine() -> bool {
    Command::new("hyperfine")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

pub fn run(opts: BenchOpts) -> Result<i32, String> {
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    let out_path = opts
        .out
        .unwrap_or_else(|| PathBuf::from(format!(".bench/results/bench-{ts}.json")));
    if let Some(p) = out_path.parent() {
        fs::create_dir_all(p).map_err(|e| format!("mkdir: {e}"))?;
    }

    let entries = if has_hyperfine() {
        let hf_json = std::env::temp_dir().join(format!("nixprof-hf-{ts}.json"));
        let mut cmd = Command::new("hyperfine");
        cmd.args([
            "--warmup",
            &opts.warmup.to_string(),
            "--runs",
            &opts.runs.to_string(),
            "--export-json",
            &hf_json.to_string_lossy(),
        ]);
        for c in &opts.commands {
            cmd.arg(c);
        }
        let status = cmd.status().map_err(|e| format!("hyperfine failed: {e}"))?;
        if !status.success() {
            return Ok(status.code().unwrap_or(1));
        }
        let raw = fs::read_to_string(&hf_json).map_err(|e| format!("read hyperfine json: {e}"))?;
        let _ = fs::remove_file(&hf_json);
        let parsed: Value = serde_json::from_str(&raw).map_err(|e| format!("parse hf: {e}"))?;
        let mut out = Vec::new();
        if let Some(arr) = parsed.get("results").and_then(Value::as_array) {
            for item in arr {
                let times: Vec<f64> = item
                    .get("times")
                    .and_then(Value::as_array)
                    .map(|a| a.iter().filter_map(Value::as_f64).collect())
                    .unwrap_or_default();
                out.push(BenchEntry {
                    command: item
                        .get("command")
                        .and_then(Value::as_str)
                        .unwrap_or("")
                        .to_string(),
                    mean_s: item.get("mean").and_then(Value::as_f64).unwrap_or(0.0),
                    stddev_s: item.get("stddev").and_then(Value::as_f64).unwrap_or(0.0),
                    median_s: item.get("median").and_then(Value::as_f64).unwrap_or(0.0),
                    min_s: item.get("min").and_then(Value::as_f64).unwrap_or(0.0),
                    max_s: item.get("max").and_then(Value::as_f64).unwrap_or(0.0),
                    runs: times,
                });
            }
        }
        out
    } else {
        // Fallback built-in statistical runner
        let mut out = Vec::new();
        for c in &opts.commands {
            for _ in 0..opts.warmup {
                let _ = Command::new("bash").args(["-lc", c]).status();
            }
            let mut times = Vec::with_capacity(opts.runs as usize);
            for _ in 0..opts.runs {
                let t0 = Instant::now();
                let st = Command::new("bash")
                    .args(["-lc", c])
                    .status()
                    .map_err(|e| format!("run `{c}`: {e}"))?;
                if !st.success() {
                    return Ok(st.code().unwrap_or(1));
                }
                times.push(t0.elapsed().as_secs_f64());
            }
            let mut sorted = times.clone();
            sorted.sort_by(f64::total_cmp);
            let mean = times.iter().sum::<f64>() / (times.len().max(1) as f64);
            let var = times.iter().map(|t| (t - mean).powi(2)).sum::<f64>()
                / (times.len().max(1) as f64);
            let median = sorted[sorted.len() / 2];
            out.push(BenchEntry {
                command: c.clone(),
                mean_s: (mean * 10000.0).round() / 10000.0,
                stddev_s: (var.sqrt() * 10000.0).round() / 10000.0,
                median_s: (median * 10000.0).round() / 10000.0,
                min_s: (*sorted.first().unwrap_or(&0.0) * 10000.0).round() / 10000.0,
                max_s: (*sorted.last().unwrap_or(&0.0) * 10000.0).round() / 10000.0,
                runs: times,
            });
        }
        out
    };

    // If single command and --cold is requested, also run one quick profiled trace
    if opts.commands.len() == 1 && opts.cold {
        let _ = trace::run(TraceOpts {
            cold: true,
            freq: 500,
            out: None,
            name: "bench-profiled".into(),
            svg: true,
            speedscope: true,
            quiet: false,
            verbose_nix: false,
            cmd: vec!["bash".into(), "-lc".into(), opts.commands[0].clone()],
        });
    }

    let report = BenchReport {
        report_type: "bench".into(),
        timestamp: ts,
        engine: if has_hyperfine() {
            "hyperfine".into()
        } else {
            "builtin".into()
        },
        entries,
    };

    let json = serde_json::to_string_pretty(&report).map_err(|e| format!("serialize: {e}"))?;
    fs::write(&out_path, json).map_err(|e| format!("write: {e}"))?;
    eprintln!("\nBenchmark report saved to: {}", out_path.display());
    Ok(0)
}
