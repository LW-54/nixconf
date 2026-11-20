{...}: {
  host.x240.subModules = {
    x240-resources = {config, ...}: {
      resources = {
        profile = "workstation";
        disk = {
          nixMinFree = "2G";
          nixMaxFree = "10G";
        };
        units = {
          "docker.service".tier = "background";
          "alloy.service".memory = {
            high = "256M";
            max = "512M";
          };
        };
        volumes.emergency-headroom = {
          mode = "reserved";
          size =
            if (config.testing.enable or false)
            then "64M"
            else "2G";
        };
      };
    };
  };
}
