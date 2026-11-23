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
    pkgs.runCommandLocal "${name}.yml" {
      nativeBuildInputs = [pkgs.yamlfmt];
    } ''
      yamlfmt -in < ${raw} > $out
    '';

  collectBuildables = system: let
    hosts = lib.concatMapAttrs (hname: host:
      lib.optionalAttrs ((self.host.${hname}.system or "x86_64-linux") == system) {
        "host-${hname}" = host.config.system.build.toplevel;
      }) (self.nixosConfigurations or {});
    # Map standard per-system flake outputs lazily by attribute name so
    # `builtins.attrNames (collectBuildables system)` never forces heavy derivations
    # like `packages.cpg-json` or `checks.docs` during evaluation.
    checks = lib.mapAttrs' (n: v: lib.nameValuePair "checks-${n}" v) (self.checks.${system} or {});
    packages = lib.mapAttrs' (n: v: lib.nameValuePair "packages-${n}" v) (self.packages.${system} or {});
    devShells = lib.mapAttrs' (n: v: lib.nameValuePair "devShells-${n}" (v.inputDerivation or v)) (self.devShells.${system} or {});
    formatter = lib.optionalAttrs ((self.formatter or {}) ? ${system}) {
      formatter = self.formatter.${system};
    };
  in
    checks // devShells // formatter // hosts // packages;
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
          Compiles and formats YAML with yamlfmt.

          # Inputs

          `pkgs`
          : Package set providing yamlfmt.

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
}
