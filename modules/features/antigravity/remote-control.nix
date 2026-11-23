{
  config,
  self,
  ...
}: let
  configModule = config.internal.antigravity.configModule;
in {
  internal.antigravity.remoteControlModule = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.agy-remote-control;
    tokenPath = "/home/${cfg.user}/.gemini/antigravity-cli/antigravity-oauth-token";
    textfileDir = config.monitoring.exporters.unix.textfileDirectory or "/var/lib/alloy/textfile";

    metricsScript = pkgs.writeShellScript "agy-export-metrics" ''
      set -euo pipefail
      dir=${lib.escapeShellArg textfileDir}
      [ -d "$dir" ] || exit 0

      home_dir="/home/${cfg.user}"
      gemini_dir="$home_dir/.gemini"
      cli_dir="$gemini_dir/antigravity-cli"
      tok="$cli_dir/antigravity-oauth-token"
      now="$(${pkgs.coreutils}/bin/date +%s)"

      daemon_active=0
      if ${pkgs.systemd}/bin/systemctl is-active --quiet agy-remote-control.service; then
        daemon_active=1
      fi

      oauth_auth=0
      oauth_expiry=0
      email=""
      if [ -s "$tok" ]; then
        oauth_auth=1
        email="$(${pkgs.jq}/bin/jq -r '.id_token_email // empty' "$tok" 2>/dev/null || true)"
        expiry_raw="$(${pkgs.jq}/bin/jq -r '.token.expiry // empty' "$tok" 2>/dev/null || true)"
        if [ -n "$expiry_raw" ]; then
          oauth_expiry="$(${pkgs.coreutils}/bin/date -d "$expiry_raw" +%s 2>/dev/null || echo 0)"
        fi
      fi

      convs=0
      if [ -d "$cli_dir/conversations" ]; then
        convs="$(${pkgs.findutils}/bin/find "$cli_dir/conversations" -maxdepth 1 -mindepth 1 2>/dev/null | ${pkgs.coreutils}/bin/wc -l | ${pkgs.coreutils}/bin/tr -d ' ')"
      fi

      bytes=0
      if [ -d "$gemini_dir" ]; then
        bytes="$(${pkgs.coreutils}/bin/du -sb "$gemini_dir" 2>/dev/null | ${pkgs.gawk}/bin/awk '{print $1}' || echo 0)"
      fi

      esc_email="$(printf '%s' "$email" | ${pkgs.gnused}/bin/sed 's/\\/\\\\/g; s/"/\\"/g')"
      esc_inst="$(printf '%s' ${lib.escapeShellArg cfg.instanceName} | ${pkgs.gnused}/bin/sed 's/\\/\\\\/g; s/"/\\"/g')"

      tmp="$dir/agy.prom.tmp.$$"
      cat > "$tmp" <<EOF
      # HELP agy_daemon_active Whether agy-remote-control.service is active (1=active, 0=inactive)
      # TYPE agy_daemon_active gauge
      agy_daemon_active $daemon_active
      # HELP agy_oauth_authenticated Whether an Antigravity OAuth token is present (1=yes, 0=no)
      # TYPE agy_oauth_authenticated gauge
      agy_oauth_authenticated $oauth_auth
      # HELP agy_oauth_expiry_seconds Unix timestamp of current OAuth access token expiry (0 if unavailable)
      # TYPE agy_oauth_expiry_seconds gauge
      agy_oauth_expiry_seconds $oauth_expiry
      # HELP agy_conversations_total Number of stored Antigravity conversations
      # TYPE agy_conversations_total gauge
      agy_conversations_total $convs
      # HELP agy_storage_bytes Disk usage of ~/.gemini in bytes
      # TYPE agy_storage_bytes gauge
      agy_storage_bytes $bytes
      # HELP agy_metrics_updated_seconds Unix timestamp when agy metrics were last collected
      # TYPE agy_metrics_updated_seconds gauge
      agy_metrics_updated_seconds $now
      # HELP agy_info Static labels describing this Antigravity host instance
      # TYPE agy_info gauge
      agy_info{instance_name="$esc_inst",email="$esc_email"} 1
      EOF
      ${pkgs.coreutils}/bin/chmod 0644 "$tmp"
      ${pkgs.coreutils}/bin/mv -f "$tmp" "$dir/agy.prom"
    '';
  in {
    key = "nixconf:agy-remote-control";
    imports = [configModule];

    options.services.agy-remote-control =
      {
        enable = lib.mkEnableOption "automatic agy remote-control background daemon" // {default = true;};

        user = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          apply = user:
            if user == null
            then let
              normalNames = self.lib.user.normalUserNames config;
            in
              if normalNames != []
              then builtins.head normalNames
              else "root"
            else user;
          description = "System user to run the `agy remote-control` daemon as.";
        };

        instanceName = lib.mkOption {
          type = lib.types.str;
          default = config.networking.hostName;
          description = "Machine instance name displayed in the Antigravity Remote Control web dashboard.";
        };

        gitPush = {
          enable = lib.mkEnableOption "scoped SOPS-backed GitHub deploy key for autonomous agent git push";

          secretStore = lib.mkOption {
            type = lib.types.str;
            default = "hosts/${config.networking.hostName}/agent-git";
            description = "SOPS secret store (relative to `secrets/`) containing `privateKey` and `publicKey` for the repo-scoped GitHub deploy key.";
          };
        };
      }
      // self.lib.monitoring.mkOption {
        units = ["agy-remote-control.service"];
      }
      // self.lib.resources.mkOption {
        tier = "background";
        memory = {
          high = "45%";
          max = "65%";
        };
      };

    config = lib.mkIf cfg.enable (lib.mkMerge [
      {
        home.shared.files.".gemini/antigravity-cli/remote-control-name".text = "${cfg.instanceName}\n";

        systemd.services.agy-remote-control = {
          description = "Antigravity CLI remote-control daemon (${cfg.instanceName})";
          wantedBy = ["multi-user.target"];
          after =
            ["network-online.target"]
            ++ lib.optional cfg.gitPush.enable "sops-install-secrets.service";
          wants = ["network-online.target"];
          unitConfig.ConditionPathExists = tokenPath;
          environment =
            {
              HOME = "/home/${cfg.user}";
              PATH = lib.mkForce "/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin";
            }
            // lib.optionalAttrs cfg.gitPush.enable {
              GIT_SSH_COMMAND = "ssh -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -i ${config.secrets.files.agy-git-deploy-key.path}";
            };
          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            WorkingDirectory = "/home/${cfg.user}";
            ExecStart = "${self.packages.${pkgs.stdenv.hostPlatform.system}.agy}/bin/agy remote-control serve";
            Restart = "on-failure";
            RestartSec = "10s";
            TimeoutStopSec = "30s";
            StandardOutput = "journal";
            StandardError = "journal";
          };
        };

        systemd.paths.agy-remote-control = {
          description = "Watch for Antigravity OAuth token to start remote-control daemon";
          wantedBy = ["multi-user.target"];
          pathConfig = {
            PathExists = tokenPath;
            Unit = "agy-remote-control.service";
          };
        };
      }
      (lib.mkIf cfg.gitPush.enable {
        secrets.files.agy-git-deploy-key = {
          store = cfg.gitPush.secretStore;
          key = "privateKey";
          owner = cfg.user;
          group = "users";
          mode = "0400";
          testValue = "nixconf-test-agy-git-deploy-key";
        };

        agy.config.rules.gitPush = ''
          ## Autonomous Git Push
          - A repo-scoped GitHub deploy key is pre-configured via `GIT_SSH_COMMAND` in this environment, so plain `git push` works directly without Bitwarden.
          - Only push after local checks and `.githooks/pre-commit` succeed.
          - NEVER force-push (`--force`, `--force-with-lease`) or delete remote branches.
        '';
      })
      (lib.mkIf (config.monitoring.enable or false) {
        monitoring.exporters.unix.textfileDirectory = lib.mkDefault "/var/lib/alloy/textfile";

        systemd.services.agy-metrics = {
          description = "Export Antigravity daemon, OAuth, and usage metrics for Alloy";
          after = ["systemd-tmpfiles-setup.service"];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = metricsScript;
          };
        };

        systemd.timers.agy-metrics = {
          description = "Periodically export Antigravity metrics for Alloy";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnBootSec = "15s";
            OnUnitActiveSec = "30s";
            AccuracySec = "5s";
          };
        };
      })
      (self.lib.monitoring.mkConfig {
        inherit config cfg;
        name = "agy-remote-control";
      })
      (self.lib.resources.mkConfig {inherit config cfg;})
    ]);
  };
}
