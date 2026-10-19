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
system?

updates
monitoring
ressource allocation

bunq
uchiyomi
better ttyd
rss

keybinds contract
hettznerbox

diagram pre commit hook instead of action
meta
docs
*/

