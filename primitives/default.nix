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
      type = lib.types.raw;
      description = "Synthesized Pass 2 primitives module.";
    };
  };

  config = {
    primitives = config.primitive.primitive.outputs;
  };
}
