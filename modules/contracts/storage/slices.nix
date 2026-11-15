{
  internal.storage.defaults.slices = {
    uchiyomi = {
      kind = "direct";
      scope = "shared";
      provider = "hbox";
      path = "uchiyomi";
      protocols = {
        ssh = true;
        webdav = true;
        samba = true;
      };
    };
    hbox-backup-host = {
      kind = "direct";
      scope = "per-host";
      provider = "hbox";
      path = "backups/hosts";
      protocols = {
        ssh = true;
        webdav = false;
        samba = false;
      };
    };
    hbox-backup-shared = {
      kind = "direct";
      scope = "shared";
      provider = "hbox";
      path = "backups/shared";
      protocols = {
        ssh = true;
        webdav = false;
        samba = false;
      };
    };
    gdrive = {
      kind = "direct";
      scope = "shared";
      provider = "gdrive";
      path = "";
      protocols = {
        ssh = false;
        webdav = false;
        samba = false;
      };
    };
    gdrive-backup-host = {
      kind = "direct";
      scope = "per-host";
      provider = "gdrive";
      path = "backups/hosts";
      protocols = {
        ssh = false;
        webdav = false;
        samba = false;
      };
    };
    gdrive-backup-shared = {
      kind = "direct";
      scope = "shared";
      provider = "gdrive";
      path = "backups/shared";
      protocols = {
        ssh = false;
        webdav = false;
        samba = false;
      };
    };
    b2 = {
      kind = "direct";
      scope = "shared";
      provider = "b2";
      path = "";
      protocols = {
        ssh = false;
        webdav = false;
        samba = false;
      };
    };
    b2-backup-host = {
      kind = "direct";
      scope = "per-host";
      provider = "b2";
      path = "backups/hosts";
      protocols = {
        ssh = false;
        webdav = false;
        samba = false;
      };
    };
    b2-backup-shared = {
      kind = "direct";
      scope = "shared";
      provider = "b2";
      path = "backups/shared";
      protocols = {
        ssh = false;
        webdav = false;
        samba = false;
      };
    };
  };
}
