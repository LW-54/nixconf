{
  lib,
  inputs,
  ...
}: let
  # Well-known, intentionally public test keys shipped with nixpkgs (RFC 9500 /
  # OpenSSH fuzz-test keys). Read as plain strings so no package set is needed.
  snakeoil = import "${inputs.nixpkgs}/nixos/tests/ssh-keys.nix" {
    inherit lib;
    writeText = _: text: text;
  };

  # nixpkgs' reference yescrypt hash of the password "test"
  # (nixos/tests/systemd-sysusers-password-option-override-ordering.nix).
  testPassword = "test";
  testHashedPassword = "$y$j9T$wLgKY231.8j.ciV2MfEXe1$P0k5j3bCwHgnwW0Ive3w4knrgpiA4TzhCYLAnHvDZ51";

  tiers = ["vm" "install"];

  evalCheckSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this evaluation-time check is enforced for the host.";
      };

      assertion = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Predicate over the evaluated host configuration that must hold.";
      };

      message = lib.mkOption {
        type = lib.types.str;
        default = "Evaluation check '${name}' failed.";
        description = "Explanation shown when the assertion does not hold, ideally with a remedy.";
      };
    };
  });

  checkSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this runtime check is part of the generated host tests.";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Human readable summary used as the subtest label in test logs.";
      };

      script = lib.mkOption {
        type = lib.types.lines;
        description = ''
          NixOS test driver Python snippet. The host under test is available as `machine`;
          remote checks can additionally use the `client` machine.
        '';
      };

      remote = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether the check needs a separate `client` machine on the test network
          (e.g. to verify SSH reachability through the firewall). Remote checks only run in the `vm` tier.
        '';
      };

      tiers = lib.mkOption {
        type = lib.types.listOf (lib.types.enum tiers);
        default = tiers;
        description = "Test tiers (`vm`: virtualised storage, `install`: real disk layout and boot loader) running this check.";
      };

      priority = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "Ordering key; checks run in ascending priority, then by name.";
      };
    };
  });

  indent = prefix: text:
    lib.concatMapStringsSep "\n" (line:
      if line == ""
      then ""
      else prefix + line) (lib.splitString "\n" (lib.removeSuffix "\n" text));

  selectChecksFn = {
    checks,
    tier,
    withRemote ? tier == "vm",
  }:
    lib.sort (a: b:
      if a.priority == b.priority
      then a.name < b.name
      else a.priority < b.priority)
    (lib.filter (c: c.enable && builtins.elem tier c.tiers && (withRemote || !c.remote))
      (lib.mapAttrsToList (name: c: c // {inherit name;}) checks));

  mkTestScriptFn = {
    checks,
    tier,
    label ? null,
    withRemote ? tier == "vm",
  }:
    lib.concatMapStringsSep "\n\n" (c: let
      title = lib.optionalString (label != null) "${label}: " + c.description;
    in ''
      with subtest(${builtins.toJSON title}):
      ${indent "    " c.script}'')
    (selectChecksFn {inherit checks tier withRemote;});

  failedEvalChecksFn = evalChecks:
    lib.mapAttrsToList (name: c: {
      inherit name;
      inherit (c) message;
    })
    (lib.filterAttrs (_: c: c.enable && !c.assertion) evalChecks);

  mkTtyLoginFn = {
    user,
    password,
    tty ? 2,
  }: let
    t = toString tty;
    marker = "/tmp/nixconf-test-login-${user}";
  in ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("rm -f ${marker}")
    machine.send_key("alt-f${t}")
    machine.wait_until_succeeds("[ $(fgconsole) = ${t} ]")
    machine.wait_for_unit("getty@tty${t}.service")
    machine.wait_until_tty_matches("${t}", "login: ")
    machine.send_chars("${user}\n")
    machine.wait_until_tty_matches("${t}", "Password: ")
    machine.send_chars(${builtins.toJSON "${password}\n"})
    machine.wait_until_succeeds("pgrep -u ${user}")
    machine.send_chars("touch ${marker}\n")
    machine.wait_for_file("${marker}")
    assert machine.succeed("stat -c %U ${marker}").strip() == "${user}"
    machine.send_chars("exit\n")
  '';
in {
  contract.testing = {
    description = "Declarative host verification: evaluation-time essentials, runtime VM checks, and test stand-ins for secrets.";

    options = {
      enable = lib.mkEnableOption "test mode; only set inside generated test variants so modules can swap real secrets and hardware for stand-ins";

      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "x240";
        description = "Flake attribute name of the host under test, injected by the test harness.";
      };

      credentials = {
        password = lib.mkOption {
          type = lib.types.str;
          default = testPassword;
          description = "Plain-text password that test stand-in password hashes resolve to.";
        };

        hashedPassword = lib.mkOption {
          type = lib.types.str;
          default = testHashedPassword;
          description = "Crypt(3) hash of `testing.credentials.password`, used as the stand-in for password hash secrets.";
        };

        sshPublicKey = lib.mkOption {
          type = lib.types.str;
          default = snakeoil.snakeOilPublicKey;
          defaultText = lib.literalMD "nixpkgs snakeoil ECDSA public key from nixos/tests/ssh-keys.nix";
          description = "Public half of the test client key, used as the stand-in for authorized key secrets.";
        };

        sshPrivateKey = lib.mkOption {
          type = lib.types.str;
          default = snakeoil.snakeOilPrivateKey;
          defaultText = lib.literalMD "nixpkgs snakeoil ECDSA private key from nixos/tests/ssh-keys.nix";
          description = "Private half of the test client key, used by remote checks to log in over SSH.";
        };

        sshHostPublicKey = lib.mkOption {
          type = lib.types.str;
          default = snakeoil.snakeOilEd25519PublicKey;
          defaultText = lib.literalMD "nixpkgs snakeoil Ed25519 public key from nixos/tests/ssh-keys.nix";
          description = "Public half of the stand-in SSH host key, used to verify host key provisioning.";
        };

        sshHostPrivateKey = lib.mkOption {
          type = lib.types.str;
          default = snakeoil.snakeOilEd25519PrivateKey;
          defaultText = lib.literalMD "nixpkgs snakeoil Ed25519 private key from nixos/tests/ssh-keys.nix";
          description = "Private half of the stand-in SSH host key, used as the stand-in for host key secrets.";
        };
      };

      evalChecks = lib.mkOption {
        type = lib.types.attrsOf evalCheckSubmodule;
        default = {};
        example = {
          ssh-reachable.enable = false;
          has-swap = {
            assertion = true;
            message = "No swap device is configured.";
          };
        };
        description = ''
          Named evaluation-time checks over the host configuration. They run in seconds without building
          anything (`nix flake check --no-build`), and all failures are reported together.
        '';
      };

      checks = lib.mkOption {
        type = lib.types.attrsOf checkSubmodule;
        default = {};
        example = {
          caddy = {
            description = "reverse proxy serves HTTPS";
            script = ''
              machine.wait_for_unit("caddy.service")
              machine.wait_for_open_port(443)
            '';
          };
        };
        description = ''
          Named runtime checks contributed by modules, executed by the NixOS test driver against the
          booted host. Every host importing a module automatically inherits its checks.
        '';
      };

      vm = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether the host can be booted in a virtualised `vm` tier test.";
        };

        memorySize = lib.mkOption {
          type = lib.types.ints.positive;
          default = 2048;
          description = "Memory in MiB given to the virtual machine running the host under test.";
        };

        cores = lib.mkOption {
          type = lib.types.ints.positive;
          default = 2;
          description = "Number of virtual CPU cores given to the host under test.";
        };

        allowedFailedUnits = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["restic-backups-*.service"];
          description = "Shell-style unit patterns that may legitimately fail inside the isolated test network.";
        };

        sshForwardPort = lib.mkOption {
          type = lib.types.port;
          default = 2222;
          description = "Host port forwarded to the guest SSH daemon when running the interactive VM.";
        };
      };

      install = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Whether the `install` tier (partition the real disk layout, install, boot through the real
            boot loader) is available for this host. Enabled automatically for Disko-managed hosts.
          '';
        };
      };
    };

    lib = {
      selectChecks = {
        docstring = ''
          Selects the enabled runtime checks for a tier, sorted by priority and name.

          # Inputs

          `checks`
          : Attribute set of `testing.checks` entries.

          `tier`
          : Tier name (`"vm"` or `"install"`).

          `withRemote`
          : Whether checks needing a `client` machine are kept (default: `tier == "vm"`).

          # Type
          ```
          selectChecks :: { checks, tier, withRemote ? Bool } -> [AttrSet]
          ```

          # Examples
          ```nix
          selectChecks { checks = config.testing.checks; tier = "vm"; }
          ```
        '';
        value = selectChecksFn;
      };

      mkTestScript = {
        docstring = ''
          Renders selected runtime checks into a NixOS test driver script, one subtest per check.

          # Inputs

          `checks`
          : Attribute set of `testing.checks` entries.

          `tier`
          : Tier name (`"vm"` or `"install"`).

          `label`
          : Optional prefix (usually the host name) for subtest titles.

          `withRemote`
          : Whether checks needing a `client` machine are included (default: `tier == "vm"`).

          # Type
          ```
          mkTestScript :: { checks, tier, label ? String, withRemote ? Bool } -> String
          ```

          # Examples
          ```nix
          mkTestScript { checks = config.testing.checks; tier = "install"; label = "x240"; }
          ```
        '';
        value = mkTestScriptFn;
      };

      failedEvalChecks = {
        docstring = ''
          Returns the enabled evaluation checks whose assertion does not hold.

          # Inputs

          `evalChecks`
          : Attribute set of `testing.evalChecks` entries.

          # Type
          ```
          failedEvalChecks :: AttrSet -> [{ name, message }]
          ```

          # Examples
          ```nix
          failedEvalChecks config.testing.evalChecks
          ```
        '';
        value = failedEvalChecksFn;
      };

      mkTtyLogin = {
        docstring = ''
          Builds a test driver snippet that logs in on a virtual console with a password and verifies the session.

          # Inputs

          `user`
          : Account name to log in as.

          `password`
          : Plain-text password typed at the prompt.

          `tty`
          : Virtual console number (default: 2, leaving tty1 to greeters).

          # Type
          ```
          mkTtyLogin :: { user, password, tty ? Int } -> String
          ```

          # Examples
          ```nix
          mkTtyLogin { user = "alice"; password = config.testing.credentials.password; }
          ```
        '';
        value = mkTtyLoginFn;
      };
    };
  };
}
