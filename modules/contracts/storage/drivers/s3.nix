{
  config,
  lib,
  ...
}: let
  # Factory for S3-compatible object storage drivers (shared by `b2` and `s3`).
  mkS3CompatibleDriver = {
    desc,
    rcloneProvider,
    defaultEndpoint ? null,
    defaultRegion ? "",
    defaultBucket ? null,
    usePathStyle ? true,
  }: {
    description = desc;
    settingsModule = {
      options = {
        endpoint = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = defaultEndpoint;
          example = "https://s3.eu-central-003.backblazeb2.com";
          description = "S3-compatible HTTPS endpoint URL for this provider instance.";
        };
        bucket = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = defaultBucket;
          example = "cyclostyle-docker";
          description = "Target bucket name inside this S3-compatible provider instance.";
        };
        region = lib.mkOption {
          type = lib.types.str;
          default = defaultRegion;
          example = "eu-central-003";
          description = "Region identifier passed to rclone S3 configuration.";
        };
        accessKeyIdKey = lib.mkOption {
          type = lib.types.str;
          default = "access-key-id";
          description = "Key name in the provider SOPS store holding the S3 access key ID.";
        };
        secretAccessKeyKey = lib.mkOption {
          type = lib.types.str;
          default = "secret-access-key";
          description = "Key name in the provider SOPS store holding the S3 secret access key.";
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
      bucket =
        if settings.bucket != null
        then settings.bucket
        else throw "storage.providers.${providerName}.settings.bucket must be set for slice '${sliceName}' (${driverName}).";
      objectPrefix = config.internal.storage.helpers.subpathJoin bucket resolvedPath;
      cleanEndpoint =
        if settings.endpoint != null
        then lib.removePrefix "https://" (lib.removePrefix "http://" settings.endpoint)
        else null;
      secrets = [
        {
          store = providerCfg.secretStore;
          key = settings.accessKeyIdKey;
          scope = "provider";
          optional = false;
          generate = null;
          description = "S3 access key ID for provider '${providerName}'.";
        }
        {
          store = providerCfg.secretStore;
          key = settings.secretAccessKeyKey;
          scope = "provider";
          optional = false;
          generate = null;
          description = "S3 secret access key for provider '${providerName}'.";
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
        type = "s3";
        subdir = objectPrefix;
        options =
          {
            provider = rcloneProvider;
            access_key_id = placeholders providerCfg.secretStore settings.accessKeyIdKey;
            secret_access_key = placeholders providerCfg.secretStore settings.secretAccessKeyKey;
            force_path_style = lib.boolToString usePathStyle;
          }
          // lib.optionalAttrs (settings.endpoint != null) {
            inherit (settings) endpoint;
          }
          // lib.optionalAttrs (settings.region != "") {
            inherit (settings) region;
          };
      };
      endpoints = {
        rclone = "${rcloneRemoteName}:${objectPrefix}";
        restic =
          if settings.endpoint != null
          then "s3:${settings.endpoint}/${objectPrefix}"
          else "rclone:${rcloneRemoteName}:";
        sftp = null;
        webdav =
          if cleanEndpoint != null
          then "https://${cleanEndpoint}/${objectPrefix}"
          else null;
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
in {
  internal.storage.drivers = {
    b2 = mkS3CompatibleDriver {
      desc = "Backblaze B2 S3-compatible object storage driver using `s3` transport for rclone and restic.";
      rcloneProvider = "Other";
      defaultEndpoint = "https://s3.eu-central-003.backblazeb2.com";
      defaultRegion = "eu-central-003";
      usePathStyle = true;
    };

    s3 = mkS3CompatibleDriver {
      desc = "Generic S3-compatible object storage driver (Garage, MinIO, Cloudflare R2, Ceph RGW).";
      rcloneProvider = "Other";
      defaultEndpoint = null;
      defaultRegion = "us-east-1";
      usePathStyle = true;
    };
  };
}
