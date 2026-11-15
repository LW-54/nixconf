{
  internal.backup.defaults.destinations = {
    hbox-host = {
      enable = true;
      slice = "hbox-backup-host";
      scope = "host";
      priority = 10;
      schedule = {
        onCalendar = "hourly";
        randomizedDelaySec = "5m";
        persistent = true;
      };
      retention = {
        last = 24;
        hourly = 48;
        daily = 30;
        weekly = 12;
        monthly = 12;
        yearly = 2;
      };
    };

    gdrive-host = {
      enable = true;
      slice = "gdrive-backup-host";
      scope = "host";
      priority = 20;
      schedule = {
        onCalendar = "hourly";
        randomizedDelaySec = "10m";
        persistent = true;
      };
      retention = {
        last = 48;
        hourly = 96;
        daily = 60;
        weekly = 26;
        monthly = 36;
        yearly = 10;
      };
    };

    b2-host = {
      enable = false;
      slice = "b2-backup-host";
      scope = "host";
      priority = 30;
      schedule = {
        onCalendar = "hourly";
        randomizedDelaySec = "15m";
        persistent = true;
      };
      retention = {
        last = 8;
        hourly = 12;
        daily = 7;
        weekly = 4;
        monthly = 2;
        yearly = null;
      };
    };

    hbox-shared = {
      enable = true;
      slice = "hbox-backup-shared";
      scope = "shared";
      priority = 10;
      schedule = {
        onCalendar = "hourly";
        randomizedDelaySec = "5m";
        persistent = true;
      };
      retention = {
        last = 24;
        hourly = 48;
        daily = 30;
        weekly = 12;
        monthly = 12;
        yearly = 2;
      };
    };

    gdrive-shared = {
      enable = true;
      slice = "gdrive-backup-shared";
      scope = "shared";
      priority = 20;
      schedule = {
        onCalendar = "hourly";
        randomizedDelaySec = "10m";
        persistent = true;
      };
      retention = {
        last = 48;
        hourly = 96;
        daily = 60;
        weekly = 26;
        monthly = 36;
        yearly = 10;
      };
    };

    b2-shared = {
      enable = false;
      slice = "b2-backup-shared";
      scope = "shared";
      priority = 30;
      schedule = {
        onCalendar = "hourly";
        randomizedDelaySec = "15m";
        persistent = true;
      };
      retention = {
        last = 8;
        hourly = 12;
        daily = 7;
        weekly = 4;
        monthly = 2;
        yearly = null;
      };
    };
  };
}
