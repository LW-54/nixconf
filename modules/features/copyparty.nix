{self, ...}: {
  feature.copyparty = {
    description = "Self-hosted multi-protocol file server, resumable upload hub, and cloud storage browser via Copyparty.";
    modules = {
      copyparty = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.copyparty-server;
        hostName = config.networking.hostName;
        domain = config.reverse-proxy.domain or null;
        publicSite =
          if cfg.subdomain != null && domain != null
          then "https://${cfg.subdomain}.${domain}/"
          else null;

        confTemplateContent = ''
          [global]
          i: ${cfg.address}
          p: ${toString cfg.port}
          rproxy: -1
          xff-src: 127.0.0.0/8, ::1/128
          hist: ${cfg.dataDir}/hist
          shr: /share
          shr-db: ${cfg.dataDir}/shares.db
          ${lib.optionalString (publicSite != null) "shr-site: ${publicSite}"}
          e2dsa
          e2ts

          [accounts]
          ${config.secrets.placeholder.copyparty-users}

          [/]
          ${cfg.filesPath}
          accs:
            A: ${cfg.adminAccount}
          flags:
            d2ds
            d2t
            nosparse
          ${lib.optionalString cfg.exposeDrop ''

            [/drop]
            ${cfg.dropPath}
            accs:
              w: *
              A: ${cfg.adminAccount}
            flags:
              d2ds
              d2t
              nosparse
          ''}${lib.optionalString cfg.enableGdrive ''

            [/gdrive]
            ${cfg.gdriveMountPoint}
            accs:
              A: ${cfg.adminAccount}
            flags:
              d2ds
              d2t
              nosparse
          ''}${lib.optionalString cfg.exposeHostRoot ''

            [/${hostName}]
            /
            accs:
              A: ${cfg.adminAccount}
            flags:
              d2d
              dthumb
          ''}
        '';
      in {
        options.services.copyparty-server =
          {
            enable = lib.mkEnableOption "Copyparty file server" // {default = true;};

            dataDir = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/copyparty";
              description = "Base local state directory for Copyparty SQLite history/thumbnail indexes, share database, and fallback local directories.";
            };

            cacheDir = lib.mkOption {
              type = lib.types.str;
              default = "/var/cache/copyparty";
              description = "Local directory for Copyparty transient runtime cache.";
            };

            filesPath = lib.mkOption {
              type = lib.types.str;
              default =
                if cfg.storage.enable && cfg.storage.mountPoint != null
                then "${cfg.storage.mountPoint}/files"
                else "${cfg.dataDir}/files";
              description = "Host directory backing the root `/` Copyparty volume.";
            };

            dropPath = lib.mkOption {
              type = lib.types.str;
              default =
                if cfg.storage.enable && cfg.storage.mountPoint != null
                then "${cfg.storage.mountPoint}/drop"
                else "${cfg.dataDir}/drop";
              description = "Host directory backing the public write-only `/drop` dead-drop volume.";
            };

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
              description = "System user account under which Copyparty runs.";
            };

            group = lib.mkOption {
              type = lib.types.str;
              default = "users";
              description = "Primary system group under which Copyparty runs.";
            };

            adminAccount = lib.mkOption {
              type = lib.types.str;
              default = "admin";
              description = "Copyparty account name granted full admin (`A`) permissions on all volumes.";
            };

            exposeDrop = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to expose a public write-only `/drop` inbox volume (`w: *`, `A: <adminAccount>`).";
            };

            enableGdrive = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to mount the `gdrive` storage slice and expose it as `/gdrive` in Copyparty.";
            };

            gdriveMountPoint = lib.mkOption {
              type = lib.types.str;
              default = "/mnt/storage/gdrive";
              description = "Host mount point for the Google Drive (`gdrive`) storage slice.";
            };

            exposeHostRoot = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to expose the host root filesystem `/` at `/<hostName>` with on-demand browsing (`d2d`, `dthumb`).";
            };
          }
          // self.lib.reverse-proxy.mkOption {
            subdomain = "copyparty";
            port = 3923;
          }
          // self.lib.persistence.mkOption {
            directories = [
              "/var/lib/copyparty"
              "/var/cache/copyparty"
            ];
          }
          // self.lib.backup.mkOption {
            paths = [
              "/var/lib/copyparty"
            ];
            beforeUnits = [
              "copyparty.service"
            ];
          }
          // self.lib.storage.mkOption {
            enable = true;
            slice = "copyparty";
            mountPoint = "/mnt/storage/copyparty";
            vfsCacheMode = "writes";
            uid = 1000;
            gid = 100;
            umask = "002";
          };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            environment.systemPackages = [pkgs.copyparty];

            secrets = {
              files.copyparty-users = {
                store = "services/copyparty";
                key = "users";
                testValue = "${cfg.adminAccount}: testpassword";
              };

              templates."copyparty.conf" = {
                owner = cfg.user;
                group = cfg.group;
                mode = "0400";
                content = confTemplateContent;
              };
            };

            storage = lib.mkIf cfg.enableGdrive {
              enable = lib.mkDefault true;
              mounts.gdrive = {
                enable = true;
                slice = "gdrive";
                mountPoint = cfg.gdriveMountPoint;
                vfsCacheMode = "writes";
                uid = 1000;
                gid = 100;
                umask = "002";
              };
            };

            systemd.tmpfiles.rules =
              [
                "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
                "d ${cfg.dataDir}/hist 0750 ${cfg.user} ${cfg.group} -"
                "d ${cfg.cacheDir} 0750 ${cfg.user} ${cfg.group} -"
                "d ${cfg.filesPath} 0775 ${cfg.user} ${cfg.group} -"
              ]
              ++ lib.optional cfg.exposeDrop "d ${cfg.dropPath} 0775 ${cfg.user} ${cfg.group} -"
              ++ lib.optional cfg.storage.enable "d ${cfg.storage.mountPoint} 0755 ${cfg.user} ${cfg.group} -"
              ++ lib.optional cfg.enableGdrive "d ${cfg.gdriveMountPoint} 0755 ${cfg.user} ${cfg.group} -";

            systemd.services =
              {
                copyparty = {
                  description = "Copyparty File Server";
                  wantedBy = ["multi-user.target"];
                  after =
                    ["network.target" "sops-install-secrets.service"]
                    ++ lib.optionals cfg.storage.enable ["rclone-config.service" "copyparty-storage-prep.service"];
                  wants =
                    ["sops-install-secrets.service"]
                    ++ lib.optionals cfg.storage.enable ["rclone-config.service" "copyparty-storage-prep.service"];
                  restartTriggers = [
                    config.secrets.templates."copyparty.conf".content
                  ];
                  serviceConfig = {
                    User = cfg.user;
                    Group = cfg.group;
                    WorkingDirectory = cfg.dataDir;
                    Environment = [
                      "HOME=${cfg.dataDir}"
                      "XDG_CONFIG_HOME=${cfg.dataDir}/config"
                      "XDG_CACHE_HOME=${cfg.cacheDir}"
                    ];
                    AmbientCapabilities = ["CAP_DAC_OVERRIDE"];
                    CapabilityBoundingSet = ["CAP_DAC_OVERRIDE"];
                    ExecStart = "${pkgs.copyparty}/bin/copyparty -c ${config.secrets.templates."copyparty.conf".path}";
                    Restart = "on-failure";
                    RestartSec = "5s";
                  };
                };
              }
              // lib.optionalAttrs cfg.storage.enable {
                copyparty-storage-prep = {
                  description = "Ensure Copyparty remote storage directories exist";
                  after = ["rclone-config.service" "network-online.target"];
                  wants = ["network-online.target"];
                  requires = ["rclone-config.service"];
                  wantedBy = ["multi-user.target"];
                  path = [pkgs.coreutils pkgs.rclone];
                  serviceConfig = {
                    Type = "oneshot";
                    RemainAfterExit = true;
                  };
                  script = ''
                    slice=${lib.escapeShellArg cfg.storage.slice}
                    files_path=${lib.escapeShellArg cfg.filesPath}
                    drop_path=${lib.escapeShellArg cfg.dropPath}

                    timeout --kill-after=5s 20s rclone --config /run/rclone/rclone.conf \
                      --contimeout=5s --timeout=15s --retries=1 --low-level-retries=1 \
                      mkdir "$slice:files"
                    ${lib.optionalString cfg.exposeDrop ''
                      timeout --kill-after=5s 20s rclone --config /run/rclone/rclone.conf \
                        --contimeout=5s --timeout=15s --retries=1 --low-level-retries=1 \
                        mkdir "$slice:drop"
                    ''}

                    install -d -m 0775 "$files_path" ${lib.optionalString cfg.exposeDrop ''"$drop_path"''}
                  '';
                };
              };

            testing = {
              vm.allowedFailedUnits = lib.optional cfg.storage.enable "copyparty-storage-prep.service";
              copyparty = {
                description = "Copyparty multi-volume file server and HTTP endpoint verification";
                inspectChecks.unit = {
                  description = "Verify copyparty.service unit exists in system closure";
                  script = self.lib.testing.mkInspectFile {
                    path = "$etc/systemd/system/copyparty.service";
                    pattern = "copyparty.conf";
                  };
                };
                vmChecks.running = {
                  description = "copyparty.service is active and serves HTTP 200 on its configured port";
                  script = ''
                    ${self.lib.testing.mkServiceCheck {unit = "copyparty.service";}}
                    ${self.lib.testing.mkHttpCheck {
                      inherit (cfg) port;
                      host = cfg.address;
                    }}
                  '';
                };
              };
            };
          }
          (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
          (self.lib.persistence.mkConfig {inherit config cfg;})
          (self.lib.backup.mkConfig {inherit config cfg;})
          (self.lib.storage.mkConfig {inherit config cfg;})
        ]);
      };
    };
  };
}
