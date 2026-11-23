{
  inputs,
  self,
  ...
}: {
  internal.antigravity = {
    packages = {pkgs, ...}: let
      upstream = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system};
      wrapMeta = pkg: helpCommand:
        pkg
        // {
          meta =
            (pkg.meta or {})
            // {
              inherit helpCommand;
              homepage = "https://github.com/jacopone/antigravity-nix";
            };
        };
      agy = wrapMeta upstream.google-antigravity-cli "agy --help";
      agy-api =
        (pkgs.symlinkJoin {
          name = "agy-api-${agy.version or "0"}";
          paths = [agy];
          nativeBuildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram "$out/bin/agy" \
              --add-flags '--settings {"modelProvider":"gemini"}'
            ln -s "$out/bin/agy" "$out/bin/agy-api"
          '';
        })
        // {
          meta =
            (builtins.removeAttrs (agy.meta or {}) ["outputsToInstall"])
            // {
              mainProgram = "agy-api";
              helpCommand = "agy-api --help";
            };
        };
      agent-git-bootstrap =
        (pkgs.writeShellScriptBin "agent-git-bootstrap" ''
          set -euo pipefail
          export PATH="${pkgs.lib.makeBinPath [pkgs.gh pkgs.sops pkgs.jq pkgs.gnugrep pkgs.coreutils pkgs.openssh]}:$PATH"

          repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
          cd "$repo_root"

          if [[ -z "''${SOPS_AGE_KEY:-}" || -z "''${GH_TOKEN:-}" ]]; then
            echo "error: SOPS_AGE_KEY and GH_TOKEN must be set. Run via: just agent-git-bootstrap" >&2
            exit 1
          fi

          repo="LW-54/nixconf"
          title="astrolabe-agent-push"
          secret_file="secrets/hosts/astrolabe/agent-git.yaml"

          if [[ ! -f "$secret_file" ]]; then
            echo "error: missing $secret_file" >&2
            exit 1
          fi

          echo "==> [1/3] Reading SOPS-encrypted deploy public key from $secret_file..."
          pub_key="$(sops -d --extract '["publicKey"]' "$secret_file")"

          echo "==> [2/3] Ensuring write-scoped GitHub deploy key '$title' is registered on $repo..."
          if gh repo deploy-key list --repo "$repo" | grep -Fq "$title"; then
            echo "    Deploy key '$title' already registered on $repo."
          else
            printf '%s\n' "$pub_key" | gh repo deploy-key add - --repo "$repo" --allow-write --title "$title"
            echo "    Registered read-write deploy key '$title' on $repo."
          fi

          echo "==> [3/3] Ensuring main branch ruleset (block force-push & deletion) on $repo..."
          ruleset_name="protect-main-no-force-push"
          if existing_rulesets="$(gh api "repos/$repo/rulesets" 2>/dev/null)"; then
            if printf '%s' "$existing_rulesets" | jq -e --arg n "$ruleset_name" 'any(.[]; .name == $n)' >/dev/null; then
              echo "    Ruleset '$ruleset_name' already active on $repo."
            else
              if gh api --method POST "repos/$repo/rulesets" --input - >/dev/null <<'JSON'
          {
            "name": "protect-main-no-force-push",
            "target": "branch",
            "enforcement": "active",
            "conditions": {
              "ref_name": {
                "include": ["refs/heads/main"],
                "exclude": []
              }
            },
            "rules": [
              { "type": "deletion" },
              { "type": "non_fast_forward" }
            ]
          }
          JSON
              then
                echo "    Created ruleset '$ruleset_name' blocking force-push & deletion on main."
              else
                echo "    Warning: could not create ruleset via API (token may lack Administration:write). Deploy key is active." >&2
              fi
            fi
          else
            echo "    Warning: could not query rulesets API (token may lack Administration:read). Deploy key is active." >&2
          fi

          if [[ -r /run/secrets/agy-git-deploy-key ]]; then
            echo "==> Verifying SSH authentication with /run/secrets/agy-git-deploy-key..."
            ssh -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -i /run/secrets/agy-git-deploy-key -T git@github.com 2>&1 || true
          else
            echo ""
            echo "Deploy key registered! Run 'just switch astrolabe' to decrypt /run/secrets/agy-git-deploy-key and restart agy-remote-control."
          fi
        '')
        // {
          meta = {
            description = "Zero-GUI CLI bootstrapper registering astrolabe's SOPS-encrypted GitHub deploy key and main branch ruleset.";
            mainProgram = "agent-git-bootstrap";
            helpCommand = "agent-git-bootstrap --help";
          };
        };
    in {
      inherit agy agy-api agent-git-bootstrap;
      antigravity = wrapMeta upstream.default "antigravity --help";
      antigravity-ide = wrapMeta upstream.google-antigravity-ide "antigravity-ide --help";
    };

    devShells = {
      pkgs,
      self',
      ...
    }: {
      gemini-api = self.lib.bitwarden.mkShell {
        inherit pkgs;
        bw = self'.packages.bw;
        packages = [pkgs.age pkgs.sops self'.packages.agy-api];
        meta = {
          description = "Development shell exporting SOPS-encrypted GEMINI_API_KEY with API-key-wrapped agy-api.";
          usage = ''
            Development shell exporting `GEMINI_API_KEY` / `GOOGLE_API_KEY` from SOPS (`secrets/admin/gemini.yaml`) and providing `agy-api` (configured with `modelProvider = "gemini"`).

            Unlocks the master SOPS age key via Bitwarden (item `c2352759-f5e3-40af-a797-89bd86e230d2`) if `SOPS_AGE_KEY` is not already set.
          '';
        };
        shellHook = ''
          if [[ -z "''${GEMINI_API_KEY:-}" ]]; then
            repo_root="''${DEVENV_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
            sops_file="$repo_root/secrets/admin/gemini.yaml"
            if [[ ! -f "$sops_file" && -f "${../../../secrets/admin/gemini.yaml}" ]]; then
              sops_file="${../../../secrets/admin/gemini.yaml}"
            fi
            if [[ ! -f "$sops_file" ]]; then
              printf 'Missing Gemini SOPS file: %s\n' "$sops_file" >&2
              exit 1
            fi
            if [[ -z "''${SOPS_AGE_KEY:-}" ]]; then
              ${self.lib.bitwarden.mkValue {
            itemId = "c2352759-f5e3-40af-a797-89bd86e230d2";
            variable = "SOPS_AGE_KEY";
            jqFilter = ".notes | select(type == \"string\" and length > 0)";
          }}
            fi
            GEMINI_API_KEY="$(SOPS_AGE_KEY="$SOPS_AGE_KEY" sops -d --extract '["api_key"]' "$sops_file")" || exit 1
            export GEMINI_API_KEY GOOGLE_API_KEY="$GEMINI_API_KEY"
          fi
        '';
      };
    };
  };
}
