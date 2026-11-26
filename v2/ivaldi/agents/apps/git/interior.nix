{
  pkgs,
  lib,
  ...
}: let
  cfg = pkgs.writeText "gitconfig" (lib.generators.toGitINI {
    init.defaultBranch = "main";
    pull.rebase = true;
    fetch.prune = true;
  });

  wrapped = pkgs.symlinkJoin {
    name = "aky-git";
    paths = [pkgs.git];
    nativeBuildInputs = [pkgs.makeBinaryWrapper];
    postBuild = ''
      wrapProgram $out/bin/git --set GIT_CONFIG_GLOBAL ${cfg}
    '';
    meta.mainProgram = "git";
  };
in {
  package = wrapped;
  nixos = {
    environment.systemPackages = [wrapped];
  };
}
