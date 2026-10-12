{ ... }:
{
  flake.nixosModules.x240Resources = { config, ... }:
    {
      nix.settings = {
        # Fixed to 3 for x240 (4 cores - 1).
        build-cores = 3;
        cores = 3;
        trusted-users = [ config.users.defaultUser.name ];
      };

      zramSwap.enable = true;
    };
}