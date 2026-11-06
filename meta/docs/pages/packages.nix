# Documentation page for executable packages (docs/packages.md).
{config, ...}: let
  md = config.internal.docs.md;
  derivationPage = config.internal.docs.outputs.derivationPage;
in {
  docs.pages.packages = derivationPage {
    path = "docs/packages.md";
    title = "Packages";
    description = "Executable packages exported on `flake.packages`.";
    kind = "package";
    commandsFor = flake: name:
      md.blocks [
        (md.code "bash" "nix run .#${name}")
        (md.code "bash" "nix run ${flake}#${name}")
      ];
    renderHelp = n: let
      usage = n.properties.usage or null;
      helpCommand = n.properties.helpCommand or null;
      homepage = n.properties.homepage or null;
    in
      if usage != null
      then ''
        #### Usage

        ${usage}
      ''
      else if helpCommand != null || homepage != null
      then ''
        #### Help & Documentation

        ${
          if helpCommand != null
          then ''
            Display command-line flags and subcommands:

            ${md.code "bash" helpCommand}
          ''
          else ""
        }
        ${
          if homepage != null
          then "Official Documentation: [${homepage}](${homepage})"
          else ""
        }
      ''
      else null;
  };
}
