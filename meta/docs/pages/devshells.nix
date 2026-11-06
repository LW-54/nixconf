# Documentation page for interactive development shells (docs/devshells.md).
{config, ...}: let
  md = config.internal.docs.md;
  derivationPage = config.internal.docs.outputs.derivationPage;
in {
  docs.pages.devshells = derivationPage {
    path = "docs/devshells.md";
    title = "Development Shells";
    description = "Interactive environments exported on `flake.devShells`.";
    kind = "devShell";
    commandsFor = flake: name:
      md.blocks [
        (md.code "bash" "nix develop .#${name}")
        (md.code "bash" "nix develop ${flake}#${name}")
      ];
    renderHelp = n: let
      usage = n.properties.usage or null;
    in
      if usage != null
      then ''
        #### Usage

        ${usage}
      ''
      else null;
  };
}
