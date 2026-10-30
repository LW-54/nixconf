{
  inputs,
  self,
  ...
}: let
  defaultAgeKeyFile = "/persist/sops-nix/key.txt";

  # Deterministic, well-known throwaway test age key pair for secretless tests.
  testAgePrivateKey = ''
    # Insecure, public throwaway test age key for nixconf test mode
    # public key: age18cswx3j8fsq77r3fr6ggrv40jhen573eavj0h2p9jkzkzx3zp5pqj3r4k9
    AGE-SECRET-KEY-1NJYZGE3M7QDP0UMY3NQR680KFES6Z0E2EM68RFRDVF6TV7LCMQRS7FSM76
  '';
  testAgeRecipient = "age18cswx3j8fsq77r3fr6ggrv40jhen573eavj0h2p9jkzkzx3zp5pqj3r4k9";

  testFileName = name: builtins.replaceStrings ["/"] ["__"] name;

  # sops can convert between stores while encrypting, so structured formats are
  # generated as JSON and emitted in the format sops-nix expects to decrypt.
  testPlaintext = lib: name: s:
    if s.format == "binary"
    then s.value
    else if s.format == "dotenv"
    then
      if s.key == ""
      then s.value
      else "${s.key}=${s.value}\n"
    else if s.format == "yaml" || s.format == "json"
    then
      builtins.toJSON (
        if s.key == ""
        then {data = s.value;}
        else lib.setAttrByPath (lib.splitString "/" s.key) s.value
      )
    else throw "sops: secret '${name}' uses format '${s.format}', which has no test stand-in support; use yaml, json, dotenv or binary.";

  mkTestSecrets = {
    pkgs,
    secrets,
  }: let
    inherit (pkgs) lib;
    inputType = format:
      if format == "yaml"
      then "json"
      else format;
  in
    pkgs.runCommand "nixconf-test-secrets" {
      nativeBuildInputs = [pkgs.sops];
      meta.description = "Throwaway age key and SOPS files holding non-sensitive stand-ins for host secrets.";
    } ''
            export HOME="$TMPDIR"
            mkdir -p "$out/files"
            cat > "$out/age-key.txt" <<'EOF'
      ${testAgePrivateKey}
      EOF
            recipient="${testAgeRecipient}"
            ${lib.concatStrings (lib.mapAttrsToList (name: s: ''
          sops --encrypt --age "$recipient" \
            --input-type ${inputType s.format} --output-type ${s.format} \
            ${pkgs.writeText "plain-${testFileName name}" (testPlaintext lib name s)} \
            > "$out/files/${testFileName name}"
        '')
        secrets)}
    '';
