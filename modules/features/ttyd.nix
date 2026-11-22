{self, ...}: {
  feature.ttyd = {
    description = "Web terminal server bridging browser sessions to persistent tmux-backed system shells via ttyd.";
    modules = {
      ttyd = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.ttyd-web;
        tmuxConf = pkgs.writeText "ttyd-tmux.conf" ''
          set -g mouse on
          set -g history-limit 20000
          set -g window-size latest
          setw -g aggressive-resize on
          set -g default-terminal "xterm-256color"
          set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
          set -g status-right "#H | %H:%M"
        '';
        sessionScript = pkgs.writeShellScript "ttyd-session" ''
          set -euo pipefail
          base=${lib.escapeShellArg cfg.persistentSession.sessionName}
          tmux_bin="${pkgs.tmux}/bin/tmux"

          if ! "$tmux_bin" has-session -t "$base" 2>/dev/null; then
            exec "$tmux_bin" -f ${tmuxConf} new-session -s "$base" "${pkgs.bashInteractive}/bin/bash -l"
          fi

          # If another browser/device is already attached, create an ephemeral grouped session
          # sharing all windows/processes while letting each client view independently at its own size.
          attached="$("$tmux_bin" list-clients -t "$base" 2>/dev/null | wc -l | tr -d ' ')"
          if [ "''${attached:-0}" -gt 0 ]; then
            exec "$tmux_bin" -f ${tmuxConf} new-session -t "$base" \; set-option destroy-unattached on
          else
            exec "$tmux_bin" -f ${tmuxConf} attach-session -t "$base"
          fi
        '';
        shellCmd =
          if cfg.persistentSession.enable
          then "${sessionScript}"
          else "${pkgs.bashInteractive}/bin/bash -l";
      in {
        options.services.ttyd-web =
          {
            enable = lib.mkEnableOption "ttyd web terminal server" // {default = true;};

            persistentSession = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Back ttyd browser sessions with a persistent tmux session (with grouped sessions for simultaneous multi-device use).";
              };

              sessionName = lib.mkOption {
                type = lib.types.str;
                default = "ttyd";
                description = "Base tmux session name shared across reconnections and grouped sessions.";
              };
            };
          }
          // self.lib.reverse-proxy.mkOption {
            subdomain = "ttyd";
          }
          // {
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
              description = "System user to run ttyd and session as.";
            };
          }
          // self.lib.monitoring.mkOption {
            units = ["ttyd-web.service"];
          }
          // self.lib.resources.mkOption {
            tier = "standard";
            memory = {
              high = "20%";
              max = "35%";
            };
          };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            environment.systemPackages = [pkgs.ttyd] ++ lib.optional cfg.persistentSession.enable pkgs.tmux;

            systemd.services.ttyd-web = {
              description = "ttyd Web Terminal";
              wantedBy = ["multi-user.target"];
              after = ["network.target"];
              serviceConfig = {
                User = cfg.user;
                WorkingDirectory = "/home/${cfg.user}";
                Environment = [
                  "HOME=/home/${cfg.user}"
                  "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin"
                ];
                ExecStart = "${pkgs.ttyd}/bin/ttyd -i ${cfg.address} -p ${toString cfg.port} -W ${shellCmd}";
                Restart = "always";
              };
            };
          }
          (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
          (self.lib.monitoring.mkConfig {
            inherit config cfg;
            name = "ttyd";
          })
          (self.lib.resources.mkConfig {inherit config cfg;})
        ]);
      };
    };
  };
}
