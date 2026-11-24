{
  description = "Antikythera (aky) — Formally verified Promise Theory & Semantic Spacetime declarative platform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    crane.url = "github:ipetkov/crane";
    impermanence = {
      url = "github:nix-community/impermanence";
      flake = false;
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    crane,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = f:
      lib.genAttrs systems (system:
        f {
          inherit system;
          pkgs = import nixpkgs {inherit system;};
        });

    realized = import ./lib/realize.nix {inherit inputs;};

    mkRust = pkgs: let
      craneLib = crane.mkLib pkgs;
      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./Cargo.toml
          ./Cargo.lock
          ./.clippy.toml
          ./deny.toml
          ./crates
        ];
      };
      commonArgs = {
        inherit src;
        strictDeps = true;
      };
      cargoArtifacts = craneLib.buildDepsOnly commonArgs;
    in {
      aky = craneLib.buildPackage (commonArgs
        // {
          inherit cargoArtifacts;
          pname = "aky";
          cargoExtraArgs = "-p aky-cli";
          meta.mainProgram = "aky";
        });
      clippy = craneLib.cargoClippy (commonArgs
        // {
          inherit cargoArtifacts;
          cargoClippyExtraArgs = "--workspace --all-targets -- --deny warnings";
        });
      test = craneLib.cargoTest (commonArgs // {inherit cargoArtifacts;});
      fmt = craneLib.cargoFmt {inherit src;};
    };

    # Hermetic offline Lean 4.35 oracle + 35-theorem Audit.lean (0 sorryAx, 0 extra inputs!)
    mkLeanOracle = pkgs:
      pkgs.stdenv.mkDerivation {
        pname = "aky-oracle";
        version = "0.2.0";
        src = lib.fileset.toSource {
          root = ./formal/lean;
          fileset = lib.fileset.unions [
            ./formal/lean/lakefile.toml
            ./formal/lean/Aky.lean
            ./formal/lean/Aky
          ];
        };
        nativeBuildInputs = [pkgs.lean4];
        buildPhase = ''
          export HOME=$TMPDIR
          lake build Aky aky-oracle
        '';
        doCheck = true;
        checkPhase = ''
          export HOME=$TMPDIR
          OUT=$(lake env lean Aky/Audit.lean)
          echo "$OUT"
          if echo "$OUT" | grep -q "sorryAx"; then
            echo "ERROR: sorryAx detected in Aky.Audit!" >&2
            exit 1
          fi
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp .lake/build/bin/aky-oracle $out/bin/aky-oracle
        '';
      };

    # Hermetic offline Quint 0.33.1 tests + exhaustive TLC verification
    mkQuintCheck = pkgs: let
      src = lib.fileset.toSource {
        root = ./formal/quint;
        fileset = ./formal/quint;
      };
    in
      pkgs.runCommand "aky-quint-check" {nativeBuildInputs = [pkgs.quint];} ''
        export HOME=$TMPDIR
        cp -r ${src}/* .
        chmod -R u+w .
        quint test triadic_pull.qnt
        quint test lifecycle_recovery.qnt
        quint test conditional_degradation.qnt
        quint verify --backend=tlc --invariant=allInvariants lifecycle_recovery.qnt
        quint verify --backend=tlc --invariant=allInvariants conditional_degradation.qnt
        echo "OK" > $out
      '';

    fleetTomlSrc = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./agents
        ./profiles
        ./policies
      ];
    };
  in {
    inherit (realized) nixosConfigurations resolvedBindings;

    packages = forAllSystems ({
      system,
      pkgs,
    }: let
      rust = mkRust pkgs;
    in
      (realized.standalonePackages system)
      // {
        default = rust.aky;
        inherit (rust) aky;
        aky-oracle = mkLeanOracle pkgs;
      });

    checks = forAllSystems ({pkgs, ...}: let
      rust = mkRust pkgs;
      oracle = mkLeanOracle pkgs;
      nixResolvedAstrolabe = pkgs.writeText "nix-resolved-astrolabe.json" (builtins.toJSON realized.resolvedBindings.astrolabe);
      nixResolvedIso = pkgs.writeText "nix-resolved-live-iso.json" (builtins.toJSON realized.resolvedBindings.live-iso);
    in {
      rust-clippy = rust.clippy;
      rust-test = rust.test;
      rust-fmt = rust.fmt;
      lean-audit = oracle;
      quint-check = mkQuintCheck pkgs;

      # Zero-Nix recursive Superagent boundary verification + Lean 4 DRT (real superagents + 500 fuzzed!)
      aky-fleet-and-drt = pkgs.runCommand "aky-fleet-and-drt" {} ''
        ${rust.aky}/bin/aky --root ${fleetTomlSrc} check
        ${rust.aky}/bin/aky --root ${fleetTomlSrc} drt --oracle ${oracle}/bin/aky-oracle --cases 500
        echo "OK" > $out
      '';

      # S1 CI Equivalence Check: proves recursive Nix `lib/realize.nix` == Rust `aky resolve` bit-for-bit!
      s1-binding-equiv = pkgs.runCommand "aky-s1-binding-equiv" {nativeBuildInputs = [pkgs.jq];} ''
        ${rust.aky}/bin/aky --root ${fleetTomlSrc} resolve astrolabe | jq -S . > rust-astro.json
        jq -S . ${nixResolvedAstrolabe} > nix-astro.json
        diff -u rust-astro.json nix-astro.json

        ${rust.aky}/bin/aky --root ${fleetTomlSrc} resolve live-iso | jq -S . > rust-iso.json
        jq -S . ${nixResolvedIso} > nix-iso.json
        diff -u rust-iso.json nix-iso.json
        echo "S1_RECURSIVE_EQUIV_OK" > $out
      '';
    });

    devShells = forAllSystems ({pkgs, ...}: {
      default = pkgs.mkShell {
        packages = [pkgs.alejandra pkgs.statix pkgs.deadnix pkgs.cargo pkgs.rustc pkgs.clippy pkgs.rustfmt pkgs.cargo-deny];
      };
      formal = pkgs.mkShell {
        packages = [pkgs.lean4 pkgs.quint];
      };
    });

    formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);
  };
}
