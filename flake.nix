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


keyring?

creat contracts

caddy ? should it be tool independent ?
restic ? toold dependence and integration with persistance ?
updates
monitoring
ressource allocation

bunq
uchiyomi
better ttyd
rss

keybinds contract
*/

