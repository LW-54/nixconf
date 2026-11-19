{self, ...}: {
  feature.docker = {
    description = "Docker application container engine, socket activation, and state persistence.";
    modules = {
      docker = {
        config,
        lib,
        ...
      }: let
        cfg = config.docker;
      in {
        options.docker.enable = lib.mkEnableOption "Docker container engine" // {default = true;};

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            virtualisation.docker = {
              enable = true;
              enableOnBoot = false;
            };

            persistence.directories = ["/var/lib/docker"];
          }
          (lib.mkIf config.default-user.enable {
            users.users.${config.default-user.username}.extraGroups = ["docker"];
          })
          (lib.mkIf (config.monitoring.enable or false) {
            monitoring = {
              exporters.cadvisor.enable = true;
              watchedUnits = ["docker.service"];
              logs.journal.units = ["docker.service"];
              dashboards.containers = lib.mkOverride 1001 {
                title = "Containers & Services";
                folder = "Services";
                json = self.lib.monitoring.dashboard.mkContainersDashboard {};
              };
            };
          })
        ]);
      };
    };
  };
}
