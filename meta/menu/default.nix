{
  self,
  lib,
  config,
  ...
}: let
  topConfig = config;

  oneLine = str:
    lib.trim (
      builtins.replaceStrings ["\n" "\r" "\t"] [" " " " " "] (
        if str == null
        then ""
        else toString str
      )
    );

  encodeMultiline = str:
    lib.trim (
      builtins.replaceStrings ["\\" "\n" "\r" "\t"] ["\\\\" "\\n" "" "  "] (
        if str == null
        then ""
        else toString str
      )
    );

  mkEntryLine = {
    category,
    title,
    command,
    description ? "",
    origin ? "",
    notes ? "",
  }:
    lib.concatStringsSep "\t" [
      (oneLine category)
      (oneLine title)
      (oneLine command)
      (oneLine description)
      (oneLine origin)
      (encodeMultiline notes)
    ];
in {
  perSystem = {
    pkgs,
    config,
    system,
    ...
  }: let
    hosts = topConfig.host or {};
    hostNames = builtins.attrNames hosts;

    resolveFile =
      if topConfig ? internal && topConfig.internal ? graph && topConfig.internal.graph ? extractors && topConfig.internal.graph.extractors ? onto
      then topConfig.internal.graph.extractors.onto.resolveFile
      else (_: _: null);

    formatOrigin = kind: name: let
      file = resolveFile kind name;
    in
      if file != null
      then "${kind}.${name} (${file})"
      else "${kind}.${name}";

    pkgArgs = {
      inherit pkgs self system;
      self' = {
        packages = config.packages or {};
        devShells = config.devShells or {};
      };
    };

    collectOrigins = facet: kind: instances:
      lib.concatMapAttrs (
        instName: instDef:
          if instDef ? ${facet}
          then let
            outSet =
              if builtins.isFunction instDef.${facet}
              then instDef.${facet} pkgArgs
              else instDef.${facet};
          in
            lib.genAttrs (builtins.attrNames outSet) (_: formatOrigin kind instName)
          else {}
      )
      instances;

    packageOrigins =
      (collectOrigins "packages" "feature" (topConfig.feature or {}))
      // (collectOrigins "packages" "implementation" (topConfig.implementation or {}))
      // (collectOrigins "packages" "contract" (topConfig.contract or {}))
      // {
        ci = "meta/ci (meta/ci/default.nix)";
        docs = "meta/docs (meta/docs/cli.nix)";
        graph = "meta/graph (meta/graph/cli.nix)";
        menu = "meta/menu (meta/menu/default.nix)";
        test = "meta/tests (meta/tests/default.nix)";
      };

    devShellOrigins =
      (collectOrigins "devShells" "feature" (topConfig.feature or {}))
      // (collectOrigins "devShells" "implementation" (topConfig.implementation or {}))
      // (collectOrigins "devShells" "contract" (topConfig.contract or {}))
      // {
        default = "meta/devenv (meta/devenv/default.nix)";
      };

    devShellNames = builtins.attrNames (config.devShells or {});

    ignoredPackages = [
      "cpg-json"
      "nixconf-json"
      "devenv-test"
      "devenv-up"
    ];
    packageNames =
      lib.filter (n: !builtins.elem n ignoredPackages)
      (builtins.attrNames (config.packages or {}));

    systemEntries =
      lib.concatMap (
        hostName: let
          hostDesc = oneLine (hosts.${hostName}.description or "NixOS host ${hostName}.");
          hostOrigin = formatOrigin "host" hostName;
        in [
          (mkEntryLine {
            category = "system";
            title = "switch (${hostName})";
            command = "sudo nixos-rebuild switch --flake .#${hostName}";
            description = "Rebuild and activate configuration on ${hostName}. ${hostDesc}";
            origin = hostOrigin;
            notes = "Requires sudo password.";
          })
          (mkEntryLine {
            category = "system";
            title = "test (${hostName})";
            command = "sudo nixos-rebuild test --flake .#${hostName}";
            description = "Build and activate configuration on ${hostName} without adding a boot entry.";
            origin = hostOrigin;
            notes = "Requires sudo password.";
          })
          (mkEntryLine {
            category = "system";
            title = "boot (${hostName})";
            command = "sudo nixos-rebuild boot --flake .#${hostName}";
            description = "Build and install configuration to bootloader for ${hostName} without switching.";
            origin = hostOrigin;
            notes = "Requires sudo password.";
          })
          (mkEntryLine {
            category = "system";
            title = "build (${hostName})";
            command = "nom-build .#nixosConfigurations.${hostName}.config.system.build.toplevel";
            description = "Build ${hostName} system toplevel closure using nix-output-monitor into ./result.";
            origin = hostOrigin;
            notes = hostDesc;
          })
        ]
      )
      hostNames;

    devShellEntries =
      map (
        shellName: let
          origin = devShellOrigins.${shellName} or "flake.devShells.${shellName}";
        in
          if shellName == "default"
          then
            mkEntryLine {
              category = "devshell";
              title = "enter: default (devenv)";
              command = "nix develop .#default";
              description = "Main development shell with devenv, just, fzf, and linters.";
              inherit origin;
            }
          else let
            sDef = config.devShells.${shellName};
            desc =
              if (sDef.meta.description or "") != ""
              then sDef.meta.description
              else "Development shell ${shellName}.";
            notes = sDef.meta.usage or "";
          in
            mkEntryLine {
              category = "devshell";
              title = "enter: ${shellName}";
              command = "nix develop .#${shellName}";
              description = desc;
              inherit origin notes;
            }
      )
      devShellNames;

    packageEntries =
      (map (
          pkgName: let
            origin = packageOrigins.${pkgName} or "flake.packages.${pkgName}";
          in
            if pkgName == "menu"
            then
              mkEntryLine {
                category = "package";
                title = "run: menu";
                command = "nix run .#menu";
                description = "Interactive fuzzy command palette and task runner dynamically derived from nixconf flake outputs.";
                inherit origin;
                notes = "Help: menu --help";
              }
            else let
              pDef = config.packages.${pkgName};
              desc =
                if (pDef.meta.description or "") != ""
                then pDef.meta.description
                else "Run exported flake package ${pkgName}.";
              helpCmd = pDef.meta.helpCommand or null;
              homepage = pDef.meta.homepage or null;
              usage = pDef.meta.usage or null;
              metaHeader = lib.concatStringsSep "\n" (lib.filter (s: s != "") [
                (
                  if helpCmd != null
                  then "Help command: `${helpCmd}`"
                  else ""
                )
                (
                  if homepage != null
                  then "Homepage: ${homepage}"
                  else ""
                )
              ]);
              notes = lib.concatStringsSep "\n\n" (lib.filter (s: s != "") [
                metaHeader
                (
                  if usage != null
                  then lib.trim usage
                  else ""
                )
              ]);
            in
              mkEntryLine {
                category = "package";
                title = "run: ${pkgName}";
                command = "nix run .#${pkgName}";
                description = desc;
                inherit origin notes;
              }
        )
        packageNames)
      ++ (lib.optionals (builtins.elem "storage" packageNames) [
        (mkEntryLine {
          category = "package";
          title = "run: storage (--list)";
          command = "nix run .#storage -- --list";
          description = "List evaluated storage providers, slices, mounts, and SOPS stores.";
          origin = packageOrigins.storage or "contract.storage";
        })
        (mkEntryLine {
          category = "package";
          title = "run: storage (--check)";
          command = "nix run .#storage -- --check";
          description = "Verify declarative storage SOPS secrets and Hetzner Storage Box state.";
          origin = packageOrigins.storage or "contract.storage";
        })
      ]);

    docsEntries = [
      (mkEntryLine {
        category = "docs";
        title = "write documentation";
        command = "nix run .#docs -- --write";
        description = "Regenerate all markdown pages (README.md, docs/**/*.md) and delete stale pages.";
        origin = "meta/docs (meta/docs/cli.nix)";
        notes = "Updates working tree documentation files.";
      })
      (mkEntryLine {
        category = "docs";
        title = "check documentation";
        command = "nix run .#docs -- --check";
        description = "Verify that working tree matches evaluated documentation generator.";
        origin = "meta/docs (meta/docs/cli.nix)";
        notes = "Exits 1 if committed documentation is stale.";
      })
      (mkEntryLine {
        category = "docs";
        title = "docs health & coverage";
        command = "nix run .#docs -- --health";
        description = "Print documentation coverage metrics, warning counts, and missing docstrings.";
        origin = "meta/docs (meta/docs/audit.nix)";
      })
      (mkEntryLine {
        category = "docs";
        title = "list generated docs";
        command = "nix run .#docs -- --list";
        description = "List all documentation files produced by the generator.";
        origin = "meta/docs (meta/docs/cli.nix)";
      })
    ];

    ciEntries = [
      (mkEntryLine {
        category = "ci";
        title = "write CI workflows";
        command = "nix run .#ci -- --write";
        description = "Synchronize compiled GitHub Actions workflows to .github/workflows/.";
        origin = "meta/ci (meta/ci/default.nix)";
        notes = "Updates .github/workflows/*.yml.";
      })
      (mkEntryLine {
        category = "ci";
        title = "check CI workflows";
        command = "nix run .#ci -- --check";
        description = "Verify that .github/workflows/ matches evaluated Nix workflow specifications.";
        origin = "meta/ci (meta/ci/default.nix)";
        notes = "Exits 1 if workflows are out of sync.";
      })
    ];

    graphEntries = [
      (mkEntryLine {
        category = "graph";
        title = "graph stats";
        command = "nix run .#graph -- --stats";
        description = "Print LPG and CPG graph node, edge, and relation counts.";
        origin = "meta/graph (meta/graph/cli.nix)";
      })
      (mkEntryLine {
        category = "graph";
        title = "export graph json";
        command = "nix run .#graph -- --json";
        description = "Print the complete architecture LPG graph as JSON to stdout.";
        origin = "meta/graph (meta/graph/cli.nix)";
      })
      (mkEntryLine {
        category = "graph";
        title = "export cpg json";
        command = "nix run .#graph -- --cpg-json";
        description = "Print the multi-strata Code Property Graph (CPG) as JSON to stdout.";
        origin = "meta/graph (meta/graph/cli.nix)";
      })
      (mkEntryLine {
        category = "graph";
        title = "inspect subgraph";
        command = "nix run .#graph -- --help";
        description = "Inspect Mermaid neighborhood for a node URN.";
        origin = "meta/graph (meta/graph/cli.nix)";
        notes = "UseCtrl-E to edit and pass --subgraph <URN>.";
      })
    ];

    tackEntries = [
      (mkEntryLine {
        category = "tack";
        title = "tack look";
        command = "tack look";
        description = "Inspect upstream drift of pinned flake inputs without modifying lockfile.";
        origin = formatOrigin "feature" "tack";
      })
      (mkEntryLine {
        category = "tack";
        title = "tack update (all)";
        command = "tack update";
        description = "Update all pinned dependencies in .tack/pins.toml and write pins.lock.json.";
        origin = formatOrigin "feature" "tack";
        notes = "Updates .tack/pins.lock.json.";
      })
      (mkEntryLine {
        category = "tack";
        title = "tack tree";
        command = "tack tree";
        description = "Show input relationship tree and followed dependencies.";
        origin = formatOrigin "feature" "tack";
      })
      (mkEntryLine {
        category = "tack";
        title = "tack verify";
        command = "tack verify";
        description = "Verify cryptographically signed commits on pins requiring signers.";
        origin = formatOrigin "feature" "tack";
      })
    ];

    testEntries =
      [
        (mkEntryLine {
          category = "test";
          title = "test: eval (all hosts)";
          command = "nix run .#test -- eval";
          description = "Evaluate all host configurations and run fast static checks (bootloader, login, ssh).";
          origin = "meta/tests (meta/tests/default.nix)";
          notes = "Tier 1: Fast evaluation check (seconds, no KVM required).";
        })
        (mkEntryLine {
          category = "test";
          title = "test: inspect (all hosts)";
          command = "nix run .#test -- inspect";
          description = "Validate /etc/fstab, PAM, sudoers, and sshd in a pure sandbox without KVM.";
          origin = "meta/tests (meta/tests/default.nix)";
          notes = "Tier 2: Sandbox filesystem & config inspection (no KVM required).";
        })
        (mkEntryLine {
          category = "test";
          title = "test: list hosts & checks";
          command = "nix run .#test -- list";
          description = "List all hosts, available test tiers, and registered test checks.";
          origin = "meta/tests (meta/tests/default.nix)";
        })
      ]
      ++ lib.concatMap (
        hostName: let
          hostDesc = oneLine (hosts.${hostName}.description or "NixOS host ${hostName}.");
          hostOrigin = formatOrigin "host" hostName;
        in [
          (mkEntryLine {
            category = "test";
            title = "test: vm (${hostName})";
            command = "nix run .#test -- vm ${hostName}";
            description = "Boot ${hostName} in QEMU and verify runtime checks (secrets, login, sudo, ssh, units).";
            origin = hostOrigin;
            notes = "Tier 3: Ephemeral QEMU VM test (requires KVM).\nHost: ${hostDesc}";
          })
          (mkEntryLine {
            category = "test";
            title = "test: install (${hostName})";
            command = "nix run .#test -- install ${hostName}";
            description = "Partition Disko layout, install ${hostName}, and verify reboot survival.";
            origin = hostOrigin;
            notes = "Tier 4: Full Disko partitioning + cold reboot persistence test (requires KVM).";
          })
          (mkEntryLine {
            category = "test";
            title = "test: run interactive VM (${hostName})";
            command = "nix run .#test -- run ${hostName}";
            description = "Boot ${hostName} interactive VM with stand-in secrets (SSH port forwarded to localhost:2222).";
            origin = hostOrigin;
            notes = "Requires KVM.";
          })
        ]
      )
      hostNames;

    checkEntries = [
      (mkEntryLine {
        category = "check";
        title = "format all files (nix fmt .)";
        command = "nix fmt .";
        description = "Format all Nix files across repository with Alejandra.";
        origin = "meta/formatter.nix";
      })
      (mkEntryLine {
        category = "check";
        title = "check formatting";
        command = "alejandra --check .";
        description = "Verify code formatting without modifying files.";
        origin = "meta/formatter.nix";
      })
      (mkEntryLine {
        category = "check";
        title = "lint dead code & patterns";
        command = "statix check && deadnix";
        description = "Run Statix anti-pattern checks and Deadnix unused variable detection.";
        origin = "meta/devenv (meta/devenv/packages.nix)";
      })
      (mkEntryLine {
        category = "check";
        title = "flake check";
        command = "nix flake check";
        description = "Run all flake validation checks, primitive schema checks, CI sync, and doc sync checks.";
        origin = "flake.nix";
      })
    ];

    staticCatalogFile = pkgs.writeText "nixconf-menu-catalog.tsv" (
      lib.concatStringsSep "\n" (
        systemEntries
        ++ devShellEntries
        ++ packageEntries
        ++ docsEntries
        ++ ciEntries
        ++ graphEntries
        ++ tackEntries
        ++ testEntries
        ++ checkEntries
      )
      + "\n"
    );
  in {
    packages.menu = pkgs.writeShellApplication {
      name = "menu";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.findutils
        pkgs.fzf
        pkgs.gawk
        pkgs.git
        pkgs.wl-clipboard
        pkgs.xclip
      ];
      meta = {
        description = "Interactive fuzzy command palette and task runner dynamically derived from nixconf flake outputs.";
        helpCommand = "menu --help";
      };
      text = ''
        REPO_ROOT="''${DEVENV_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
        cd "$REPO_ROOT"

        CATEGORIES=(all ide system devshell package secrets test docs ci graph tack check)

        normalize_category() {
          local raw="''${1:-all}"
          raw="''${raw#[}"
          raw="''${raw%]}"
          raw="''${raw,,}"
          if [ -z "$raw" ]; then
            raw="all"
          fi
          printf '%s' "$raw"
        }

        # Internal: advance or set active category in state file
        if [ "''${1:-}" = "--internal-step" ]; then
          DIRECTION="''${2:-next}"
          STATE_FILE="''${3:-}"
          CURRENT="all"
          if [ -n "$STATE_FILE" ] && [ -f "$STATE_FILE" ]; then
            CURRENT=$(<"$STATE_FILE")
          fi
          CURRENT=$(normalize_category "$CURRENT")

          if [ "$DIRECTION" = "all" ]; then
            printf 'all' >"$STATE_FILE"
            exit 0
          fi

          TOTAL=''${#CATEGORIES[@]}
          IDX=0
          for i in "''${!CATEGORIES[@]}"; do
            if [ "''${CATEGORIES[$i]}" = "$CURRENT" ]; then
              IDX=$i
              break
            fi
          done

          if [ "$DIRECTION" = "prev" ]; then
            NEXT_IDX=$(( (IDX - 1 + TOTAL) % TOTAL ))
          else
            NEXT_IDX=$(( (IDX + 1) % TOTAL ))
          fi
          printf '%s' "''${CATEGORIES[$NEXT_IDX]}" >"$STATE_FILE"
          exit 0
        fi

        # Internal: render interactive category bar header
        if [ "''${1:-}" = "--internal-header" ]; then
          STATE_FILE="''${2:-}"
          CURRENT="all"
          if [ -n "$STATE_FILE" ] && [ -f "$STATE_FILE" ]; then
            CURRENT=$(<"$STATE_FILE")
          fi
          CURRENT=$(normalize_category "$CURRENT")

          BAR=""
          for cat in "''${CATEGORIES[@]}"; do
            label="$cat"
            if [ "$cat" = "all" ]; then
              label="ALL"
            fi
            if [ "$cat" = "$CURRENT" ]; then
              BAR+="''${BAR:+ }\033[1;36;7m ''${label} \033[0m"
            else
              BAR+="''${BAR:+ }\033[0;90m''${label}\033[0m"
            fi
          done
          echo -e "Categories: $BAR"
          echo -e "\033[0;90m[Enter] Run · [Tab/S-Tab] Category · [Ctrl-A] All · [Ctrl-E] Edit · [Ctrl-Y] Copy · [Alt-Enter] Print\033[0m"
          exit 0
        fi

        # Preview generator called by fzf preview
        if [ "''${1:-}" = "--preview" ]; then
          shift
          CATEGORY="''${1:-}"
          TITLE="''${2:-}"
          COMMAND="''${3:-}"
          DESCRIPTION="''${4:-}"
          ORIGIN="''${5:-}"
          NOTES="''${6:-}"

          echo -e "\033[1;36m━━━ ''${TITLE} ━━━\033[0m"
          echo -e "\033[1;33mCategory:\033[0m    [''${CATEGORY}]"
          if [ -n "$ORIGIN" ]; then
            echo -e "\033[1;35mOrigin:\033[0m      ''${ORIGIN}"
          fi
          echo ""
          echo -e "\033[1;32mCommand:\033[0m"
          echo -e "  \033[1;37m''${COMMAND}\033[0m"
          echo ""
          echo -e "\033[1;34mDescription:\033[0m"
          echo -e "  ''${DESCRIPTION}"

          if [ -n "$NOTES" ]; then
            echo ""
            echo -e "\033[1;35mDetails & Usage:\033[0m"
            printf '%b\n' "$NOTES" | awk '
              /^```/ { in_code = !in_code; next }
              in_code { printf "  \033[0;36m%s\033[0m\n", $0; next }
              { printf "  %s\n", $0 }
            '
          fi

          # Live SOPS secret file inspection (encrypted key names & recipients without decrypting)
          if [ "$CATEGORY" = "secrets" ]; then
            SECRET_PATH="''${COMMAND#sops }"
            if [ ! -f "$SECRET_PATH" ] && [ -f "${self}/$SECRET_PATH" ]; then
              SECRET_PATH="${self}/$SECRET_PATH"
            fi
            if [ -f "$SECRET_PATH" ]; then
              echo ""
              echo -e "\033[1;33mEncrypted Keys in Store:\033[0m"
              awk -F: '/^[a-zA-Z0-9_-]+:/ && $1 != "sops" { printf "  \033[1;37m•\033[0m %s\n", $1 }' "$SECRET_PATH"
              LAST_MOD=$(awk '/lastmodified:/ { gsub(/"/, "", $2); print $2; exit }' "$SECRET_PATH")
              RECIPIENTS=$(awk '/recipient:/ { print $NF }' "$SECRET_PATH")
              if [ -n "$LAST_MOD" ]; then
                echo ""
                echo -e "\033[1;34mSOPS Metadata:\033[0m"
                echo -e "  Last modified: ''${LAST_MOD}"
              fi
              if [ -n "$RECIPIENTS" ]; then
                echo -e "  Age recipients:"
                for r in $RECIPIENTS; do
                  NAME=""
                  if [ -f "$REPO_ROOT/.sops.yaml" ]; then
                    NAME=$(awk -v key="$r" '$0 ~ key { gsub(/:/, "", $1); print $1; exit }' "$REPO_ROOT/.sops.yaml")
                  fi
                  if [ -n "$NAME" ]; then
                    echo -e "    \033[0;32m✓\033[0m \033[1;37m''${NAME}\033[0m (\033[0;90m''${r:0:16}…\033[0m)"
                  else
                    echo -e "    \033[0;32m✓\033[0m \033[0;90m''${r}\033[0m"
                  fi
                done
              fi
            fi
          fi
          exit 0
        fi

        generate_secrets_entries() {
          local secrets_dir="$REPO_ROOT/secrets"
          if [ ! -d "$secrets_dir" ] && [ -d "${self}/secrets" ]; then
            secrets_dir="${self}/secrets"
          fi
          if [ -d "$secrets_dir" ]; then
            while IFS= read -r rel_secret; do
              [ -z "$rel_secret" ] && continue
              printf "secrets\tedit: %s\tsops secrets/%s\tEdit SOPS-encrypted secret store secrets/%s.\t.sops.yaml (secrets/%s)\tRequires an authorized age key (enter sops-admin or sops-host devshell).\n" \
                "$rel_secret" "$rel_secret" "$rel_secret" "$rel_secret"
            done < <(find "$secrets_dir" -type f \( -name '*.yaml' -o -name '*.yml' -o -name '*.json' \) -printf '%P\n' | sort)
          fi
        }

        generate_raw_catalog() {
          cat "${staticCatalogFile}"
          generate_secrets_entries
        }

        # Format raw catalog with aligned ANSI display column in field 2:
        # cat \t display \t title \t cmd \t desc \t origin \t notes
        render_filtered_catalog() {
          local filter_cat
          filter_cat=$(normalize_category "''${1:-all}")
          generate_raw_catalog | awk -F'\t' -v filter="$filter_cat" '
            filter != "all" && $1 != filter { next }
            {
              cat = $1
              title = $2
              cmd = $3
              desc = $4
              origin = $5
              notes = $6

              color = "\033[1;34m"
              if (cat == "system")   color = "\033[1;31m"
              if (cat == "devshell") color = "\033[1;35m"
              if (cat == "package")  color = "\033[1;32m"
              if (cat == "secrets")  color = "\033[1;33m"
              if (cat == "test")     color = "\033[1;34m"
              if (cat == "docs")     color = "\033[0;36m"
              if (cat == "ci")       color = "\033[0;35m"
              if (cat == "graph")    color = "\033[0;32m"
              if (cat == "tack")     color = "\033[0;33m"
              if (cat == "check")    color = "\033[1;37m"

              badge = sprintf("[%s]", cat)
              display = sprintf("%s%-10s\033[0m  \033[1;37m%-36s\033[0m  \033[0;90m%s\033[0m", color, badge, title, cmd)
              printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", cat, display, title, cmd, desc, origin, notes
            }
          '
        }

        if [ "''${1:-}" = "--internal-list" ]; then
          STATE_FILE="''${2:-}"
          CURRENT="all"
          if [ -n "$STATE_FILE" ] && [ -f "$STATE_FILE" ]; then
            CURRENT=$(<"$STATE_FILE")
          fi
          render_filtered_catalog "$CURRENT"
          exit 0
        fi

        CATEGORY_FILTER="all"
        INITIAL_QUERY=""
        LIST_ONLY=0

        while [ "$#" -gt 0 ]; do
          case "$1" in
            --category|-c)
              CATEGORY_FILTER=$(normalize_category "''${2:-all}")
              shift 2
              ;;
            --query|-q)
              INITIAL_QUERY="''${2:-}"
              shift 2
              ;;
            --list|-l)
              LIST_ONLY=1
              shift
              ;;
            --help|-h)
              echo "Usage: menu [--category <cat>] [--query <text>] [--list] [--help]"
              echo ""
              echo "Interactive fuzzy command palette dynamically derived from nixconf flake outputs."
              echo ""
              echo "Options:"
              echo "  -c, --category <cat>  Start filtered by category (all, ide, system, devshell, package, secrets, test, docs, ci, graph, tack, check)"
              echo "  -q, --query <text>    Start fzf with an initial search query"
              echo "  -l, --list            Print the tab-separated catalog and exit"
              echo "  -h, --help            Show this help message"
              echo ""
              echo "Interactive Keybindings:"
              echo "  Enter                 Execute selected command"
              echo "  Tab / Shift-Tab       Cycle next / previous category filter"
              echo "  Ctrl-A                Reset category filter to ALL"
              echo "  Ctrl-E                Edit command interactively before executing"
              echo "  Ctrl-Y                Copy command to clipboard"
              echo "  Alt-Enter             Print command to stdout without executing"
              exit 0
              ;;
            *)
              INITIAL_QUERY="$1"
              shift
              ;;
          esac
        done

        if [ "$LIST_ONLY" -eq 1 ]; then
          generate_raw_catalog | awk -F'\t' -v filter="$CATEGORY_FILTER" '
            filter != "all" && $1 != filter { next }
            { printf "[%s]\t%s\t%s\t%s\t%s\n", $1, $2, $3, $4, $5 }
          '
          exit 0
        fi

        STATE_FILE=$(mktemp "''${TMPDIR:-/tmp}/nixconf-menu-state.XXXXXX")
        trap 'rm -f "$STATE_FILE"' EXIT
        printf '%s' "$CATEGORY_FILTER" >"$STATE_FILE"

        HEADER=$("$0" --internal-header "$STATE_FILE")

        # Run FZF command palette
        FZF_OUT=$(render_filtered_catalog "$CATEGORY_FILTER" | fzf \
          --ansi \
          --delimiter=$'\t' \
          --with-nth=2 \
          --nth=1,3,4,5,6 \
          --query="$INITIAL_QUERY" \
          --height=70% \
          --reverse \
          --border=rounded \
          --prompt="nixconf ❯ " \
          --header="$HEADER" \
          --expect=ctrl-e,alt-enter \
          --preview="\"$0\" --preview {1} {3} {4} {5} {6} {7}" \
          --preview-window=right:48%:wrap:border-left \
          --bind="tab:execute-silent(\"$0\" --internal-step next \"$STATE_FILE\")+reload(\"$0\" --internal-list \"$STATE_FILE\")+transform-header(\"$0\" --internal-header \"$STATE_FILE\")" \
          --bind="btab:execute-silent(\"$0\" --internal-step prev \"$STATE_FILE\")+reload(\"$0\" --internal-list \"$STATE_FILE\")+transform-header(\"$0\" --internal-header \"$STATE_FILE\")" \
          --bind="ctrl-a:execute-silent(\"$0\" --internal-step all \"$STATE_FILE\")+reload(\"$0\" --internal-list \"$STATE_FILE\")+transform-header(\"$0\" --internal-header \"$STATE_FILE\")" \
          --bind="ctrl-y:execute-silent(printf '%s' {4} | wl-copy 2>/dev/null || xclip -selection clipboard 2>/dev/null || true)+abort" \
          || true)

        if [ -z "$FZF_OUT" ]; then
          exit 0
        fi

        KEY=$(printf '%s\n' "$FZF_OUT" | sed -n '1p')
        SELECTED=$(printf '%s\n' "$FZF_OUT" | sed -n '2p')

        if [ -z "$SELECTED" ]; then
          exit 0
        fi

        CMD=$(printf '%s\n' "$SELECTED" | awk -F'\t' '{print $4}')

        if [ -z "$CMD" ]; then
          exit 0
        fi

        if [ "$KEY" = "alt-enter" ]; then
          printf '%s\n' "$CMD"
          exit 0
        fi

        if [ "$KEY" = "ctrl-e" ]; then
          echo ""
          read -e -r -p $'\033[1;33m➜ Edit command:\033[0m ' -i "$CMD" CMD || exit 0
          if [ -z "$CMD" ]; then
            exit 0
          fi
        fi

        echo ""
        echo -e "\033[1;32m➜ Executing:\033[0m \033[1;37m$CMD\033[0m"
        echo ""
        eval "$CMD"
      '';
    };
  };
}
