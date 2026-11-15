{
  self,
  lib,
  ...
}: {
  internal.storage.drivers.gdrive = {
    description = "Google Drive rclone driver with per-instance OAuth token isolation and subdirectory slicing.";
    settingsModule = {lib, ...}: {
      options = {
        scope = lib.mkOption {
          type = lib.types.enum ["drive" "drive.readonly" "drive.file" "drive.appfolder"];
          default = "drive";
          description = "Google Drive OAuth access scope requested by rclone.";
        };
        rootFolderId = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "1A2B3C4D5E6F";
          description = "Optional Google Drive root folder ID constraining this provider instance.";
        };
        tokenKey = lib.mkOption {
          type = lib.types.str;
          default = "token";
          description = "Key name in the provider SOPS store holding the serialized rclone OAuth JSON token.";
        };
        clientIdKey = lib.mkOption {
          type = lib.types.str;
          default = "client-id";
          description = "Key name in the provider SOPS store holding an optional custom OAuth client ID.";
        };
        clientSecretKey = lib.mkOption {
          type = lib.types.str;
          default = "client-secret";
          description = "Key name in the provider SOPS store holding an optional custom OAuth client secret.";
        };
        useCustomClient = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Whether to inject custom OAuth `client_id` and `client_secret` from SOPS into `rclone.conf` (null auto-detects whether encrypted values exist in the provider SOPS file).";
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
      sopsFile = self + "/secrets/${providerCfg.secretStore}.yaml";
      sopsLines =
        if builtins.pathExists sopsFile
        then lib.splitString "\n" (builtins.readFile sopsFile)
        else [];
      hasEncryptedKey = key:
        lib.any (
          line: builtins.match "^${lib.escapeRegex key}:[[:space:]]*ENC\\[.*" line != null
        )
        sopsLines;
      customClientActive =
        if settings.useCustomClient != null
        then settings.useCustomClient
        else (hasEncryptedKey settings.clientIdKey) && (hasEncryptedKey settings.clientSecretKey);
      secrets = [
        {
          store = providerCfg.secretStore;
          key = settings.tokenKey;
          scope = "provider";
          optional = false;
          generate = null;
          description = "Google Drive rclone OAuth token JSON for provider '${providerName}'.";
        }
        {
          store = providerCfg.secretStore;
          key = settings.clientIdKey;
          scope = "provider";
          optional = !customClientActive;
          generate = null;
          description = "Optional custom Google OAuth client ID for provider '${providerName}'.";
        }
        {
          store = providerCfg.secretStore;
          key = settings.clientSecretKey;
          scope = "provider";
          optional = !customClientActive;
          generate = null;
          description = "Optional custom Google OAuth client secret for provider '${providerName}'.";
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
        type = "drive";
        subdir = resolvedPath;
        options =
          {
            inherit (settings) scope;
            token = placeholders providerCfg.secretStore settings.tokenKey;
          }
          // lib.optionalAttrs (settings.rootFolderId != null) {
            root_folder_id = settings.rootFolderId;
          }
          // lib.optionalAttrs customClientActive {
            client_id = placeholders providerCfg.secretStore settings.clientIdKey;
            client_secret = placeholders providerCfg.secretStore settings.clientSecretKey;
          };
      };
      endpoints = {
        rclone = "${rcloneRemoteName}:${resolvedPath}";
        restic = "rclone:${rcloneRemoteName}:${resolvedPath}";
        sftp = null;
        webdav = null;
        smb = null;
      };
      reconcile = [
        {
          kind = "sops-secret";
          inherit providerName sliceName secretStore secrets;
        }
      ];
    };
  };
}
