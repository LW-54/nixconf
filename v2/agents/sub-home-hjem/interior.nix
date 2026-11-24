{inputs, ...}: {
  nixos = {
    imports = [
      inputs.hjem.nixosModules.default
    ];
    users.users.lw = {
      isNormalUser = true;
      home = "/home/lw";
    };
    hjem.users.lw = {
      enable = true;
      files.".config/aky/README".text = "Managed by Antikythera (sealed feel-co/hjem).\n";
    };
  };
}
