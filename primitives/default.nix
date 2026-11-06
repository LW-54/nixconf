{
  config,
  lib,
  primitiveSubmodule,
  ...
}: {
  options = {
    primitive = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule primitiveSubmodule);
      default = {};
      description = "Declared primitives in the repository.";
    };
    primitives = lib.mkOption {
      type = lib.types.deferredModule;
      description = "Synthesized Pass 2 primitives module.";
    };
    docs = lib.mkOption {
      type = lib.types.deferredModule;
      default = {};
      description = "Parallel documentation module declared across primitives.";
    };
  };

  config = {
    primitives = {
      imports = [
        config.primitive.primitive.outputs
        config.docs
      ];
    };
  };
}
