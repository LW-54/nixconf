{self, ...}: {
  feature.ssh = {
    description = "OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell.";
    modules = {
      ssh = {
        config,
        lib,
        pkgs,
        inputs,
        ...
      }: let
        cfg = config.services.ssh;
        hostKeySecretPath = ../../secrets/hosts/${config.networking.hostName}/ssh.yaml;
        hasHostKeySecret = builtins.pathExists hostKeySecretPath;
        publicKeysFile = ../../secrets/ssh/public.yaml;
        publicKeys =
          if builtins.pathExists publicKeysFile
          then let
            lines = lib.splitString "\n" (builtins.readFile publicKeysFile);
            getKey = line: let
              m = builtins.match "^([a-zA-Z0-9_.-]+):.*" line;
            in
              if m != null && builtins.head m != "sops"
              then builtins.head m
              else null;
          in
            lib.unique (builtins.filter (x: x != null) (map getKey lines))
          else ["master"];

        snakeoil = import "${inputs.nixpkgs}/nixos/tests/ssh-keys.nix" {
          inherit lib;
          writeText = _: text: text;
        };
        port = toString cfg.listenPort;
      in {
        options.services.ssh = {
          enable = lib.mkEnableOption "standard SSH configuration" // {default = true;};

          prebuildMasterSsh = lib.mkEnableOption "prebuilding the master SSH development shell" // {default = true;};

          listenPort = lib.mkOption {
            type = lib.types.port;
            default = 22;
            description = "Port to listen on for SSH.";
          };

          openFirewall = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to automatically open SSH port in firewall.";
          };

          authorizedKeys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Additional SSH authorized public keys for administrative access.";
          };

          authorizeForUsers = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = ["root"];
            description = "List of user accounts that should receive the authorizedKeys.";
          };
        };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            services.openssh = {
              enable = true;
              ports = [cfg.listenPort];
              settings = {
                PasswordAuthentication = false;
                KbdInteractiveAuthentication = false;
              };
            };

            networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.listenPort];

            # Expose public keys in secrets
            secrets.files =
              lib.listToAttrs (map (name: {
                  name = "ssh/public/${name}";
                  value = {
                    file = ../../secrets/ssh/public.yaml;
                    key = name;
                    mode = "0444";
                    testValue = snakeoil.snakeOilPublicKey;
                  };
                })
                publicKeys)
              // lib.optionalAttrs hasHostKeySecret {
                "ssh/host-key" = {
                  file = hostKeySecretPath;
                  key = "ed25519";
                  mode = "0600";
                  testValue = snakeoil.snakeOilEd25519PrivateKey;
                };
              };

            virtualisation.vmVariant = {
              virtualisation.forwardPorts = [
                {
                  from = "host";
                  host.port = config.testing.vm.sshForwardPort;
                  guest.port = cfg.listenPort;
                }
              ];
            };

            testing = {
              interactiveInit = ''
                key="$state/nixconf-test-ssh-key"
                install -m 0600 ${pkgs.writeText "nixconf-test-ssh-key" snakeoil.snakeOilPrivateKey} "$key"
              '';

              interactiveNotes = [
                "  ssh           : ssh -p ${toString config.testing.vm.sshForwardPort} -i $state/nixconf-test-ssh-key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost"
              ];

              ssh = {
                description = "OpenSSH server daemon, firewall ports, and provisioned host keys";

                evalChecks.firewall-open = {
                  assertion =
                    !(cfg.enable && config.networking.firewall.enable)
                    || lib.all (p: builtins.elem p config.networking.firewall.allowedTCPPorts) [cfg.listenPort];
                  message = "SSH is enabled on port ${port} but not allowed in firewall; set `services.ssh.openFirewall = true` or add it to `networking.firewall.allowedTCPPorts`.";
                };

                inspectChecks.sshd-config = {
                  description = "sshd_config generated in /etc/ssh";
                  script = ''
                    if [ ! -d "$etc/ssh" ] || [ ! -e "$etc/ssh/sshd_config" ]; then
                      echo "Error: sshd_config was not generated!" >&2
                      exit 1
                    fi
                    if [ ! -e "$etc/pam.d/sshd" ]; then
                      echo "Error: /etc/pam.d/sshd was not generated!" >&2
                      exit 1
                    fi
                  '';
                };

                vmChecks.ssh-daemon = {
                  description = "sshd listens on port ${port}${lib.optionalString hasHostKeySecret " with the provisioned host key"}";
                  script =
                    ''
                      machine.wait_for_open_port(${port})
                    ''
                    + lib.optionalString hasHostKeySecret ''
                      machine.wait_for_unit("provision-ssh-host-key.service")
                      _hostkey = machine.succeed("${pkgs.openssh}/bin/ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key").split()[1]
                      assert _hostkey == ${builtins.toJSON (builtins.elemAt (lib.splitString " " snakeoil.snakeOilEd25519PublicKey) 1)}, "SSH host key was not provisioned from secrets"
                    '';
                };
              };
            };

            # Provision host SSH key from secrets if missing or different
            systemd.services.provision-ssh-host-key = lib.mkIf hasHostKeySecret {
              description = "Provision SSH host key from secrets if missing or different";
              wantedBy = ["sshd.service"];
              before = ["sshd.service"];
              after = ["sops-nix.service"];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
              script = ''
                if [ ! -s /etc/ssh/ssh_host_ed25519_key ] || ! ${pkgs.diffutils}/bin/cmp -s /etc/ssh/ssh_host_ed25519_key ${config.secrets.files."ssh/host-key".path}; then
                  mkdir -p /etc/ssh
                  install -m 600 ${config.secrets.files."ssh/host-key".path} /etc/ssh/ssh_host_ed25519_key
                  ${pkgs.openssh}/bin/ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key > /etc/ssh/ssh_host_ed25519_key.pub
                  chmod 644 /etc/ssh/ssh_host_ed25519_key.pub
                  if [ -d /persist/system ]; then
                    mkdir -p /persist/system/etc/ssh
                    if ! [ /etc/ssh/ssh_host_ed25519_key -ef /persist/system/etc/ssh/ssh_host_ed25519_key ]; then
                      cp -p /etc/ssh/ssh_host_ed25519_key /persist/system/etc/ssh/ssh_host_ed25519_key
                    fi
                    if ! [ /etc/ssh/ssh_host_ed25519_key.pub -ef /persist/system/etc/ssh/ssh_host_ed25519_key.pub ]; then
                      cp -p /etc/ssh/ssh_host_ed25519_key.pub /persist/system/etc/ssh/ssh_host_ed25519_key.pub
                    fi
                  fi
                fi
              '';
            };

            system.extraDependencies = lib.optional cfg.prebuildMasterSsh self.devShells.${pkgs.stdenv.hostPlatform.system}.master-ssh;

            services.openssh.extraConfig = lib.optionalString (cfg.authorizeForUsers != []) ''
              Match User ${lib.concatStringsSep "," cfg.authorizeForUsers}
                  AuthorizedKeysFile /etc/ssh/authorized_keys.d/%u ${config.secrets.files."ssh/public/master".path}
            '';

            users.users = lib.genAttrs cfg.authorizeForUsers (_: {
              openssh.authorizedKeys.keys = cfg.authorizedKeys;
            });

            persistence.files = lib.mkIf (config.persistence ? enable && config.persistence.enable) [
              "/etc/ssh/ssh_host_ed25519_key"
              "/etc/ssh/ssh_host_ed25519_key.pub"
              "/etc/ssh/ssh_host_rsa_key"
              "/etc/ssh/ssh_host_rsa_key.pub"
            ];
          }
          (lib.mkIf config.default-user.enable {
            services.ssh.authorizeForUsers = ["root" config.default-user.username];
          })
        ]);
      };
    };

    devShells = {
      pkgs,
      self',
      ...
    }: {
      master-ssh = self.lib.bitwarden.mkShell {
        inherit pkgs;
        bw = self'.packages.bw;
        meta = {
          description = "Administrative development shell configured with Bitwarden-managed master SSH private keys.";
          usage = ''
            Administrative shell configured with the master SSH deployment key.

            Extracts the master deployment identity (`6b22304d-b9cf-43ca-a483-3c97ceca6717`) from Bitwarden and exports `GIT_SSH_COMMAND` for remote machine deployment, maintenance, and cluster orchestration.
          '';
        };
        shellHook = ''
          umask 077
          master_ssh_key="$(mktemp "''${TMPDIR:-/tmp}/master-ssh.XXXXXX")"
          chmod 600 "''${master_ssh_key}"
          trap 'rm -f "''${master_ssh_key}"' EXIT

          ${self.lib.bitwarden.mkValue {
            itemId = "master-key";
            jqFilter = ".sshKey.privateKey // .notes";
          }} > "''${master_ssh_key}"

          ssh-add "''${master_ssh_key}" 2>/dev/null || true
        '';
      };
    };
  };
}
