mod bench;
mod cache;
mod ci;
mod compare;
mod flamegraph;
mod metrics;
mod native;
mod shim;
mod trace;

use clap::{Parser, Subcommand};
use std::path::PathBuf;
use std::process::ExitCode;

#[derive(Parser, Debug)]
#[command(
    name = "nixprof",
    version,
    about = "General-purpose Nix & command profiler with transparent nix PATH shim, SVG flamegraphs, Speedscope timelines, cache-diff, and CI telemetry"
)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Trace any command or script, transparently profiling every nested `nix` invocation
    Trace {
        /// Force cold Nix evaluation (--no-eval-cache) on all intercepted nix calls
        #[arg(long)]
        cold: bool,

        /// Nix eval-profiler sampling frequency in Hz
        #[arg(long, default_value_t = 500)]
        freq: u32,

        /// Output directory for trace artifacts (report.json, eval.svg, timeline.speedscope.json)
        #[arg(short, long)]
        out: Option<PathBuf>,

        /// Human label for this trace
        #[arg(long, default_value = "trace")]
        name: String,

        /// Skip SVG flamegraph generation
        #[arg(long)]
        no_svg: bool,

        /// Skip Speedscope JSON generation
        #[arg(long)]
        no_speedscope: bool,

        /// Suppress terminal summary (still prints artifact paths)
        #[arg(short, long)]
        quiet: bool,

        /// Forward raw Nix internal-json stderr messages
        #[arg(long)]
        verbose_nix: bool,

        /// Command and arguments to trace (after --)
        #[arg(required = true, trailing_var_arg = true, allow_hyphen_values = true)]
        cmd: Vec<String>,
    },

    /// Statistical multi-run benchmark (delegates to hyperfine when available) + profiled Nix stats
    Bench {
        /// Number of benchmark runs
        #[arg(short = 'r', long, default_value_t = 3)]
        runs: u32,

        /// Number of warmup runs
        #[arg(short = 'w', long, default_value_t = 1)]
        warmup: u32,

        /// Pass --no-eval-cache to intercepted nix calls during the profiled pass
        #[arg(long)]
        cold: bool,

        /// Output JSON report path
        #[arg(short, long)]
        out: Option<PathBuf>,

        /// Command string(s) to benchmark (pass multiple commands to compare)
        #[arg(required = true)]
        commands: Vec<String>,
    },

    /// Native CPU profiling via samply (Firefox Profiler interactive flamegraph & call tree)
    Native {
        /// Output profile path (.json.gz)
        #[arg(short, long)]
        out: Option<PathBuf>,

        /// Save only (do not launch browser UI)
        #[arg(long)]
        save_only: bool,

        /// Command and arguments to profile (after --)
        #[arg(required = true, trailing_var_arg = true, allow_hyphen_values = true)]
        cmd: Vec<String>,
    },

    /// Analyze Nix derivation cache invalidations and build-closure sizes
    CacheDiff {
        /// Specific flake installables to track (or use --flake-all)
        #[arg(value_name = "INSTALLABLE")]
        installables: Vec<String>,

        /// Auto-discover checks, packages, devShells, and nixosConfigurations in current flake
        #[arg(long)]
        flake_all: bool,

        /// Target system for --flake-all discovery
        #[arg(long, default_value = "x86_64-linux")]
        system: String,

        /// Synthetic file(s) to mutate in an isolated temporary git worktree (repeatable)
        #[arg(long = "mutate")]
        mutate: Vec<PathBuf>,

        /// Compare two git refs instead of synthetic mutations (format: BASE..HEAD)
        #[arg(long)]
        between: Option<String>,

        /// Base git ref for worktree mutations
        #[arg(long, default_value = "HEAD")]
        base_ref: String,

        /// Snapshot the current uncommitted working tree instead of a committed git ref
        #[arg(long)]
        working_tree: bool,

        /// Maximum number of invalidated derivations to run `nix-diff` on per mutation
        #[arg(long, default_value_t = 8)]
        max_diffs: usize,

        /// Output JSON report path
        #[arg(short, long)]
        out: Option<PathBuf>,
    },

    /// Analyze GitHub Actions workflow/job/step timings, runner overhead, and critical paths
    Ci {
        /// Repository slug owner/repo (auto-detected from git remote origin if omitted)
        #[arg(long)]
        repo: Option<String>,

        /// Number of recent workflow runs to inspect
        #[arg(long, default_value_t = 12)]
        limit: u32,

        /// Output JSON report path
        #[arg(short, long)]
        out: Option<PathBuf>,
    },

    /// Compare two saved nixprof JSON reports side-by-side
    Compare {
        /// Baseline report JSON
        before: PathBuf,
        /// New report JSON
        after: PathBuf,
    },

    /// Export CI, binary cache, Nix eval, and cache-isolation telemetry in Prometheus textfile format
    Metrics {
        /// Collect GitHub Actions CI timings, substituter latency probes, and Attic disk usage
        #[arg(long)]
        ci: bool,

        /// Collect uncached Nix eval timings, allocations, and README.md cache-isolation probe
        #[arg(long)]
        eval: bool,

        /// GitHub repository slug owner/repo
        #[arg(long)]
        repo: Option<String>,

        /// Number of recent workflow runs to inspect
        #[arg(long, default_value_t = 12)]
        limit: u32,

        /// Attic binary cache base URL (e.g. https://cache.adje.app/nixconf)
        #[arg(long, default_value = "https://cache.adje.app/nixconf")]
        attic_url: String,

        /// Cachix binary cache base URL
        #[arg(long, default_value = "https://lw-54.cachix.org")]
        cachix_url: String,

        /// Local Attic storage directory to measure disk usage (e.g. /var/lib/atticd)
        #[arg(long)]
        attic_dir: Option<PathBuf>,

        /// Path to local .githooks/pre-commit JSON telemetry file to export
        #[arg(long)]
        precommit_state: Option<PathBuf>,

        /// Local git repository checkout for --eval benchmarks
        #[arg(long, default_value = ".")]
        repo_dir: PathBuf,

        /// Target Nix system for --eval benchmarks
        #[arg(long, default_value = "x86_64-linux")]
        system: String,

        /// Output Prometheus .prom file path (atomic write; prints to stdout if omitted)
        #[arg(short, long)]
        out: Option<PathBuf>,
    },
}

