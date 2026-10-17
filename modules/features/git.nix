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
  perSystem = {pkgs, ...}: {
    packages.git = inputs.wrapper-modules.wrappers.git.wrap {
      inherit pkgs;
      settings = defaultSettings;
    };

    devShells.github-ssh = pkgs.mkShell {
      packages = [
        self.packages.${pkgs.system}.bw
        pkgs.jq
      ];
      shellHook = ''
        umask 077
        github_ssh_key="$(mktemp "''${TMPDIR:-/tmp}/github-ssh.XXXXXX")"
        chmod 600 "''${github_ssh_key}"
        trap 'rm -f "''${github_ssh_key}"' EXIT

        ${self.lib.mkBitwardenSecretShellHook {
          itemId = "334fd4e6-1911-4017-9232-9463e6b70e21";
          jqFilter = ".sshKey.privateKey | select(type == \"string\" and length > 0)";
        }} > "''${github_ssh_key}"

        export GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -i ''${github_ssh_key}"
      '';
    };
  };

  flake.nixosModules.git = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.git;
    settings = self.lib.mkOptionWithUserOverride {
      inherit lib;
      type = lib.types.attrsOf lib.types.anything;
      default = defaultSettings;
      userDefault = {};
      merge = lib.recursiveUpdate;
      description = "Git settings";
    };
  in {
    options.git.prebuildGithubSsh = lib.mkEnableOption "prebuilding the GitHub SSH development shell" // {default = true;};
    config.system.extraDependencies = lib.optional cfg.prebuildGithubSsh self.devShells.${pkgs.system}.github-ssh;

    imports = [
      (self.lib.mkUserFeature {
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
}
