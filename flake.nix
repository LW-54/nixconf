{
  inputs.devenv-root = {
    url = "file+file:///dev/null";
    flake = false;
  };

  outputs = {self, ...} @ args: let
    inputs =
      (import ./.tack) {
        overrides = args.tackOverrides or {};
      }
      // {
        self = self // {inherit inputs;};
        inherit (args) devenv-root;
      };

    primitives =
      (inputs.nixpkgs.lib.evalModules {
        modules = [(inputs.import-tree ./primitives)];
        specialArgs = {inherit inputs self;};
      }).config.primitives;
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;
      imports = [
        inputs.devenv.flakeModule
        primitives
        (inputs.import-tree ./meta)
        (inputs.import-tree ./modules)
      ];
      perSystem = {pkgs, ...}: {
        devenv.shells.default = {
          imports = [./devenv.nix];
        };
        formatter = pkgs.alejandra;
      };
    };
}
