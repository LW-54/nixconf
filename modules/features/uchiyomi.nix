{self, ...}: {
  feature.uchiyomi = {
    description = "Self-hosted manga, manhwa, and webtoon server, reader, and downloader stack.";
    modules = {
      uchiyomi = {
        config,
        lib,
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
              description = "Base host state directory for Uchiyomi database, config, backups, and Suwayomi data.";
            };

            libraryPath = lib.mkOption {
              type = lib.types.str;
              default = "${cfg.dataDir}/library";
              description = "Host directory containing existing comics and manga collections.";
            };

            downloadsPath = lib.mkOption {
              type = lib.types.str;
              default = "${cfg.dataDir}/downloads";
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
            port = 8080;
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
          };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            assertions = [
              {
                assertion = cfg.libraryPath != cfg.downloadsPath;
                message = "services.uchiyomi-server: libraryPath and downloadsPath must be different directories to prevent recursive scanning loops.";
              }
            ];

            virtualisation.oci-containers.containers = {
              ${flaresolverrHost} = {
                image = cfg.flaresolverrImage;
                networks = [networkName];
                environment = {
                  LOG_LEVEL = "warning";
                };
                extraOptions = [
                  "--shm-size=1g"
                  "--memory=2g"
                ];
              };

              ${suwayomiHost} = {
                image = cfg.suwayomiImage;
                networks = [networkName];
                dependsOn = [flaresolverrHost];
                environment = {
                  TZ = config.time.timeZone or "UTC";
                  JAVA_TOOL_OPTIONS = "-Xmx768m -XX:+UseSerialGC";
                  MALLOC_ARENA_MAX = "2";
                  AUTO_DOWNLOAD_CHAPTERS = "false";
                  DOWNLOAD_AS_CBZ = "true";
                  FLARESOLVERR_ENABLED = "true";
                  FLARESOLVERR_URL = "http://${flaresolverrHost}:8191";
                };
                volumes = [
                  "${cfg.dataDir}/suwayomi:/home/suwayomi/.local/share/Tachidesk"
                ];
                extraOptions = [
                  "--memory=2048m"
                ];
              };

              uchiyomi = {
                image = cfg.image;
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
                  "${cfg.dataDir}/backups:/backups"
                ];
                extraOptions = [
                  "--stop-timeout=40"
                ];
              };
            };

            systemd.tmpfiles.rules = [
              "d ${cfg.dataDir} 0755 root root -"
              "d ${cfg.dataDir}/data 0775 10002 10002 -"
              "d ${cfg.dataDir}/config 0775 10002 10002 -"
              "d ${cfg.dataDir}/suwayomi 0775 1000 1000 -"
              "d ${cfg.dataDir}/backups 0775 10002 10002 -"
              "d ${cfg.libraryPath} 0775 10002 10002 -"
              "d ${cfg.downloadsPath} 0775 10002 10002 -"
              "d ${cfg.cacheDir} 0775 10002 10002 -"
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
              // lib.genAttrs (map (c: "${backend}-${c}") containers) (_: {
                after = ["oci-network-${networkName}.service"];
                requires = ["oci-network-${networkName}.service"];
              });
          }
          (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
          (self.lib.persistence.mkConfig {
            inherit config;
            cfg = cfg.persistence;
          })
          (self.lib.backup.mkConfig {
            inherit config;
            cfg = cfg.backup;
          })
        ]);
      };
    };
  };
}
