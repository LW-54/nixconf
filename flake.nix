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
      systems = import inputs.systems;
      imports = [
        primitives
        (inputs.import-tree ./meta)
        (inputs.import-tree ./modules)
      ];
      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };
    };
}
