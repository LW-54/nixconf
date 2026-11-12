{
  self,
  lib,
  ...
}: let
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
in {
  lib.ci = {
    description = "Continuous integration workflow helpers, YAML serialization, and derivation collection utilities.";
    symbols = {
      fromYAML = {
        docstring = ''
          Parses raw YAML text into a Nix attribute set via remarshal.

          # Inputs

          `pkgs`
          : Package set providing the remarshal tool.

          `str`
          : Raw YAML string content to parse.

          # Type
          ```
          fromYAML :: Pkgs -> String -> AttrSet
          ```
        '';
        value = fromYAML;
      };

      toYAML = {
        docstring = ''
          Compiles and formats YAML with yamlfmt, pre-linting with actionlint.

          # Inputs

          `pkgs`
          : Package set providing yamlfmt and actionlint.

          `name`
          : Workflow name string used for output file naming.

          `data`
          : Native Nix attribute set or raw YAML string representing the workflow.

          # Type
          ```
          toYAML :: Pkgs -> String -> (AttrSet | String) -> Derivation
          ```
        '';
        value = toYAML;
      };

      collectBuildables = {
        docstring = ''
          Universally walks all outputs in self to collect buildable derivations for a system.

          # Inputs

          `system`
          : System architecture string (e.g. "x86_64-linux").

          # Type
          ```
          collectBuildables :: String -> AttrSet
          ```
        '';
        value = collectBuildables;
      };
    };
  };

  # Preserve top-level flake.lib symbols for backward compatibility
  flake.lib = {
    inherit fromYAML toYAML collectBuildables;
  };
}
