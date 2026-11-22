{self, ...}: {
  feature.uchiyomi = {
    description = "Self-hosted manga, manhwa, and webtoon server, reader, and downloader stack.";
    modules = {
      uchiyomi = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.uchiyomi-server;

        networkName = "uchiyomi_app";
        flaresolverrHost = "uchiyomi-flaresolverr";
        suwayomiHost = "uchiyomi-suwayomi";
        containers = ["uchiyomi" flaresolverrHost suwayomiHost];

        backend = config.virtualisation.oci-containers.backend;
        backendPkg =
          if backend == "docker"
          then config.virtualisation.docker.package
          else config.virtualisation.podman.package;

        domain = config.reverse-proxy.domain or null;
        cgroupParentOpts = lib.optionals ((config.resources.enable or false) && cfg.resources.enable) [
          "--cgroup-parent=${self.lib.resources.sliceName cfg.resources.tier}"
        ];
      in {
        options.services.uchiyomi-server =
          {
            enable = lib.mkEnableOption "Uchiyomi manga server stack" // {default = true;};

            image = lib.mkOption {
              type = lib.types.str;
              default = "ghcr.io/angelosha/uchiyomi:latest";
              description = "OCI image for Uchiyomi server application.";
            };

            suwayomiImage = lib.mkOption {
              type = lib.types.str;
              default = "ghcr.io/suwayomi/suwayomi-server:v2.4.2366";
              description = "OCI image for Suwayomi-Server extension engine.";
            };

            flaresolverrImage = lib.mkOption {
              type = lib.types.str;
              default = "ghcr.io/flaresolverr/flaresolverr:latest";
              description = "OCI image for FlareSolverr Cloudflare solver.";
            };

            dataDir = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/uchiyomi";
              description = "Base host state directory for Uchiyomi database, config, and Suwayomi data.";
            };

            libraryPath = lib.mkOption {
              type = lib.types.str;
              default =
                if cfg.storage.enable && cfg.storage.mountPoint != null
                then "${cfg.storage.mountPoint}/library"
                else "${cfg.dataDir}/library";
              description = "Host directory containing existing comics and manga collections.";
            };

            downloadsPath = lib.mkOption {
              type = lib.types.str;
              default =
                if cfg.storage.enable && cfg.storage.mountPoint != null
                then "${cfg.storage.mountPoint}/downloads"
                else "${cfg.dataDir}/downloads";
              description = "Host directory where Uchiyomi saves downloaded chapters (must not be inside libraryPath).";
            };

            cacheDir = lib.mkOption {
              type = lib.types.str;
              default = "/var/cache/uchiyomi";
              description = "Host directory for Uchiyomi transient image cache.";
            };

            environment = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = {};
              description = "Additional environment variables injected into the Uchiyomi container.";
            };
          }
          // self.lib.reverse-proxy.mkOption {
            subdomain = "uchiyomi";
          }
          // self.lib.persistence.mkOption {
            directories = [
              "/var/lib/uchiyomi"
              "/var/cache/uchiyomi"
            ];
          }
          // self.lib.backup.mkOption {
            paths = [
              "/var/lib/uchiyomi/data"
              "/var/lib/uchiyomi/config"
              "/var/lib/uchiyomi/suwayomi"
            ];
            beforeUnits = [
              "${backend}-uchiyomi.service"
              "${backend}-${suwayomiHost}.service"
            ];
          }
          // self.lib.storage.mkOption {
            enable = true;
            slice = "uchiyomi";
            mountPoint = "/mnt/storage/uchiyomi";
            vfsCacheMode = "writes";
            uid = 10002;
            gid = 10002;
            umask = "002";
          }
          // self.lib.monitoring.mkOption {
            units = map (c: "${backend}-${c}.service") containers;
          }
          // self.lib.resources.mkOption {
            tier = "standard";
          };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            assertions = [
              {
                assertion = cfg.libraryPath != cfg.downloadsPath;
                message = "services.uchiyomi-server: libraryPath and downloadsPath must be different directories to prevent recursive scanning loops.";
              }
            ];

            testing.vm.allowedFailedUnits =
              [
                "${backend}-*.service"
              ]
              ++ lib.optional cfg.storage.enable "uchiyomi-storage-prep.service";

            virtualisation.oci-containers.containers = {
              ${flaresolverrHost} = {
                image = cfg.flaresolverrImage;
                networks = [networkName];
                environment = {
                  LOG_LEVEL = "warning";
                };
                extraOptions =
                  [
                    "--shm-size=1g"
                    "--memory=2g"
                  ]
                  ++ cgroupParentOpts;
              };

              ${suwayomiHost} = {
                image = cfg.suwayomiImage;
                networks = [networkName];
                dependsOn = [flaresolverrHost];
                environment = {
                  TZ = config.time.timeZone or "UTC";
                  JAVA_TOOL_OPTIONS = "-Xmx1536m -XX:+UseG1GC";
                  MALLOC_ARENA_MAX = "2";
                  AUTO_DOWNLOAD_CHAPTERS = "false";
                  DOWNLOAD_AS_CBZ = "true";
                  FLARESOLVERR_ENABLED = "true";
                  FLARESOLVERR_URL = "http://${flaresolverrHost}:8191";
                };
                volumes = [
                  "${cfg.dataDir}/suwayomi:/home/suwayomi/.local/share/Tachidesk"
                ];
                extraOptions =
                  [
                    "--memory=3g"
                  ]
                  ++ cgroupParentOpts;
              };

              uchiyomi = {
                inherit (cfg) image;
                ports = [
                  "${cfg.address}:${toString cfg.port}:3000"
                ];
                networks = [networkName];
                dependsOn = [
                  flaresolverrHost
                  suwayomiHost
                ];
                environment =
                  {
                    PORT = "3000";
                    LIBRARY_BACKEND = "owned";
                    PUBLIC_ORIGIN =
                      if cfg.subdomain != null && domain != null
                      then "https://${cfg.subdomain}.${domain}"
                      else "http://${cfg.address}:${toString cfg.port}";
                    FLARESOLVERR_URL = "http://${flaresolverrHost}:8191";
                    SUWAYOMI_URL = "http://${suwayomiHost}:4567";
                    SUWAYOMI_MAX_SOURCES = "100";
                    EXTENSION_ENGINE = "1";
                    SOURCES_DIR = "/sources";
                    CUSTOM_SITES_FILE = "/config/sites.json";
                  }
                  // cfg.environment;
                volumes = [
                  "${cfg.dataDir}/data:/data"
                  "${cfg.dataDir}/config:/config"
                  "${cfg.downloadsPath}:/library-dl"
                  "${cfg.libraryPath}:/library"
                  "${cfg.cacheDir}:/cache"
                ];
                extraOptions =
                  [
                    "--stop-timeout=40"
                  ]
                  ++ cgroupParentOpts;
              };
            };

            systemd.tmpfiles.rules =
              [
                "d ${cfg.dataDir} 0755 root root -"
                "d ${cfg.dataDir}/data 0775 10002 10002 -"
                "d ${cfg.dataDir}/config 0775 10002 10002 -"
                "d ${cfg.dataDir}/suwayomi 0775 1000 1000 -"
                "d ${cfg.cacheDir} 0775 10002 10002 -"
              ]
              ++ lib.optional cfg.storage.enable "d ${cfg.storage.mountPoint} 0755 root root -"
              ++ lib.optionals (!cfg.storage.enable) [
                "d ${cfg.libraryPath} 0775 10002 10002 -"
                "d ${cfg.downloadsPath} 0775 10002 10002 -"
              ];

            systemd.services =
              {
                "oci-network-${networkName}" = {
                  description = "OCI Network ${networkName}";
                  after = ["network.target"];
                  wantedBy = ["multi-user.target"];
                  serviceConfig = {
                    Type = "oneshot";
                    RemainAfterExit = true;
                  };
                  script = ''
                    ${backendPkg}/bin/${backend} network inspect ${networkName} >/dev/null 2>&1 || \
                      ${backendPkg}/bin/${backend} network create ${networkName}
                  '';
                };
              }
              // lib.optionalAttrs cfg.storage.enable {
                uchiyomi-storage-prep = {
                  description = "Ensure Uchiyomi remote storage directories exist";
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
                    lib_path=${lib.escapeShellArg cfg.libraryPath}
                    dl_path=${lib.escapeShellArg cfg.downloadsPath}

                    rclone --config /run/rclone/rclone.conf mkdir "$slice:library"
                    rclone --config /run/rclone/rclone.conf mkdir "$slice:downloads"

                    install -d -m 0775 "$lib_path" "$dl_path"
                  '';
                };
              }
              // lib.genAttrs (map (c: "${backend}-${c}") containers) (c:
                {
                  after =
                    ["oci-network-${networkName}.service"]
                    ++ lib.optional (c == "${backend}-uchiyomi" && cfg.storage.enable) "uchiyomi-storage-prep.service";
                  requires =
                    ["oci-network-${networkName}.service"]
                    ++ lib.optional (c == "${backend}-uchiyomi" && cfg.storage.enable) "uchiyomi-storage-prep.service";
                }
                // lib.optionalAttrs (c == "${backend}-uchiyomi" && cfg.storage.enable) {
                  unitConfig.RequiresMountsFor = [cfg.storage.mountPoint];
                });
          }
          (lib.mkIf ((config.persistence.enable or false) && backend == "podman") {
            persistence.directories = ["/var/lib/containers"];
          })
          (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
          (self.lib.persistence.mkConfig {inherit config cfg;})
          (self.lib.backup.mkConfig {inherit config cfg;})
          (self.lib.storage.mkConfig {inherit config cfg;})
          (self.lib.monitoring.mkConfig {
            inherit config cfg;
            name = "uchiyomi";
          })
          (self.lib.resources.mkConfig {inherit config cfg;})
          (lib.mkIf (config.monitoring.enable or false) {
            monitoring.exporters.cadvisor.enable = true;
          })
        ]);
      };
    };
  };
}
