use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

pub struct CacheOpts {
    pub installables: Vec<String>,
    pub flake_all: bool,
    pub system: String,
    pub mutate: Vec<PathBuf>,
    pub between: Option<String>,
    pub base_ref: String,
    pub working_tree: bool,
    pub max_diffs: usize,
    pub out: Option<PathBuf>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClosureStat {
    pub drv: String,
    pub total_paths: usize,
    pub input_drvs: usize,
    pub input_srcs: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MutationResult {
    pub label: String,
    pub total_tracked: usize,
    pub invalidated_count: usize,
    pub unchanged_count: usize,
    pub invalidated: Vec<String>,
    pub diffs: BTreeMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CacheReport {
    pub report_type: String,
    pub timestamp: u64,
    pub tracked_count: usize,
    pub closures: BTreeMap<String, ClosureStat>,
    pub mutations: Vec<MutationResult>,
}

fn git_root() -> Result<PathBuf, String> {
    let out = Command::new("git")
        .args(["rev-parse", "--show-toplevel"])
        .output()
        .map_err(|e| format!("git rev-parse: {e}"))?;
    if !out.status.success() {
        return Err("not inside a git repository".into());
    }
    Ok(PathBuf::from(
        String::from_utf8_lossy(&out.stdout).trim(),
    ))
}

struct TempWorktree {
    root: PathBuf,
    path: PathBuf,
    is_git_worktree: bool,
}

impl TempWorktree {
    fn create(root: &Path, git_ref: &str) -> Result<Self, String> {
        let ts = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos();
        let path = std::env::temp_dir().join(format!("nixprof-wt-{ts}"));
        let out = Command::new("git")
            .args(["worktree", "add", "--detach", &path.to_string_lossy(), git_ref])
            .current_dir(root)
            .output()
            .map_err(|e| format!("git worktree add: {e}"))?;
        if !out.status.success() {
            return Err(format!(
                "git worktree add failed: {}",
                String::from_utf8_lossy(&out.stderr)
            ));
        }
        Ok(Self {
            root: root.to_path_buf(),
            path,
            is_git_worktree: true,
        })
    }

    fn create_from_working_tree(root: &Path) -> Result<Self, String> {
        let ts = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos();
        let path = std::env::temp_dir().join(format!("nixprof-wt-copy-{ts}"));
        fs::create_dir_all(&path).map_err(|e| format!("mkdir: {e}"))?;

        let list_out = Command::new("git")
            .args(["ls-files", "-z"])
            .current_dir(root)
            .output()
            .map_err(|e| format!("git ls-files: {e}"))?;
        if !list_out.status.success() {
            return Err("git ls-files failed".into());
        }

        for raw in list_out.stdout.split(|&b| b == 0) {
            if raw.is_empty() {
                continue;
            }
            let rel = String::from_utf8_lossy(raw);
            let src = root.join(rel.as_ref());
            if !src.exists() {
                continue;
            }
            let dst = path.join(rel.as_ref());
            if let Some(parent) = dst.parent() {
                fs::create_dir_all(parent).map_err(|e| format!("mkdir {}: {e}", parent.display()))?;
            }
            fs::copy(&src, &dst).map_err(|e| format!("copy {}: {e}", rel))?;
        }

        let run_git = |args: &[&str]| -> Result<(), String> {
            let o = Command::new("git")
                .args(args)
                .current_dir(&path)
                .env("GIT_AUTHOR_NAME", "nixprof")
                .env("GIT_AUTHOR_EMAIL", "nixprof@local")
                .env("GIT_COMMITTER_NAME", "nixprof")
                .env("GIT_COMMITTER_EMAIL", "nixprof@local")
                .output()
                .map_err(|e| format!("git {:?}: {e}", args))?;
            if !o.status.success() {
                return Err(format!(
                    "git {:?} failed: {}",
                    args,
                    String::from_utf8_lossy(&o.stderr)
                ));
            }
            Ok(())
        };

        run_git(&["init", "-q"])?;
        run_git(&["add", "-A"])?;
        run_git(&["commit", "-q", "-m", "nixprof working-tree snapshot", "--no-verify"])?;

        Ok(Self {
            root: root.to_path_buf(),
            path,
            is_git_worktree: false,
        })
    }
}

impl Drop for TempWorktree {
    fn drop(&mut self) {
        if self.is_git_worktree {
            let _ = Command::new("git")
                .args(["worktree", "remove", "--force", &self.path.to_string_lossy()])
                .current_dir(&self.root)
                .output();
        }
        let _ = fs::remove_dir_all(&self.path);
    }
}

fn snapshot_flake_all(cwd: &Path, system: &str) -> Result<BTreeMap<String, String>, String> {
    let cwd_str = cwd.to_string_lossy();
    let expr = format!(
        r#"
        let
          flake = builtins.getFlake "git+file://{cwd_str}";
          sys = "{system}";
          safeDrv = v: let t = builtins.tryEval (v.drvPath or (v.inputDerivation.drvPath or null)); in if t.success then t.value else null;
          collect = prefix: attrs:
            builtins.listToAttrs (builtins.concatMap (k: let d = safeDrv attrs.${{k}}; in if d != null then [{{ name = prefix + k; value = d; }}] else []) (builtins.attrNames attrs));
          checks = collect "check:" (flake.checks.${{sys}} or {{}});
          pkgs = collect "pkg:" (flake.packages.${{sys}} or {{}});
          shells = collect "shell:" (flake.devShells.${{sys}} or {{}});
          hosts = builtins.listToAttrs (builtins.concatMap (h:
            let
              cfg = flake.nixosConfigurations.${{h}}.config.system.build;
              t = safeDrv (cfg.toplevel or null);
              e = safeDrv (cfg.etc or null);
            in
              (if t != null then [{{ name = "host-toplevel:" + h; value = t; }}] else [])
              ++ (if e != null then [{{ name = "host-etc:" + h; value = e; }}] else [])
          ) (builtins.attrNames (flake.nixosConfigurations or {{}})));
        in checks // pkgs // shells // hosts
        "#
    );
    let out = Command::new("nix")
        .args(["eval", "--impure", "--no-eval-cache", "--json", "--expr", &expr])
        .current_dir(cwd)
        .output()
        .map_err(|e| format!("nix eval: {e}"))?;
    if !out.status.success() {
        return Err(format!(
            "snapshot_flake_all failed: {}",
            String::from_utf8_lossy(&out.stderr)
        ));
    }
    serde_json::from_slice(&out.stdout).map_err(|e| format!("parse drv snapshot: {e}"))
}

fn snapshot_installables(
    cwd: &Path,
    installables: &[String],
) -> Result<BTreeMap<String, String>, String> {
    let mut map = BTreeMap::new();
    for inst in installables {
        let target = if inst.ends_with(".drvPath") {
            inst.clone()
        } else {
            format!("{inst}.drvPath")
        };
        let out = Command::new("nix")
            .args(["eval", "--no-eval-cache", "--raw", &target])
            .current_dir(cwd)
            .output()
            .map_err(|e| format!("nix eval {target}: {e}"))?;
        if out.status.success() {
            map.insert(
                inst.clone(),
                String::from_utf8_lossy(&out.stdout).trim().to_string(),
            );
        }
    }
    Ok(map)
}

fn closure_stat(drv: &str, cwd: &Path) -> ClosureStat {
    let out = Command::new("nix-store")
        .args(["-qR", drv])
        .current_dir(cwd)
        .output();
    let (total, drvs, srcs) = match out {
        Ok(o) if o.status.success() => {
            let txt = String::from_utf8_lossy(&o.stdout);
            let lines: Vec<&str> = txt.lines().filter(|l| !l.trim().is_empty()).collect();
            let d = lines.iter().filter(|l| l.ends_with(".drv")).count();
            (lines.len(), d, lines.len().saturating_sub(d))
        }
        _ => (0, 0, 0),
    };
    ClosureStat {
        drv: Path::new(drv)
            .file_name()
            .map(|n| n.to_string_lossy().into_owned())
            .unwrap_or_else(|| drv.to_string()),
        total_paths: total,
        input_drvs: drvs,
        input_srcs: srcs,
    }
}

fn explain_drv_diff(old_drv: &str, new_drv: &str, cwd: &Path) -> String {
    // Prefer `nix-diff` if installed for rich recursive explanation
    if let Ok(o) = Command::new("nix-diff")
        .args(["--color", "never", old_drv, new_drv])
        .current_dir(cwd)
        .output()
    {
        if o.status.success() || !o.stdout.is_empty() {
            let txt = String::from_utf8_lossy(&o.stdout);
            let truncated: String = txt.lines().take(25).collect::<Vec<_>>().join("\n");
            if !truncated.trim().is_empty() {
                return truncated;
            }
        }
    }
    // Fallback: concise diff via `nix derivation show`
    format!("drv changed: {} -> {}", old_drv, new_drv)
}

fn diff_maps(
    label: String,
    base: &BTreeMap<String, String>,
    after: &BTreeMap<String, String>,
    cwd: &Path,
    max_diffs: usize,
) -> MutationResult {
    let mut invalidated = Vec::new();
    let mut unchanged = 0usize;
    let mut diffs = BTreeMap::new();

    for (k, old_d) in base {
        match after.get(k) {
            Some(new_d) if new_d == old_d => unchanged += 1,
            Some(new_d) => {
                invalidated.push(k.clone());
                if diffs.len() < max_diffs {
                    diffs.insert(k.clone(), explain_drv_diff(old_d, new_d, cwd));
                }
            }
            None => {
                invalidated.push(k.clone());
            }
        }
    }

    MutationResult {
        label,
        total_tracked: base.len(),
        invalidated_count: invalidated.len(),
        unchanged_count: unchanged,
        invalidated,
        diffs,
    }
}

pub fn run(opts: CacheOpts) -> Result<i32, String> {
    let root = git_root()?;
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    let use_flake_all = opts.flake_all || opts.installables.is_empty();
    let snapshot = |cwd: &Path| -> Result<BTreeMap<String, String>, String> {
        if use_flake_all {
            snapshot_flake_all(cwd, &opts.system)
        } else {
            snapshot_installables(cwd, &opts.installables)
        }
    };

    let mut closures = BTreeMap::new();
    let mut mutations = Vec::new();
    let tracked_count: usize;

    if let Some(between) = &opts.between {
        let (r1, r2) = between
            .split_once("..")
            .ok_or_else(|| "--between must have format BASE..HEAD".to_string())?;
        let wt1 = TempWorktree::create(&root, r1)?;
        let wt2 = TempWorktree::create(&root, r2)?;
        eprintln!("Snapshotting {r1}...");
        let base = snapshot(&wt1.path)?;
        tracked_count = base.len();
        eprintln!("Snapshotting {r2}...");
        let after = snapshot(&wt2.path)?;
        for (k, drv) in &after {
            if k.starts_with("check:") || k.starts_with("host-") || !use_flake_all {
                closures.insert(k.clone(), closure_stat(drv, &wt2.path));
            }
        }
        mutations.push(diff_maps(
            format!("{r1}..{r2}"),
            &base,
            &after,
            &wt2.path,
            opts.max_diffs,
        ));
    } else {
        let wt = if opts.working_tree {
            eprintln!("Snapshotting current working tree...");
            TempWorktree::create_from_working_tree(&root)?
        } else {
            eprintln!("Snapshotting baseline ({})...", opts.base_ref);
            TempWorktree::create(&root, &opts.base_ref)?
        };
        let base = snapshot(&wt.path)?;
        tracked_count = base.len();

        for (k, drv) in &base {
            if k.starts_with("check:") || k.starts_with("host-") || !use_flake_all {
                closures.insert(k.clone(), closure_stat(drv, &wt.path));
            }
        }

        for rel in &opts.mutate {
            let full = wt.path.join(rel);
            if !full.exists() {
                return Err(format!("mutation file does not exist: {}", rel.display()));
            }
            let orig = fs::read_to_string(&full).map_err(|e| format!("read {}: {e}", rel.display()))?;
            let suffix = if rel.extension().and_then(|s| s.to_str()) == Some("nix") {
                "\n# nixprof-cache-probe\n"
            } else {
                "\n"
            };
            fs::write(&full, format!("{orig}{suffix}"))
                .map_err(|e| format!("write {}: {e}", rel.display()))?;
            let _ = Command::new("git")
                .args(["add", &rel.to_string_lossy()])
                .current_dir(&wt.path)
                .status();

            eprintln!("Probing cache invalidation for edit to {}...", rel.display());
            let after = snapshot(&wt.path)?;
            mutations.push(diff_maps(
                format!("mutate:{}", rel.display()),
                &base,
                &after,
                &wt.path,
                opts.max_diffs,
            ));

            // Restore file before next mutation
            fs::write(&full, &orig).map_err(|e| format!("restore {}: {e}", rel.display()))?;
            let _ = Command::new("git")
                .args(["add", &rel.to_string_lossy()])
                .current_dir(&wt.path)
                .status();
        }
    }

    let report = CacheReport {
        report_type: "cache".into(),
        timestamp: ts,
        tracked_count,
        closures,
        mutations,
    };

    eprintln!("\n=== Derivation Build Closures ===");
    for (k, c) in &report.closures {
        eprintln!(
            "  {:<32} {:4} drvs  {:4} srcs  (total {})",
            k, c.input_drvs, c.input_srcs, c.total_paths
        );
    }

    if !report.mutations.is_empty() {
        eprintln!("\n=== Cache Invalidation Matrix ===");
        for m in &report.mutations {
            eprintln!(
                "  {:<36} invalidated {:2}/{}",
                m.label, m.invalidated_count, m.total_tracked
            );
            if !m.invalidated.is_empty() {
                let preview: Vec<&str> = m.invalidated.iter().take(12).map(String::as_str).collect();
                eprintln!("    changed: {}", preview.join(", "));
            }
            for (target, diff_txt) in &m.diffs {
                let first_line = diff_txt.lines().find(|l| !l.trim().is_empty()).unwrap_or("");
                eprintln!("    root-cause [{target}]: {first_line}");
            }
        }
    }

    let out_path = opts
        .out
        .unwrap_or_else(|| PathBuf::from(format!(".bench/results/cache-{ts}.json")));
    if let Some(p) = out_path.parent() {
        fs::create_dir_all(p).map_err(|e| format!("mkdir: {e}"))?;
    }
    let json = serde_json::to_string_pretty(&report).map_err(|e| format!("serialize: {e}"))?;
    fs::write(&out_path, json).map_err(|e| format!("write: {e}"))?;
    eprintln!("\nCache report saved to: {}", out_path.display());

    Ok(0)
}
