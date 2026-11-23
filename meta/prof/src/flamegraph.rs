use crate::shim::NixInvocationRecord;
use inferno::flamegraph::{self, Options};
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::collections::{HashMap, HashSet};
use std::fs::{self, File};
use std::io::BufWriter;
use std::path::Path;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FrameStat {
    pub frame: String,
    pub samples: u64,
    pub pct: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AreaStat {
    pub area: String,
    pub self_samples: u64,
    pub self_pct: f64,
    pub incl_samples: u64,
    pub incl_pct: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ProfileSummary {
    pub total_samples: u64,
    pub top_self: Vec<FrameStat>,
    pub top_inclusive: Vec<FrameStat>,
    pub by_area: Vec<AreaStat>,
}

fn strip_store_prefix(s: &str, repo_root: &str) -> String {
    let mut out = s.trim().to_string();
    if !repo_root.is_empty() {
        let prefix = format!("{}/", repo_root.trim_end_matches('/'));
        out = out.replace(&prefix, "repo/");
    }
    // Normalize Nix flake URI guillemets: «github:owner/repo/rev?narHash=...»/ -> input:repo/
    // and «git+file:///.../nixconf?...»/ -> repo/
    while let (Some(start), Some(end_rel)) = (out.find('«'), out.find('»')) {
        if end_rel <= start {
            break;
        }
        let inner = &out[start + '«'.len_utf8()..end_rel];
        let replacement = if inner.starts_with("git+file://") || inner.starts_with("path:") {
            "repo".to_string()
        } else if let Some(rest) = inner.strip_prefix("github:") {
            let mut parts = rest.split('/');
            let _owner = parts.next().unwrap_or("");
            let repo = parts
                .next()
                .unwrap_or("github")
                .split('?')
                .next()
                .unwrap_or("github");
            format!("input:{repo}")
        } else if inner == "none" {
            "<none>".to_string()
        } else {
            let short = inner.split('?').next().unwrap_or(inner);
            format!("input:{short}")
        };
        let end = end_rel + '»'.len_utf8();
        out.replace_range(start..end, &replacement);
    }
    // Normalize /nix/store/<32-char-hash>-<name>/
    let bytes = out.as_bytes();
    let mut result = String::with_capacity(out.len());
    let mut i = 0;
    while i < bytes.len() {
        if out[i..].starts_with("/nix/store/") && i + 44 <= out.len() {
            let after_hash = i + 11 + 32; // "/nix/store/" (11) + 32-char hash
            if out.as_bytes().get(after_hash) == Some(&b'-') {
                if let Some(slash_rel) = out[after_hash + 1..].find('/') {
                    let pkg = &out[after_hash + 1..after_hash + 1 + slash_rel];
                    if pkg == "source" {
                        result.push_str("repo/");
                    } else {
                        result.push_str("store:");
                        result.push_str(pkg);
                        result.push('/');
                    }
                    i = after_hash + 1 + slash_rel + 1;
                    continue;
                }
            }
        }
        let ch = out[i..].chars().next().unwrap();
        result.push(ch);
        i += ch.len_utf8();
    }
    result
}

fn classify_area(norm: &str) -> String {
    if let Some(idx) = norm.find("repo/") {
        let rel = &norm[idx + 5..];
        let mut parts = rel.split('/');
        let p0 = parts.next().unwrap_or("root");
        let p1 = parts.next();
        if let Some(p1) = p1 {
            if !p1.contains(':') {
                return format!("repo/{p0}/{p1}");
            }
        }
        return format!("repo/{p0}");
    }
    if norm.starts_with("primop ") || norm.contains("primop") {
        return "nix-primops".to_string();
    }
    if norm.contains("lib/modules.nix")
        || norm.contains("lib/types.nix")
        || norm.contains("lib/options.nix")
    {
        return "nixpkgs/module-system".to_string();
    }
    if norm.contains("nixos/modules/") {
        return "nixpkgs/nixos-modules".to_string();
    }
    if norm.contains("/lib/") {
        return "nixpkgs/lib".to_string();
    }
    if norm.contains("flake-parts") {
        return "flake-parts".to_string();
    }
    if norm.contains("devenv") {
        return "devenv".to_string();
    }
    if norm.contains("pkgs/") {
        return "nixpkgs/pkgs".to_string();
    }
    "other".to_string()
}

/// Normalize and merge one or more folded stack files into normalized lines + summary.
pub fn merge_and_analyze_folded(
    files: &[&Path],
    repo_root: &str,
) -> (Vec<String>, ProfileSummary) {
    let mut merged: HashMap<String, u64> = HashMap::new();
    let mut self_counts: HashMap<String, u64> = HashMap::new();
    let mut incl_counts: HashMap<String, u64> = HashMap::new();
    let mut area_self: HashMap<String, u64> = HashMap::new();
    let mut area_incl: HashMap<String, u64> = HashMap::new();
    let mut total_samples: u64 = 0;

    for f in files {
        let Ok(content) = fs::read_to_string(f) else {
            continue;
        };
        for line in content.lines() {
            let line = line.trim();
            if line.is_empty() {
                continue;
            }
            let Some((stack_raw, count_raw)) = line.rsplit_once(' ') else {
                continue;
            };
            let Ok(count) = count_raw.parse::<u64>() else {
                continue;
            };
            let frames: Vec<String> = stack_raw
                .split(';')
                .map(|fr| strip_store_prefix(fr, repo_root))
                .filter(|fr| !fr.is_empty())
                .collect();
            if frames.is_empty() {
                continue;
            }
            total_samples += count;

            let norm_stack = frames.join(";");
            *merged.entry(norm_stack).or_insert(0) += count;

            let leaf = frames.last().unwrap();
            *self_counts.entry(leaf.clone()).or_insert(0) += count;
            *area_self.entry(classify_area(leaf)).or_insert(0) += count;

            let unique_frames: HashSet<&String> = frames.iter().collect();
            for fr in unique_frames {
                *incl_counts.entry(fr.clone()).or_insert(0) += count;
            }
            let unique_areas: HashSet<String> = frames.iter().map(|fr| classify_area(fr)).collect();
            for area in unique_areas {
                *area_incl.entry(area).or_insert(0) += count;
            }
        }
    }

    let mut folded_lines: Vec<String> = merged
        .into_iter()
        .map(|(stack, cnt)| format!("{stack} {cnt}"))
        .collect();
    folded_lines.sort();

    let to_top = |map: HashMap<String, u64>, limit: usize| -> Vec<FrameStat> {
        let mut items: Vec<(String, u64)> = map.into_iter().collect();
        items.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
        items
            .into_iter()
            .take(limit)
            .map(|(frame, samples)| FrameStat {
                frame,
                samples,
                pct: if total_samples > 0 {
                    (samples as f64 / total_samples as f64 * 10000.0).round() / 100.0
                } else {
                    0.0
                },
            })
            .collect()
    };

    let mut areas: Vec<AreaStat> = area_self
        .into_iter()
        .map(|(area, self_samples)| {
            let incl_samples = *area_incl.get(&area).unwrap_or(&self_samples);
            AreaStat {
                area,
                self_samples,
                self_pct: if total_samples > 0 {
                    (self_samples as f64 / total_samples as f64 * 10000.0).round() / 100.0
                } else {
                    0.0
                },
                incl_samples,
                incl_pct: if total_samples > 0 {
                    (incl_samples as f64 / total_samples as f64 * 10000.0).round() / 100.0
                } else {
                    0.0
                },
            }
        })
        .collect();
    areas.sort_by(|a, b| b.self_samples.cmp(&a.self_samples));

    let summary = ProfileSummary {
        total_samples,
        top_self: to_top(self_counts, 15),
        top_inclusive: to_top(incl_counts, 15),
        by_area: areas,
    };

    (folded_lines, summary)
}

/// Render an interactive SVG flamegraph natively via embedded `inferno`.
pub fn write_svg_flamegraph(
    folded_lines: &[String],
    title: &str,
    out_svg: &Path,
) -> Result<(), String> {
    if folded_lines.is_empty() {
        return Ok(());
    }
    let mut opts = Options::default();
    opts.title = title.to_string();
    opts.count_name = "samples".to_string();
    opts.min_width = 0.2;

    let file = File::create(out_svg).map_err(|e| format!("create svg: {e}"))?;
    let writer = BufWriter::new(file);
    let refs: Vec<&str> = folded_lines.iter().map(String::as_str).collect();
    flamegraph::from_lines(&mut opts, refs.into_iter(), writer)
        .map_err(|e| format!("inferno flamegraph render failed: {e}"))
}

/// Emit a multi-profile Speedscope JSON containing:
///   1. Chronological Gantt Timeline (`evented` profile of all nix invocations + build/copy/sub spans)
///   2. Nix Eval Flamegraph (`sampled` profile from folded stacks)
pub fn write_speedscope_json(
    trace_name: &str,
    total_wall_ms: f64,
    invocations: &[NixInvocationRecord],
    folded_lines: &[String],
    freq_hz: u32,
    out_path: &Path,
) -> Result<(), String> {
    let mut frame_index: HashMap<String, usize> = HashMap::new();
    let mut frames: Vec<serde_json::Value> = Vec::new();

    let mut intern_frame = |name: &str| -> usize {
        if let Some(&idx) = frame_index.get(name) {
            return idx;
        }
        let idx = frames.len();
        frames.push(json!({ "name": name }));
        frame_index.insert(name.to_string(), idx);
        idx
    };

    // Profile 1: Evented Timeline (milliseconds)
    // Flatten non-overlapping timeline events per invocation + its major child activities
    let mut events: Vec<(f64, u8, usize)> = Vec::new(); // (at_ms, kind: 0=O 1=C, frame_idx)
    let root_frame = intern_frame(&format!("trace: {trace_name}"));
    events.push((0.0, 0, root_frame));

    let mut sorted_inv: Vec<&NixInvocationRecord> = invocations.iter().collect();
    sorted_inv.sort_by(|a, b| a.start_ms.total_cmp(&b.start_ms));

    for inv in &sorted_inv {
        let label = format!(
            "nix #{} {} ({:.2}s)",
            inv.id,
            inv.args.iter().take(4).cloned().collect::<Vec<_>>().join(" "),
            inv.wall_s
        );
        let f_inv = intern_frame(&label);
        let s = inv.start_ms.max(0.0);
        let e = inv.end_ms.max(s + 0.1);
        events.push((s, 0, f_inv));

        // Add significant non-overlapping activities (>= 5ms) inside this invocation
        let mut acts: Vec<_> = inv
            .activities
            .iter()
            .filter(|a| {
                a.duration_ms >= 5.0
                    && matches!(
                        a.kind.as_str(),
                        "build" | "substitute" | "copyPath" | "fetchTree" | "fileTransfer" | "realise"
                    )
            })
            .collect();
        acts.sort_by(|a, b| a.start_ms.total_cmp(&b.start_ms));

        let mut cursor = s;
        for act in acts {
            let a_start = act.start_ms.max(cursor).min(e);
            let a_end = act.end_ms.max(a_start).min(e);
            if a_end <= a_start {
                continue;
            }
            let act_label = match &act.drv {
                Some(drv) => format!("{}: {}", act.kind, drv),
                None => format!("{}: {}", act.kind, act.text),
            };
            let f_act = intern_frame(&act_label);
            events.push((a_start, 0, f_act));
            events.push((a_end, 1, f_act));
            cursor = a_end;
        }

        events.push((e, 1, f_inv));
    }

    events.push((total_wall_ms.max(1.0), 1, root_frame));

    let speedscope_events: Vec<serde_json::Value> = events
        .into_iter()
        .map(|(at, k, frame)| {
            json!({
                "type": if k == 0 { "O" } else { "C" },
                "at": (at * 100.0).round() / 100.0,
                "frame": frame,
            })
        })
        .collect();

    let mut profiles: Vec<serde_json::Value> = vec![json!({
        "type": "evented",
        "name": format!("Timeline ({trace_name})"),
        "unit": "milliseconds",
        "startValue": 0.0,
        "endValue": total_wall_ms.max(1.0),
        "events": speedscope_events,
    })];

    // Profile 2: Sampled Nix Eval Flamegraph (milliseconds estimated from freq_hz)
    if !folded_lines.is_empty() {
        let ms_per_sample = 1000.0 / (freq_hz.max(1) as f64);
        let mut samples: Vec<Vec<usize>> = Vec::with_capacity(folded_lines.len());
        let mut weights: Vec<f64> = Vec::with_capacity(folded_lines.len());
        let mut total_w = 0.0;

        for line in folded_lines {
            if let Some((stack_str, cnt_str)) = line.rsplit_once(' ') {
                if let Ok(cnt) = cnt_str.parse::<u64>() {
                    let stack: Vec<usize> = stack_str
                        .split(';')
                        .filter(|s| !s.is_empty())
                        .map(&mut intern_frame)
                        .collect();
                    if !stack.is_empty() {
                        let w = (cnt as f64) * ms_per_sample;
                        total_w += w;
                        samples.push(stack);
                        weights.push((w * 100.0).round() / 100.0);
                    }
                }
            }
        }

        profiles.push(json!({
            "type": "sampled",
            "name": "Nix Eval Flamegraph (merged)",
            "unit": "milliseconds",
            "startValue": 0.0,
            "endValue": (total_w * 100.0).round() / 100.0,
            "samples": samples,
            "weights": weights,
        }));
    }

    let doc = json!({
        "$schema": "https://www.speedscope.app/file-format-schema.json",
        "version": "0.0.1",
        "name": format!("nixprof: {trace_name}"),
        "exporter": "nixprof 0.1.0",
        "shared": { "frames": frames },
        "profiles": profiles,
    });

    let serialized = serde_json::to_string(&doc).map_err(|e| format!("serialize speedscope: {e}"))?;
    fs::write(out_path, serialized).map_err(|e| format!("write speedscope: {e}"))
}
