use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

pub fn run(out: Option<PathBuf>, save_only: bool, cmd: Vec<String>) -> Result<i32, String> {
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();
    let profile_out = out.unwrap_or_else(|| PathBuf::from(format!(".bench/native/profile-{ts}.json.gz")));
    if let Some(p) = profile_out.parent() {
        fs::create_dir_all(p).map_err(|e| format!("mkdir: {e}"))?;
    }

    let mut c = Command::new("samply");
    c.arg("record");
    if save_only {
        c.arg("--save-only");
    }
    c.arg("-o").arg(&profile_out);
    c.arg("--");
    c.args(&cmd);

    let status = c.status().map_err(|e| {
        format!("failed to invoke `samply` (ensure samply is in PATH / devenv): {e}")
    })?;
    eprintln!("Native CPU profile written to: {}", profile_out.display());
    Ok(status.code().unwrap_or(1))
}
