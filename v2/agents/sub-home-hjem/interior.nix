{
  bound,
  inputs,
  ...
}: let
  user = bound."config:primary-user".name;
in {
  nixos = {
    imports = [
      inputs.hjem.nixosModules.default
    ];
    users.users.${user} = {
      isNormalUser = true;
      home = "/home/${user}";
    };
    hjem.users.${user} = {
      enable = true;
      files.".config/aky/README".text = "Managed by Antikythera (sealed feel-co/hjem).\n";
    };
  };
}