fn is_nix_shim_invocation() -> bool {
    if std::env::var_os("NIXPROF_SESSION_DIR").is_none() {
        return false;
    }
    std::env::args_os()
        .next()
        .and_then(|p| PathBuf::from(p).file_name().map(|n| n.to_string_lossy().into_owned()))
        .map(|name| name == "nix")
        .unwrap_or(false)
}

fn main() -> ExitCode {
    // Transparent multi-call PATH shim mode when invoked as `nix` inside `nixprof trace`
    if is_nix_shim_invocation() {
        let code = shim::run_shim();
        return ExitCode::from((code & 0xff) as u8);
    }

    let cli = Cli::parse();
    let res = match cli.command {
        Commands::Trace {
            cold,
            freq,
            out,
            name,
            no_svg,
            no_speedscope,
            quiet,
            verbose_nix,
            cmd,
        } => trace::run(trace::TraceOpts {
            cold,
            freq,
            out,
            name,
            svg: !no_svg,
            speedscope: !no_speedscope,
            quiet,
            verbose_nix,
            cmd,
        }),
        Commands::Bench {
            runs,
            warmup,
            cold,
            out,
            commands,
        } => bench::run(bench::BenchOpts {
            runs,
            warmup,
            cold,
            out,
            commands,
        }),
        Commands::Native {
            out,
            save_only,
            cmd,
        } => native::run(out, save_only, cmd),
        Commands::CacheDiff {
            installables,
            flake_all,
            system,
            mutate,
            between,
            base_ref,
            working_tree,
            max_diffs,
            out,
        } => cache::run(cache::CacheOpts {
            installables,
            flake_all,
            system,
            mutate,
            between,
            base_ref,
            working_tree,
            max_diffs,
            out,
        }),
        Commands::Ci { repo, limit, out } => ci::run(repo, limit, out),
        Commands::Compare { before, after } => compare::run(&before, &after),
        Commands::Metrics {
            ci,
            eval,
            repo,
            limit,
            attic_url,
            cachix_url,
            attic_dir,
            precommit_state,
            repo_dir,
            system,
            out,
        } => metrics::run(metrics::MetricsOpts {
            ci,
            eval,
            repo,
            limit,
            attic_url,
            cachix_url,
            attic_dir,
            precommit_state,
            repo_dir,
            system,
            out,
        }),
    };

    match res {
        Ok(code) => ExitCode::from((code & 0xff) as u8),
        Err(err) => {
            eprintln!("nixprof error: {err}");
            ExitCode::from(1)
        }
    }
}
