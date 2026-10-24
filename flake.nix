{
  outputs = {self, ...} @ args: let
    inputs =
      (import ./.tack) {
        overrides = args.tackOverrides or {};
      }
      // {
        self = self // {inherit inputs;};
      };

    primitives =
      (inputs.nixpkgs.lib.evalModules {
        modules = [(inputs.import-tree ./primitives)];
        specialArgs = {inherit inputs self;};
      }).config.primitives;
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        primitives
        (inputs.import-tree ./meta)
        (inputs.import-tree ./modules)
      ];
    };
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
generate iso s (vm) for hosts
mini live usb host (inspired by sonic)
sops public secrets provisioning
non conflicting ports provisioning
LSP support
.sops.yaml in secrets

hard coded docs
docs docs docs pass
lib in diagrams
make TO DO work correctly
make more clickable
*/

