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
keyring
autostart
noctalia and labwc config
uwsm
systemd
bw wrappers
cachix watcher stoping

creat contracts

caddy ? should it be tool independent ?
restic ? toold dependence and integration with persistance ?
updates
monitoring
ressource allocation

uchiyomi
better ttyd
*/

