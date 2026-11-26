{
  description = "Baugr -> Verft -> Ivaldi -> Skidbladnir: Strictly Fenced 4-Layer Promise Theory & Semantic Spacetime Ecosystem";

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

    # =========================================================================
    # L0: `baugr` — Universal Promise Theory & SST Framework (0 Nix, 0 Linux, 0 domain!)
    # Strictly sandbox-fenced via `lib.fileset.toSource { root = ./baugr; }` so it
    # has ZERO visibility into `verft/`, `ivaldi/`, or `skidbladnir/`!
    # =========================================================================
    mkBaugrRust = pkgs: let
      craneLib = crane.mkLib pkgs;
      src = lib.fileset.toSource {
        root = ./baugr;
        fileset = lib.fileset.unions [
          ./baugr/Cargo.toml
          ./baugr/Cargo.lock
          ./baugr/.clippy.toml
          ./baugr/deny.toml
          ./baugr/crates
        ];
      };
      commonArgs = {
        pname = "baugr-workspace";
        version = "0.1.0";
        inherit src;
        strictDeps = true;
      };
      cargoArtifacts = craneLib.buildDepsOnly commonArgs;
    in {
      baugr = craneLib.buildPackage (commonArgs
        // {
          inherit cargoArtifacts;
          pname = "baugr";
          cargoExtraArgs = "-p baugr-cli";
          meta.mainProgram = "baugr";
        });
      baugr-doc = craneLib.buildPackage (commonArgs
        // {
          inherit cargoArtifacts;
          pname = "baugr-doc";
          cargoExtraArgs = "-p baugr-doc";
          meta.mainProgram = "baugr-doc";
        });
      clippy = craneLib.cargoClippy (commonArgs
        // {
          inherit cargoArtifacts;
          cargoClippyExtraArgs = "--workspace --all-targets -- --deny warnings";
        });
      test = craneLib.cargoTest (commonArgs // {inherit cargoArtifacts;});
      fmt = craneLib.cargoFmt {
        pname = "baugr-workspace";
        version = "0.1.0";
        inherit src;
      };
    };

    # L0 Hermetic Offline Lean 4.35 Oracle + 54-Theorem `Baugr.Audit` (`0 sorryAx`!)
    # Covers `Baugr.Theory.*` (pure Promise Theory + SST) <- `Baugr.Engine.*` (+ Resolve Progress & Preservation!)
    mkBaugrOracle = pkgs:
      pkgs.stdenv.mkDerivation {
        pname = "baugr-oracle";
        version = "0.1.0";
        src = lib.fileset.toSource {
          root = ./baugr/formal/lean;
          fileset = lib.fileset.unions [
            ./baugr/formal/lean/lakefile.toml
            ./baugr/formal/lean/Baugr.lean
            ./baugr/formal/lean/Baugr
          ];
        };
        nativeBuildInputs = [pkgs.lean4];
        buildPhase = ''
          export HOME=$TMPDIR
          lake build Baugr baugr-oracle
        '';
        doCheck = true;
        checkPhase = ''
          export HOME=$TMPDIR
          OUT=$(lake env lean Baugr/Audit.lean)
          echo "$OUT"
          if echo "$OUT" | grep -q "sorryAx"; then
            echo "ERROR: sorryAx detected in Baugr.Audit!" >&2
            exit 1
          fi
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp .lake/build/bin/baugr-oracle $out/bin/baugr-oracle
        '';
      };

    # =========================================================================
    # L1: `verft` — Minimal Realization Framework (`hjem`-like) + Own Formal Verification
    # Strictly sandbox-fenced Quint/TLC models:
    #   - Positive exhaustive TLC safety + temporal liveness (`triadic_pull_tlc`)
    #   - Negative TLC counterexample falsifications (`userspace_drop` SIGKILL & `vaultwarden_only` DR deadlock!)
    # =========================================================================
    mkVerftQuintCheck = pkgs: let
      src = lib.fileset.toSource {
        root = ./verft/formal/quint;
        fileset = lib.fileset.unions [
          ./verft/formal/quint/types.qnt
          ./verft/formal/quint/triadic_pull.qnt
          ./verft/formal/quint/capability_session.qnt
          ./verft/formal/quint/lifecycle_recovery.qnt
          ./verft/formal/quint/conditional_degradation.qnt
        ];
      };
    in
      pkgs.runCommand "verft-quint-check" {nativeBuildInputs = [pkgs.quint];} ''
        export HOME=$TMPDIR
        cp -r ${src}/* .
        chmod -R u+w .

        # 1. Deterministic executable scenario tests
        quint test capability_session.qnt --main=capability_session
        quint test capability_session.qnt --main=capability_session_naive
        quint test lifecycle_recovery.qnt --main=lifecycle_recovery
        quint test lifecycle_recovery.qnt --main=lifecycle_recovery_naive
        quint test triadic_pull.qnt --main=triadic_pull
        quint test conditional_degradation.qnt

        # 2. Exhaustive positive TLC safety & temporal liveness proofs
        quint verify --backend=tlc --main=capability_session --invariant=allInvariants capability_session.qnt
        quint verify --backend=tlc --main=lifecycle_recovery --invariant=allInvariants lifecycle_recovery.qnt
        quint verify --backend=tlc --main=conditional_degradation --invariant=allInvariants conditional_degradation.qnt
        quint verify --backend=tlc --main=triadic_pull_tlc --invariant=allInvariants triadic_pull.qnt
        quint verify --backend=tlc --main=triadic_pull_tlc --temporal=eventuallyHealthyStabilization triadic_pull.qnt

        # 3. Non-vacuity proof: TLC MUST falsify naive mechanisms with real counterexamples!
        if quint verify --backend=tlc --main=capability_session_naive --invariant=invZeroResidueOnHost capability_session.qnt; then
          echo "ERROR: naive userspace_drop should have been FALSIFIED by TLC on SIGKILL!" >&2
          exit 1
        fi
        if quint verify --backend=tlc --main=lifecycle_recovery_naive --invariant=invNoDrDeadlock lifecycle_recovery.qnt; then
          echo "ERROR: naive vaultwarden_only DR should have been FALSIFIED by TLC!" >&2
          exit 1
        fi

        echo "VERFT_QUINT_SAFETY_LIVENESS_FALSIFICATION_OK" > $out
      '';

    # =========================================================================
    # L2 (`ivaldi`) + L3 (`skidbladnir`): Barrier-Free Multi-Root Fractal Composition!
    # =========================================================================
    realized = import ./verft/lib/realize.nix {
      inherit inputs;
      agentRoots = [
        ./ivaldi/agents
        ./skidbladnir/agents
      ];
      profileRoots = [
        ./ivaldi/profiles
      ];
      fleetRoot = "fleet";
    };

    ivaldiSrc = lib.fileset.toSource {
      root = ./ivaldi;
      fileset = lib.fileset.unions [
        ./ivaldi/agents
        ./ivaldi/profiles
        ./ivaldi/policies
      ];
    };

    skidbladnirSrc = lib.fileset.toSource {
      root = ./skidbladnir;
      fileset = lib.fileset.unions [
        ./skidbladnir/agents
        ./skidbladnir/policies
      ];
    };
  in {
    inherit (realized) nixosConfigurations resolvedBindings;

    packages = forAllSystems ({
      system,
      pkgs,
    }: let
      rust = mkBaugrRust pkgs;
    in
      (realized.standalonePackages system)
      // {
        default = rust.baugr;
        inherit (rust) baugr baugr-doc;
        baugr-oracle = mkBaugrOracle pkgs;
      });

    checks = forAllSystems ({pkgs, ...}: let
      rust = mkBaugrRust pkgs;
      oracle = mkBaugrOracle pkgs;
      equivTargets = realized.allSuperagentIds;
      nixResolvedFiles =
        lib.genAttrs equivTargets
        (t: pkgs.writeText "nix-resolved-${t}.json" (builtins.toJSON realized.resolvedBindings.${t}));
    in {
      # L0 `baugr` strict sandbox-isolated checks
      baugr-clippy = rust.clippy;
      baugr-test = rust.test;
      baugr-fmt = rust.fmt;
      baugr-lean-audit = oracle;

      # L1 `verft` mechanism-faithful Quint/TLC safety + temporal liveness + falsification
      verft-quint-check = mkVerftQuintCheck pkgs;

      # L0 Unix filter doc pipe: `baugr graph --json | baugr-doc`
      baugr-doc-pipe = pkgs.runCommand "baugr-doc-pipe" {} ''
        ${rust.baugr}/bin/baugr --root ${ivaldiSrc} --root ${skidbladnirSrc} graph --json \
          | ${rust.baugr-doc}/bin/baugr-doc --out $out --title "Skidbladnir Architecture"
        test -s $out/SUMMARY.md
        test -s $out/index.md
        test -s $out/scopes/fleet.md
      '';

      # L3 `skidbladnir` fleet check + 514-case Lean 4 DRT (checker + Resolve + SST + Cedar!) + 6-plane projections
      skidbladnir-fleet-and-drt = pkgs.runCommand "skidbladnir-fleet-and-drt" {} ''
        ${rust.baugr}/bin/baugr --root ${ivaldiSrc} --root ${skidbladnirSrc} check
        ${rust.baugr}/bin/baugr --root ${ivaldiSrc} --root ${skidbladnirSrc} drt --oracle ${oracle}/bin/baugr-oracle --cases 500
        ${rust.baugr}/bin/baugr --root ${ivaldiSrc} --root ${skidbladnirSrc} graph --impact obs-victoriametrics
        ${rust.baugr}/bin/baugr --root ${ivaldiSrc} --root ${skidbladnirSrc} project read-secret
        ${rust.baugr}/bin/baugr --root ${ivaldiSrc} --root ${skidbladnirSrc} project assume-capability
        ${rust.baugr}/bin/baugr --root ${ivaldiSrc} --root ${skidbladnirSrc} project admit-agent
        ${rust.baugr}/bin/baugr --root ${ivaldiSrc} --root ${skidbladnirSrc} project mesh-connect
        ${rust.baugr}/bin/baugr --root ${ivaldiSrc} --root ${skidbladnirSrc} project nats-queue
        echo "OK" > $out
      '';

      # L1 `verft` S1 Rust == Nix Binding Equivalence across ALL auto-discovered closed Superagents
      # + `assertNonPiercingNixos` proof checks!
      verft-s1-equiv = let
        fnBlocked = !(builtins.tryEval (realized.assertNonPiercingNixos "rogue" {attributes = [];} ({config, ...}: {inherit config;}))).success;
        importsBlocked = !(builtins.tryEval (realized.assertNonPiercingNixos "rogue" {attributes = [];} {imports = [({config, ...}: {inherit config;})];})).success;
        attrAllowed = (builtins.tryEval (realized.assertNonPiercingNixos "clean" {attributes = [];} {services.caddy.enable = true;})).success;
      in
        assert fnBlocked && importsBlocked && attrAllowed;
          pkgs.runCommand "verft-s1-equiv" {nativeBuildInputs = [pkgs.jq];} ''
            ${lib.concatMapStringsSep "\n" (t: ''
                ${rust.baugr}/bin/baugr --root ${ivaldiSrc} --root ${skidbladnirSrc} resolve ${t} | jq -S . > rust-${t}.json
                jq -S . ${nixResolvedFiles.${t}} > nix-${t}.json
                diff -u rust-${t}.json nix-${t}.json
              '')
              equivTargets}
            echo "VERFT_S1_ALL_SUPERAGENTS_EQUIV_OK" > $out
          '';
    });

    devShells = forAllSystems ({system, ...}: realized.devShells system);

    formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);
  };
}
