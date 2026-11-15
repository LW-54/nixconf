{
  internal.storage.drivers.hetzner-box = {
    description = "Hetzner Storage Box driver managing isolated SSH/WebDAV/Samba subaccounts and ZFS snapshot plans via api.hetzner.com/v1.";
    settingsModule = {lib, ...}: {
      options = {
        boxId = lib.mkOption {
          type = lib.types.str;
          default = "u711975";
          description = "Hetzner Storage Box username or numeric box identifier (for example `u711975`).";
        };
        host = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "u711975.your-storagebox.de";
          description = "Override FQDN for the Storage Box; defaults to `<boxId>.your-storagebox.de`.";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 23;
          description = "SSH/SFTP port used to access this Hetzner Storage Box.";
        };
        apiTokenKey = lib.mkOption {
          type = lib.types.str;
          default = "hetzner-api-token";
          description = "Key name inside the provider SOPS store containing the Hetzner Console API bearer token.";
        };
        sshPublicKeysStore = lib.mkOption {
          type = lib.types.str;
          default = "ssh/public";
          description = "Logical SOPS secret store containing public SSH keys to deploy to SSH-enabled subaccounts.";
        };
        reachableExternally = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether subaccounts on this box are reachable from outside Hetzner networks.";
        };
        snapshotPlan = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable automated Hetzner Storage Box ZFS snapshots for this instance.";
          };
          maxSnapshots = lib.mkOption {
            type = lib.types.ints.positive;
            default = 10;
            description = "Maximum number of automated snapshots retained on this Storage Box.";
          };
          hour = lib.mkOption {
            type = lib.types.ints.between 0 23;
            default = 3;
            description = "UTC hour (0-23) when automated snapshots execute.";
          };
          minute = lib.mkOption {
            type = lib.types.ints.between 0 59;
            default = 0;
            description = "Minute of the hour (0-59) when automated snapshots execute.";
          };
          dayOfWeek = lib.mkOption {
            type = lib.types.nullOr (lib.types.ints.between 1 7);
            default = null;
            example = 7;
            description = "Optional day of week (1-7) for weekly snapshot schedules, or null for daily.";
          };
          dayOfMonth = lib.mkOption {
            type = lib.types.nullOr (lib.types.ints.between 1 31);
            default = null;
            example = 1;
            description = "Optional day of month (1-31) for monthly snapshot schedules, or null for daily/weekly.";
          };
        };
      };
    };
    resolveSlice = {
      driverName,
      providerName,
      providerCfg,
      settings,
      sliceName,
      sliceCfg,
      hostName,
      placeholders,
      resolvedPath,
      secretStore,
      rcloneRemoteName,
    }: let
      boxHost =
        if settings.host != null
        then settings.host
        else "${settings.boxId}.your-storagebox.de";
      subaccountSlug =
        if sliceCfg.scope == "per-host"
        then "${sliceName}-${hostName}"
        else sliceName;
      subaccountDescription =
        if sliceCfg.scope == "per-host"
        then "nixconf:${providerName}:${sliceName}:${hostName}"
        else "nixconf:${providerName}:${sliceName}";
      transportType =
        if sliceCfg.protocols.ssh
        then "sftp"
        else if sliceCfg.protocols.webdav
        then "webdav"
        else "smb";
      transportOptions =
        if transportType == "sftp"
        then {
          host = boxHost;
          port = toString settings.port;
          user = placeholders secretStore "username";
          pass = placeholders secretStore "password";
          shell_type = "unix";
        }
        else if transportType == "webdav"
        then {
          url = "https://${boxHost}";
          vendor = "other";
          user = placeholders secretStore "username";
          pass = placeholders secretStore "password";
        }
        else {
          host = boxHost;
          user = placeholders secretStore "username";
          pass = placeholders secretStore "password";
        };
      secrets = [
        {
          store = providerCfg.secretStore;
          key = settings.apiTokenKey;
          scope = "provider";
          optional = true;
          generate = null;
          description = "Hetzner Console API bearer token for provider '${providerName}' (${settings.boxId}).";
        }
        {
          store = secretStore;
          key = "username";
          inherit (sliceCfg) scope;
          optional = false;
          generate = "hetzner-subaccount";
          description = "Hetzner subaccount login username for slice '${sliceName}'.";
        }
        {
          store = secretStore;
          key = "password";
          inherit (sliceCfg) scope;
          optional = false;
          generate = "random-password";
          description = "Hetzner subaccount password for slice '${sliceName}'.";
        }
      ];
    in {
      inherit driverName providerName sliceName secretStore resolvedPath rcloneRemoteName secrets;
      inherit (sliceCfg) scope kind;
      hostName =
        if sliceCfg.scope == "per-host"
        then hostName
        else null;
      rcloneRemote = {
        name = rcloneRemoteName;
        type = transportType;
        # Hetzner subaccounts are already chrooted to home_directory (`resolvedPath`).
        subdir = null;
        options = transportOptions;
      };
      endpoints = {
        rclone = "${rcloneRemoteName}:";
        restic = "rclone:${rcloneRemoteName}:";
        sftp =
          if sliceCfg.protocols.ssh
          then "sftp://u-subaccount@${boxHost}:${toString settings.port}/"
          else null;
        webdav =
          if sliceCfg.protocols.webdav
          then "https://${boxHost}/"
          else null;
        smb =
          if sliceCfg.protocols.samba
          then "//${boxHost}/subaccount"
          else null;
      };
      reconcile = [
        {
          kind = "hetzner-subaccount";
          inherit providerName sliceName secretStore secrets;
          inherit (settings) boxId port apiTokenKey sshPublicKeysStore;
          host = boxHost;
          providerSecretStore = providerCfg.secretStore;
          inherit (sliceCfg) scope;
          hostName =
            if sliceCfg.scope == "per-host"
            then hostName
            else null;
          subaccount = {
            name = subaccountSlug;
            description = subaccountDescription;
            homeDirectory = resolvedPath;
            sshEnabled = sliceCfg.protocols.ssh;
            webdavEnabled = sliceCfg.protocols.webdav;
            sambaEnabled = sliceCfg.protocols.samba;
            readonly = sliceCfg.readOnly;
            inherit (settings) reachableExternally;
            usernameStore = secretStore;
            usernameKey = "username";
            passwordStore = secretStore;
            passwordKey = "password";
          };
        }
        {
          kind = "hetzner-snapshot-plan";
          inherit providerName;
          inherit (settings) boxId apiTokenKey snapshotPlan;
          providerSecretStore = providerCfg.secretStore;
        }
      ];
    };
  };
}
