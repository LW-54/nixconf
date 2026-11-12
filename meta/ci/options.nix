{lib, ...}: {
  perSystem = {pkgs, ...}: {
    options.workflow = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}: {
        freeformType = (pkgs.formats.yaml {}).type;
      }));
      default = {};
      description = ''
        Declarative GitHub Actions workflows.
        The attribute name maps to .github/workflows/<name>.yml.
        The value is a native Nix attribute set representing the YAML document structure.
      '';
    };
  };
}
