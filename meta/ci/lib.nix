{
  self,
  lib,
  ...
}: {
  flake.lib = {
    # Parses raw YAML text into a Nix attribute set via remarshal
    fromYAML = pkgs: str: let
      json =
        pkgs.runCommand "from-yaml.json" {
          nativeBuildInputs = [pkgs.remarshal];
        } ''
          remarshal -if yaml -of json <<'EOF' > $out
          ${str}
          EOF
        '';
    in
      builtins.fromJSON (builtins.readFile json);

    # Compiles and formats YAML with yamlfmt, pre-linting with actionlint
    toYAML = pkgs: name: data: let
      raw =
        if builtins.isString data
        then pkgs.writeText "${name}.raw.yml" data
        else (pkgs.formats.yaml {}).generate "${name}.yml" data;
    in
      pkgs.runCommand "${name}.yml" {
        nativeBuildInputs = [pkgs.yamlfmt pkgs.actionlint];
      } ''
        yamlfmt -in < ${raw} > $out
        actionlint $out
      '';

    # Universally walks all outputs in self to collect buildable derivations for a system
    collectBuildables = system:
      lib.concatMapAttrs (
        name: output:
          if name == "nixosConfigurations"
          then
            lib.concatMapAttrs (hname: host:
              lib.optionalAttrs ((host.pkgs.system or host.config.nixpkgs.hostPlatform.system) == system) {
                "host-${hname}" = host.config.system.build.toplevel;
              })
            output
          else if name != "legacyPackages" && name != "outputs" && builtins.isAttrs output && output ? ${system}
          then let
            sysVal = output.${system};
          in
            if lib.isDerivation sysVal
            then {"${name}" = sysVal;}
            else if builtins.isAttrs sysVal
            then
              lib.concatMapAttrs (subName: v:
                lib.optionalAttrs (lib.isDerivation (v.inputDerivation or v)) {
                  "${name}-${subName}" = v.inputDerivation or v;
                })
              sysVal
            else {}
          else {}
      )
      self;
  };
}
