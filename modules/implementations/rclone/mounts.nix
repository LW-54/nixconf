{
  internal.rclone.mkUnits = {
    self,
    config,
    lib,
    pkgs,
    utils,
    state,
    tmpl,
  }: let
    inherit
      (state)
      cfg
      enabledMounts
      mountNames
      secretId
      resolved
      ;
    inherit (tmpl) mountWhat rcloneConfigSetupScript rcloneTemplateContent;

    usedStores = lib.unique (
      lib.filter (s: s != null) (map (s: s.store or null) (builtins.attrValues state.secretFileAttrs))
    );
    secretStoreHashes =
      map (
        store: let
          p = self + "/secrets/${store}.yaml";
        in
          if builtins.pathExists p
          then builtins.hashString "sha256" (builtins.readFile p)
          else store
      )
      usedStores;

    systemdMountEntries =
      map (
        mName: let
          mCfg = enabledMounts.${mName};
        in {
          what = mountWhat mName mCfg;
          where = mCfg.mountPoint;
          type = "rclone";
          after = ["rclone-config.service" "network-online.target"];
          wants = ["rclone-config.service" "network-online.target"];
          requires = ["rclone-config.service"];
          options = lib.concatStringsSep "," (
            [
              (
                if mCfg.readOnly
                then "ro"
                else "rw"
              )
              "_netdev"
              "allow_other"
              "args2env"
              "config=/run/rclone/rclone.conf"
              "cache-dir=/var/cache/rclone/${mName}"
              "vfs-cache-mode=${mCfg.vfsCacheMode}"
              "vfs-cache-max-size=${mCfg.vfsCacheMaxSize}"
              "vfs-cache-max-age=${mCfg.vfsCacheMaxAge}"
            ]
            ++ lib.optional (mCfg.uid != null) "uid=${toString mCfg.uid}"
            ++ lib.optional (mCfg.gid != null) "gid=${toString mCfg.gid}"
            ++ lib.optional (mCfg.umask != null) "umask=${mCfg.umask}"
          );
          wantedBy = lib.optional (!mCfg.automount) "multi-user.target";
        }
      )
      mountNames;

    systemdAutomountEntries = map (
      mName: let
        mCfg = enabledMounts.${mName};
      in {
        where = mCfg.mountPoint;
        wantedBy = ["multi-user.target"];
      }
    ) (lib.filter (mName: enabledMounts.${mName}.automount) mountNames);

    nonAutomountUnits =
      map (
        mName: "${utils.escapeSystemdPath enabledMounts.${mName}.mountPoint}.mount"
      )
      mountNames;

    storagePkg = self.packages.${pkgs.stdenv.hostPlatform.system}.storage;
    hetznerTokenFiles = lib.concatMap (
      pCfg:
        lib.optional (pCfg.driver == "hetzner-box")
        config.secrets.files.${secretId pCfg.secretStore pCfg.settings.apiTokenKey}.path
    ) (builtins.attrValues resolved.providers);

    driftCheckScript = pkgs.writeShellApplication {
      name = "nixconf-storage-drift-check";
      runtimeInputs = [pkgs.coreutils storagePkg];
      meta.description = "Run scheduled declarative storage drift verification for this host.";
      text = ''
        ${lib.optionalString (builtins.length hetznerTokenFiles == 1) ''
          token_file=${lib.escapeShellArg (builtins.head hetznerTokenFiles)}
          if [[ -z "''${HETZNER_TOKEN:-}" ]] && [[ -s "$token_file" ]]; then
            HETZNER_TOKEN="$(tr -d '\n' < "$token_file")"
            export HETZNER_TOKEN
          fi
        ''}
        exec nixconf-storage --host ${lib.escapeShellArg config.networking.hostName} --check
      '';
    };

    services = lib.mkMerge [
      {
        rclone-config = {
          description = "Render obscured rclone configuration from SOPS template";
          wantedBy = ["multi-user.target"];
          before = ["remote-fs-pre.target"];
          after = ["sops-install-secrets.service"];
          restartTriggers = [rcloneTemplateContent] ++ secretStoreHashes;
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${rcloneConfigSetupScript}/bin/nixconf-rclone-config-setup";
          };
        };
      }
      (lib.mkIf cfg.driftCheck.enable {
        storage-drift-check = {
          description = "Check declarative storage state against SOPS and provider APIs";
          after = ["network-online.target" "sops-install-secrets.service"];
          wants = ["network-online.target"];
          serviceConfig = {
            Type = "oneshot";
            Environment = [
              "DEVENV_ROOT=${self}"
              "SOPS_AGE_KEY_FILE=${config.sops.age.keyFile}"
            ];
            ExecStart = "${driftCheckScript}/bin/nixconf-storage-drift-check";
          };
        };
      })
    ];

    timers = lib.mkIf cfg.driftCheck.enable {
      storage-drift-check = {
        description = "Periodic declarative storage drift check";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = cfg.driftCheck.onCalendar;
          Persistent = true;
        };
      };
    };
  in {
    inherit
      systemdMountEntries
      systemdAutomountEntries
      nonAutomountUnits
      services
      timers
      ;
  };
}
