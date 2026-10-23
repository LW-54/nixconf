{lib, ...}: {
  options.internal.docs = {
    spec = {
      core = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Core specification helpers and shared formatting utilities.";
      };
      functions = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "RFC 145 function validation specification.";
      };
      options = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "NixOS option documentation and guideline specification.";
      };
      primitives = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Core primitive schema verification specification.";
      };
      meta = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Flake package, devshell, and module metadata specification.";
      };
    };
    graph = {
      discovery = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Dynamic code and runtime inspection utilities.";
      };
      nodes = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "LPG graph node constructors.";
      };
      edges = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "LPG graph edge constructors.";
      };
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
