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


keyring
autostart
noctalia and labwc config
uwsm
systemd
cachix watcher stoping
empty trash
also look into the trash 1000 files

creat contracts

caddy ? should it be tool independent ?
restic ? toold dependence and integration with persistance ?
updates
monitoring
ressource allocation

uchiyomi
better ttyd
*/

