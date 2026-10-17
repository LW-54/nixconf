{
  outputs = {self, ...} @ args: let
    inputs =
      (import ./.tack) {
        overrides = args.tackOverrides or {};
      }
      // {
        self = self // {inherit inputs;};
      };
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
/*

refactor default user and hjem/users split
simplify abstraction lib
make lib module specefic mayb but lib in parts.nix and maybe also declare disko config
keyring
autostart
noctalia and labwc config
uwsm
systemd
bw wrappers
cachix watcher stoping
git username and email maybe also regular user name in defaults
sops key ? sops_host environement
improve bitwarden shell (pkgs.mkShell wrapper for dependencies and maybe think about removing the jq dependency)
evaluation warning: 'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'
prebuild devshells
devshells pkg inheritence


creat contracts

caddy ? should it be tool independent ?
restic ? toold dependence and integration with persistance ?
updates
monitoring
ressource allocation

uchiyomi
better ttyd
make bw use the vaultwarden variable

empty trash
also look into the trash 1000 files
*/

