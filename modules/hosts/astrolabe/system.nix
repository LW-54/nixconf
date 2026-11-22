{self, ...}: {
  host.astrolabe.subModules = {
    astrolabe-system = {pkgs, ...}: {
      imports = [
        self.nixosModules.sops
        self.nixosModules.cgroups
        self.nixosModules.rclone
        self.nixosModules.lw
        self.nixosModules.hjem
        self.nixosModules.nix
        self.nixosModules.locale
        self.nixosModules.direnv
        self.nixosModules.ssh
        self.nixosModules.git
        self.nixosModules.tack
        self.nixosModules.bw
        self.nixosModules.micro
      ];

      config = {
        networking.hostName = "astrolabe";
        environment.systemPackages = with pkgs; [
          rsync
          btop
        ];
        system.configurationRevision = self.rev or self.dirtyRev or "unknown";
        system.stateVersion = "25.11";
      };
    };
  };
}
