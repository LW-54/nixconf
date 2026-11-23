# General-purpose Nix & command profiler (nixprof) with SVG flamegraphs, Speedscope export,
# transparent `nix` PATH shim, cache-diff analyzer, and CI telemetry.
{lib, ...}: {
  perSystem = {pkgs, ...}: let
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./Cargo.toml
        ./Cargo.lock
        ./src
      ];
    };

    nixprof = pkgs.rustPlatform.buildRustPackage {
      pname = "nixprof";
      version = "0.1.0";
      inherit src;
      cargoLock.lockFile = ./Cargo.lock;

      nativeBuildInputs = [pkgs.makeBinaryWrapper];

      postInstall = ''
        wrapProgram $out/bin/nixprof \
          --suffix PATH : ${lib.makeBinPath [
          pkgs.hyperfine
          pkgs.nix-diff
          pkgs.samply
          pkgs.curl
          pkgs.git
        ]}
      '';

      meta = {
        description = "General-purpose Nix and command profiler with transparent nix PATH shim, SVG flamegraphs, Speedscope timelines, cache-diff, and CI telemetry.";
        mainProgram = "nixprof";
        helpCommand = "nixprof --help";
        usage = ''
          Profile any Nix command, script, or pre-commit hook with full eval flamegraphs and Gantt timelines:

          ```bash
          # Trace any command or script (auto-profiles all nested nix calls)
          nixprof trace -- ./.githooks/pre-commit

          # Statistical multi-run benchmark via hyperfine
          nixprof bench --runs 5 "nix flake check --no-build"

          # Native CPU profiling via samply (Firefox Profiler UI)
          nixprof native -- nix eval .#nixosConfigurations.x240.config.system.build.toplevel.drvPath

          # Derivation cache-invalidation matrix + nix-diff root causes
          nixprof cache-diff --flake-all --mutate README.md --mutate modules/features/foot.nix

          # GitHub Actions workflow/job/step telemetry
          nixprof ci

          # Side-by-side comparison of two saved reports
          nixprof compare before.json after.json
          ```
        '';
      };
    };
  in {
    packages.prof = nixprof;
  };
}
