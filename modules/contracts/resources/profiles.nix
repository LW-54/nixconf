{...}: {
  internal.resources.profiles = {
    server = {
      critical = {
        description = "Critical ingress, authentication, and administrative services.";
        cpu.weight = 500;
        io.weight = 500;
        memory = {
          min = "5%";
          low = "15%";
        };
        oom = {
          preference = "avoid";
          scoreAdjust = -500;
        };
      };

      system = {
        description = "Core operating system daemons and unmanaged systemd units.";
        cpu.weight = 300;
        io.weight = 300;
        memory.low = "5%";
        oom.preference = "avoid";
      };

      standard = {
        description = "Standard user-facing application and observability services.";
        cpu.weight = 100;
        io.weight = 100;
        memory.high = "75%";
        oom = {
          preference = "none";
          kill = true;
          pressureLimit = "80%";
          scoreAdjust = 0;
        };
      };

      user = {
        description = "Interactive user login sessions and shells.";
        cpu.weight = 100;
        io.weight = 100;
        oom.preference = "none";
      };

      machine = {
        description = "Virtual machines and containers without an explicit workload tier.";
        cpu.weight = 100;
        io.weight = 100;
        oom = {
          preference = "none";
          kill = true;
          pressureLimit = "80%";
        };
      };

      background = {
        description = "Low-priority backups, snapshots, builds, and maintenance jobs.";
        cpu.weight = 20;
        io.weight = 20;
        memory.high = "80%";
        oom = {
          preference = "none";
          kill = true;
          pressureLimit = "60%";
          scoreAdjust = 500;
        };
      };
    };

    workstation = {
      user = {
        description = "Interactive desktop compositor, graphical applications, and user sessions.";
        cpu.weight = 500;
        io.weight = 500;
        memory = {
          min = "10%";
          low = "20%";
        };
        oom.preference = "avoid";
      };

      critical = {
        description = "Critical administrative and local infrastructure daemons.";
        cpu.weight = 300;
        io.weight = 300;
        memory = {
          min = "2%";
          low = "5%";
        };
        oom = {
          preference = "avoid";
          scoreAdjust = -500;
        };
      };

      system = {
        description = "Core operating system daemons and unmanaged systemd units.";
        cpu.weight = 200;
        io.weight = 200;
        memory.low = "5%";
        oom.preference = "avoid";
      };

      standard = {
        description = "Standard application and telemetry services.";
        cpu.weight = 100;
        io.weight = 100;
        oom = {
          preference = "none";
          kill = true;
          pressureLimit = "80%";
          scoreAdjust = 0;
        };
      };

      machine = {
        description = "Virtual machines and containers without an explicit workload tier.";
        cpu.weight = 100;
        io.weight = 100;
        oom = {
          preference = "none";
          kill = true;
          pressureLimit = "80%";
        };
      };

      background = {
        description = "Low-priority backups, builds, and maintenance jobs throttled on battery.";
        cpu.weight = 10;
        io.weight = 10;
        memory.high = "75%";
        oom = {
          preference = "none";
          kill = true;
          pressureLimit = "60%";
          scoreAdjust = 500;
        };
        onBattery = {
          enable = true;
          cpu = {
            weight = 5;
            quota = "50%";
          };
          io.weight = 10;
        };
      };
    };
  };
}
