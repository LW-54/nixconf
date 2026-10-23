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
utilise google storage
gemini scheduled
generate iso s for hosts
mini live usb host (inspired by sonic)


primitives abstraction
Flake Schemas
docs docs
lib in diagrams
make TO DO work correctly
make more clickable
LSP support
*/

