{ inputs, ... }:

{
  systems = import inputs.systems;

  perSystem = { pkgs, ... }: {
    formatter = pkgs.alejandra;
  };
}