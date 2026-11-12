{lib, ...}: let
  evalCheckSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this evaluation check is enforced.";
      };

      assertion = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Predicate over the evaluated host configuration that must hold.";
      };

      message = lib.mkOption {
        type = lib.types.str;
        default = "Evaluation check '${name}' failed.";
        description = "Failure message explaining why the check failed and remedies.";
      };
    };
  });

  inspectCheckSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this artifact inspection check is enforced.";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Human-readable label for this artifact check.";
      };

      script = lib.mkOption {
        type = lib.types.lines;
        description = "Bash snippet run in artifact sandbox. Target /etc available as `$etc`, system toplevel available as `$system`.";
      };

      priority = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "Execution ordering key; lower numbers run first.";
      };
    };
  });

  checkSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this runtime check is executed in the test driver.";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Human-readable summary of the test check.";
      };

      script = lib.mkOption {
        type = lib.types.lines;
        description = "Python test driver snippet executed against running QEMU `machine`.";
      };

      priority = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "Execution ordering key; lower numbers run first.";
      };
    };
  });

  namespaceSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether checks in namespace '${name}' are active.";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Human-readable label for this test namespace.";
      };

      evalChecks = lib.mkOption {
        type = lib.types.attrsOf evalCheckSubmodule;
        default = {};
        description = "Pure evaluation-time assertions checked without building derivations.";
      };

      inspectChecks = lib.mkOption {
        type = lib.types.attrsOf inspectCheckSubmodule;
        default = {};
        description = "Sandboxed artifact inspection checks verifying generated files.";
      };

      vmChecks = lib.mkOption {
        type = lib.types.attrsOf checkSubmodule;
        default = {};
        description = "Runtime Python snippets executed inside QEMU VM. Automatically included in install tier.";
      };

      installChecks = lib.mkOption {
        type = lib.types.attrsOf checkSubmodule;
        default = {};
        description = "Install-tier lifecycle Python snippets executed in the full Disko environment.";
      };
    };
  });

  scenarioSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this scenario test is enabled.";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Human-readable summary of this multi-node test scenario.";
      };

      nodes = lib.mkOption {
        type = lib.types.attrsOf lib.types.deferredModule;
        description = "NixOS machine configurations participating in this scenario.";
      };

      testScript = lib.mkOption {
        type = lib.types.lines;
        description = "Python test driver script orchestrating the multi-node test.";
      };
    };
  });
in {
  # Flake-level option for arbitrary multi-node scenarios
  options.test.scenarios = lib.mkOption {
    type = lib.types.attrsOf scenarioSubmodule;
    default = {};
    description = "Arbitrary multi-node test scenarios compiled into legacyPackages.<system>.scenarios.";
  };

  config = {
    flake.nixosModules.testing = {
      _file = "meta/tests/options.nix";
      key = "meta-tests-testing-options";
      options.testing = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.attrsOf namespaceSubmodule;
          options = {
            enable = lib.mkEnableOption "test mode; enables stand-in secrets and virtualisation tweaks";

            name = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "x240";
              description = "Flake host name under test.";
            };

            interactiveInit = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Shell script commands executed prior to starting interactive test VM (e.g. setting up test keys).";
            };

            interactiveNotes = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "Banner notices displayed when launching an interactive test VM.";
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
                description = "Memory in MiB given to the test virtual machine.";
              };

              cores = lib.mkOption {
                type = lib.types.ints.positive;
                default = 2;
                description = "Virtual CPU cores allocated to the host under test.";
              };

              allowedFailedUnits = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                description = "Systemd unit patterns that may legitimately fail inside isolated test networks.";
              };

              sshForwardPort = lib.mkOption {
                type = lib.types.port;
                default = 2222;
                description = "Host port forwarded to guest SSH daemon in interactive VMs.";
              };
            };

            install = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether the `install` tier (real Disko layout & bootloader) is available.";
              };
            };
          };
        };
        default = {};
        description = "Decentralized host testing framework: evaluation, inspection, runtime VM, and install tiers.";
      };
    };
  };
}