in {
  /**
  Age-encrypted secrets management and filesystem projection via SOPS-nix.
  */
  implementation.sops = {
    contract = "secrets";
    description = "Declarative encrypted secrets provisioning using SOPS and age keys.";
    lib = {
      mkTestSecrets = {
        docstring = ''
          Builds a deterministic test age key plus SOPS-encrypted files holding test stand-in values, used in test mode.

          # Inputs

          `pkgs`
          : Nixpkgs package set.

          `secrets`
          : Attribute set of `{ key, format, value }` keyed by secret name.

          # Type

          ```
          mkTestSecrets :: { pkgs, secrets } -> Derivation
          ```

          # Examples

          ```nix
          self.lib.sops.mkTestSecrets {
            inherit pkgs;
            secrets.api-token = { key = "token"; format = "yaml"; value = "dummy"; };
          }
          ```
        '';
        value = mkTestSecrets;
      };

      mkHostShell = {
        docstring = ''
          Constructs a developer shell configured to decrypt host SOPS secrets with the host's age key.

          # Inputs

          `pkgs`
          : Nixpkgs package set.

          `keyFile`
          : Path to the age private key file on the host (default: `/persist/sops-nix/key.txt`).

          # Type

          ```
          mkHostShell :: { pkgs, keyFile ? Path } -> Derivation
          ```

          # Examples

          ```nix
          self.lib.sops.mkHostShell { inherit pkgs; }
          ```
        '';
        value = {
          pkgs,
          keyFile ? defaultAgeKeyFile,
        }:
          pkgs.mkShell {
            packages = [pkgs.age pkgs.sops];
            meta.description = "Host-level development shell configured to decrypt local host SOPS secrets.";
            shellHook = let
              keyFileArg = pkgs.lib.escapeShellArg keyFile;
            in ''
              SOPS_AGE_KEY="$(${pkgs.coreutils}/bin/cat ${keyFileArg} 2>/dev/null ||
                { command -v sudo >/dev/null 2>&1 && sudo ${pkgs.coreutils}/bin/cat ${keyFileArg}; } ||
                { printf 'Unable to read the SOPS age key file: %s\n' ${keyFileArg} >&2; exit 1; }
              )" || exit 1
              export SOPS_AGE_KEY
            '';
          };
      };
    };
    module = {
      config,
      lib,
      options,
      pkgs,
      ...
    }: let
      cfg = config.sops;
      testMode = config.testing.enable;

      testSecrets = mkTestSecrets {
        inherit pkgs;
        secrets =
          lib.mapAttrs (name: s: {
            inherit (s) key;
            inherit (cfg.secrets.${name}) format;
            value = s.testValue;
          })
          config.secrets.files;
      };

      # Mirrors the conditions under which sops-nix decrypts from activation scripts
      # (as opposed to systemd units, which run after activation anyway).
      regularSecrets = lib.filterAttrs (_: s: !s.neededForUsers) cfg.secrets;
      secretsForUsers = lib.filterAttrs (_: s: s.neededForUsers) cfg.secrets;
      usersViaSystemd =
        (options.systemd ? sysusers && config.systemd.sysusers.enable)
        || (options.services ? userborn && config.services.userborn.enable);
      afterTestKey = {deps = ["nixconf-test-age-key"];};
    in {
      imports = [
        inputs.sops-nix.nixosModules.sops
        self.nixosModules.testing
      ];

      options.sops.prebuildAdminShell = lib.mkEnableOption "prebuilding the SOPS admin development shell" // {default = true;};
      options.sops.prebuildHostShell = lib.mkEnableOption "prebuilding the SOPS host development shell" // {default = true;};

      config = lib.mkMerge [
        {
          sops.age.keyFile = lib.mkDefault defaultAgeKeyFile;
          sops.defaultSopsFile = lib.mkIf (config.secrets.defaultFile != null) config.secrets.defaultFile;

          sops.secrets =
            lib.mapAttrs (name: s: {
              sopsFile =
                if testMode
                then "${testSecrets}/files/${testFileName name}"
                else if s.file != null
                then s.file
                else config.sops.defaultSopsFile;
              inherit (s) key owner group mode neededForUsers;
            })
            config.secrets.files;

          testing.evalChecks.sops-secrets-via-contract = {
            assertion = lib.all (name: config.secrets.files ? ${name}) (builtins.attrNames cfg.secrets);
            message = "sops.secrets {${lib.concatStringsSep ", " (lib.filter (n: !(config.secrets.files ? ${n})) (builtins.attrNames cfg.secrets))}} bypass the `secrets` contract, so tests cannot substitute stand-ins for them; declare them via `secrets.files` instead.";
          };

          system.extraDependencies = lib.concatLists [
            (lib.optional cfg.prebuildAdminShell self.devShells.${pkgs.stdenv.hostPlatform.system}.sops-admin)
            (lib.optional cfg.prebuildHostShell (self.lib.sops.mkHostShell {
              inherit pkgs;
              keyFile = config.sops.age.keyFile;
            }))
          ];
        }

        # Test mode: decrypt stand-ins with the deterministic test key through the regular sops-nix path.
        (lib.mkIf testMode {
          sops.validateSopsFiles = false;
          sops.age.generateKey = lib.mkForce false;
          sops.age.sshKeyPaths = lib.mkForce [];
          sops.gnupg.sshKeyPaths = lib.mkForce [];

          system.activationScripts = {
            nixconf-test-age-key = {
              deps = [];
              text = ''
                install -D -m 0400 ${testSecrets}/age-key.txt ${lib.escapeShellArg cfg.age.keyFile}
              '';
            };
            setupSecrets = lib.mkIf (regularSecrets != {} && !cfg.useSystemdActivation) afterTestKey;
            setupSecretsForUsers = lib.mkIf (secretsForUsers != {} && !usersViaSystemd) afterTestKey;
          };

          testing.checks.secrets-provisioned = {
            description = "secrets are decrypted with the declared ownership";
            priority = 100;
            script = ''
              machine.wait_for_unit("multi-user.target")
              for _path, _owner in ${builtins.toJSON (lib.mapAttrsToList (_: s: [s.path s.owner]) config.secrets.files)}:
                  machine.succeed(f"test -s {_path}")
                  _actual = machine.succeed(f"stat -L -c %U {_path}").strip()
                  assert _actual == _owner, f"{_path} is owned by {_actual}, expected {_owner}"
            '';
          };
        })
      ];
    };

    devShells = {
      pkgs,
      self',
      ...
    }: {
      sops-admin = self.lib.bitwarden.mkShell {
        inherit pkgs;
        bw = self'.packages.bw;
        packages = [pkgs.age pkgs.sops];
        meta.description = "Administrative secret editing shell with Bitwarden-authenticated master SOPS age key.";
        shellHook = self.lib.bitwarden.mkValue {
          itemId = "c2352759-f5e3-40af-a797-89bd86e230d2";
          variable = "SOPS_AGE_KEY";
          jqFilter = ".notes | select(type == \"string\" and length > 0)";
        };
      };

      sops-host = self.lib.sops.mkHostShell {inherit pkgs;};
    };
  };
}
