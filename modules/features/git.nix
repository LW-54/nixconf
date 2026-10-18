{
  self,
  inputs,
  ...
}: let
  defaultSettings = {
    user.name = "LW-54";
    user.email = "leonardwilsonb@gmail.com";
    pull.rebase = true;
    fetch.prune = true;
    push.autoSetupRemote = true;
    rerere.enabled = true;
  };
in {
  flake.nixosModules.git = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.git;
    settings = self.lib.users.mkOptionWithUserOverride {
      inherit lib;
      type = lib.types.attrsOf lib.types.anything;
      default = defaultSettings;
      userDefault = {};
      merge = lib.recursiveUpdate;
      description = "Git settings";
    };
  in {
    options.git.prebuildGithubSsh = lib.mkEnableOption "prebuilding the GitHub SSH development shell" // {default = true;};
    config.system.extraDependencies = lib.optional cfg.prebuildGithubSsh self.devShells.${pkgs.stdenv.hostPlatform.system}.github-ssh;

    imports = [
      (self.lib.users.mkUserFeature {
        inherit lib;
        name = "git";
        description = "Git";
        package = pkgs: pkgs.git;

        featureOptions.settings = settings.global;
        userOptions.settings = settings.user;

        userModule = {
          cfg,
          user,
          lib,
          ...
        }: {
          xdg.config.files."git/config" = {
            generator = lib.generators.toINI {};
            value = lib.recursiveUpdate cfg.settings (user.settings or {});
          };
        };
      })
    ];
  };

  perSystem = {pkgs, ...}: {
    packages.git = inputs.wrapper-modules.wrappers.git.wrap {
      inherit pkgs;
      settings = defaultSettings;
    };

    devShells.github-ssh = self.lib.bitwarden.mkShell {
      inherit pkgs;
      shellHook = ''
        umask 077
        github_ssh_key="$(mktemp "''${TMPDIR:-/tmp}/github-ssh.XXXXXX")"
        chmod 600 "''${github_ssh_key}"
        trap 'rm -f "''${github_ssh_key}"' EXIT

        ${self.lib.bitwarden.mkValue {
          itemId = "334fd4e6-1911-4017-9232-9463e6b70e21";
          jqFilter = ".sshKey.privateKey | select(type == \"string\" and length > 0)";
        }} > "''${github_ssh_key}"

        export GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -i ''${github_ssh_key}"
      '';
    };
  };
}
