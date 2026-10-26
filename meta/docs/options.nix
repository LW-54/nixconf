{lib, ...}: {
  options.internal.docs = {
    trees = lib.mkOption {
      type = lib.types.raw;
      default = {};
      description = "Disko and Impermanence ASCII tree generators for host documentation.";
    };
    markdown = {
      shared = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Shared markdown table row and link helpers.";
      };
      hosts = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Host markdown rendering engine.";
      };
      contracts = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Contract markdown rendering engine.";
      };
      implementations = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Implementation markdown rendering engine.";
      };
      features = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Feature markdown rendering engine.";
      };
      outputs = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Module, package, devshell, and lib markdown rendering engine.";
      };
      root = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Root README, debt, and guide markdown rendering engine.";
      };
    };
  };
}
