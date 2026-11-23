use serde_json::Value;
use std::fs;
use std::path::Path;

fn fmt_delta(before: f64, after: f64, unit: &str) -> String {
    let delta = after - before;
    let speedup = if after > 0.0001 { before / after } else { 0.0 };
    format!(
        "{:8.2}{} -> {:8.2}{}  ({:+8.2}{}, {:5.2}x)",
        before, unit, after, unit, delta, unit, speedup
    )
}

pub fn run(before_path: &Path, after_path: &Path) -> Result<i32, String> {
    let b: Value = serde_json::from_str(
        &fs::read_to_string(before_path).map_err(|e| format!("read before: {e}"))?,
    )
    .map_err(|e| format!("parse before: {e}"))?;
    let a: Value = serde_json::from_str(
        &fs::read_to_string(after_path).map_err(|e| format!("read after: {e}"))?,
    )
    .map_err(|e| format!("parse after: {e}"))?;

    let b_type = b.get("report_type").and_then(Value::as_str).unwrap_or("unknown");
    let a_type = a.get("report_type").and_then(Value::as_str).unwrap_or("unknown");
    if b_type != a_type {
        return Err(format!(
            "cannot compare mismatched report types: `{b_type}` vs `{a_type}`"
        ));
    }

    println!(
        "Comparing [{}] {} -> {}\n",
        b_type,
        before_path.display(),
        after_path.display()
    );

    match b_type {
        "trace" => {
            let bw = b.get("wall_s").and_then(Value::as_f64).unwrap_or(0.0);
            let aw = a.get("wall_s").and_then(Value::as_f64).unwrap_or(0.0);
            println!("  Wall time      : {}", fmt_delta(bw, aw, "s"));

            let bc = b.get("nix_total_cpu_s").and_then(Value::as_f64).unwrap_or(0.0);
            let ac = a.get("nix_total_cpu_s").and_then(Value::as_f64).unwrap_or(0.0);
            println!("  Nix eval CPU   : {}", fmt_delta(bc, ac, "s"));

            let ba = b.get("nix_total_alloc_mb").and_then(Value::as_f64).unwrap_or(0.0);
            let aa = a.get("nix_total_alloc_mb").and_then(Value::as_f64).unwrap_or(0.0);
            println!("  Nix allocations: {}", fmt_delta(ba, aa, "MB"));

            let bi = b.get("nix_invocation_count").and_then(Value::as_u64).unwrap_or(0);
            let ai = a.get("nix_invocation_count").and_then(Value::as_u64).unwrap_or(0);
            println!("  Nix invocations: {bi} -> {ai} ({:+})", ai as i64 - bi as i64);
        }
        "bench" => {
            if let (Some(be), Some(ae)) = (
                b.get("entries").and_then(Value::as_array),
                a.get("entries").and_then(Value::as_array),
            ) {
                for (x, y) in be.iter().zip(ae.iter()) {
                    let cmd = x.get("command").and_then(Value::as_str).unwrap_or("");
                    let bm = x.get("mean_s").and_then(Value::as_f64).unwrap_or(0.0);
                    let am = y.get("mean_s").and_then(Value::as_f64).unwrap_or(0.0);
                    println!("  {:<36}: {}", cmd, fmt_delta(bm, am, "s"));
                }
            }
        }
        "cache" => {
            if let (Some(bm), Some(am)) = (
                b.get("mutations").and_then(Value::as_array),
                a.get("mutations").and_then(Value::as_array),
            ) {
                for (x, y) in bm.iter().zip(am.iter()) {
                    let label = x.get("label").and_then(Value::as_str).unwrap_or("");
                    let bc = x.get("invalidated_count").and_then(Value::as_u64).unwrap_or(0);
                    let ac = y.get("invalidated_count").and_then(Value::as_u64).unwrap_or(0);
                    let tot = y.get("total_tracked").and_then(Value::as_u64).unwrap_or(0);
                    println!(
                        "  {:<36}: {:3}/{} -> {:3}/{} ({:+})",
                        label,
                        bc,
                        tot,
                        ac,
                        tot,
                        ac as i64 - bc as i64
                    );
                }
            }
        }
        "ci" => {
            if let (Some(bw), Some(aw)) = (
                b.get("workflows").and_then(Value::as_object),
                a.get("workflows").and_then(Value::as_object),
            ) {
                for (name, bv) in bw {
                    if let Some(av) = aw.get(name) {
                        println!("  Workflow: {name}");
                        let bwall = bv.get("wall_s").and_then(Value::as_f64).unwrap_or(0.0);
                        let awall = av.get("wall_s").and_then(Value::as_f64).unwrap_or(0.0);
                        println!("    Wall time   : {}", fmt_delta(bwall, awall, "s"));
                        let brun = bv.get("total_runner_s").and_then(Value::as_f64).unwrap_or(0.0) / 60.0;
                        let arun = av.get("total_runner_s").and_then(Value::as_f64).unwrap_or(0.0) / 60.0;
                        println!("    Runner mins : {}", fmt_delta(brun, arun, "m"));
                    }
                }
            }
        }
        _ => return Err(format!("unsupported report_type `{b_type}`")),
    }

    Ok(0)
}
