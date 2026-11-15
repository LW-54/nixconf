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
        last = 6;
        hourly = 24;
        daily = 14;
        weekly = 8;
        monthly = 6;
        yearly = 1;
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
        last = 12;
        hourly = 48;
        daily = 30;
        weekly = 16;
        monthly = 24;
        yearly = 5;
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
        last = 4;
        hourly = 6;
        daily = 7;
        weekly = 2;
        monthly = 1;
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
        last = 6;
        hourly = 24;
        daily = 14;
        weekly = 8;
        monthly = 12;
        yearly = 1;
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
        last = 12;
        hourly = 48;
        daily = 30;
        weekly = 16;
        monthly = 24;
        yearly = 5;
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
        last = 4;
        hourly = 6;
        daily = 7;
        weekly = 2;
        monthly = 1;
        yearly = null;
      };
    };
  };
}
