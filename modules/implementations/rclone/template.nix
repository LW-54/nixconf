{
  internal.rclone.mkTemplate = {
    config,
    lib,
    pkgs,
    state,
  }: let
    inherit
      (state)
      cfg
      enabledMounts
      mountNames
      requiredSliceNames
      placeholderFor
      resolved
      ;

    renderIniSection = name: type: opts: let
      keys = lib.sort (a: b: a < b) (builtins.attrNames opts);
      lines = map (k: "${k} = ${toString opts.${k}}") keys;
    in
      lib.concatStringsSep "\n" (["[${name}]" "type = ${type}"] ++ lines);

    protocolEndpointKey = proto:
      if proto == "sftp"
      then "sftp"
      else if proto == "webdav"
      then "webdav"
      else if proto == "smb"
      then "smb"
      else null;

    mountIsProtocolSupported = mCfg:
      if !(cfg.slices ? ${mCfg.slice})
      then true
      else if lib.elem mCfg.protocol ["auto" "rclone"]
      then true
      else let
        rSlice = resolved.slices.${mCfg.slice};
        epKey = protocolEndpointKey mCfg.protocol;
      in
        rSlice.rcloneRemote.type
        == mCfg.protocol
        || (
          rSlice.driverName
          == "hetzner-box"
          && epKey != null
          && (rSlice.endpoints.${epKey} or null) != null
        );

    mountNeedsProtocolOverride = mCfg: let
      rSlice = resolved.slices.${mCfg.slice};
    in
      lib.elem mCfg.protocol ["sftp" "webdav" "smb"]
      && rSlice.rcloneRemote.type != mCfg.protocol;

    mountOverrideRemote = mName: mCfg: let
      rSlice = resolved.slices.${mCfg.slice};
      pSettings = resolved.providers.${rSlice.providerName}.settings;
      boxHost =
        if pSettings.host != null
        then pSettings.host
        else "${pSettings.boxId}.your-storagebox.de";
      user = placeholderFor rSlice.secretStore "username";
      pass = placeholderFor rSlice.secretStore "password";
      options =
        if mCfg.protocol == "sftp"
        then {
          host = boxHost;
          port = toString pSettings.port;
          inherit user pass;
          shell_type = "unix";
        }
        else if mCfg.protocol == "webdav"
        then {
          url = "https://${boxHost}";
          vendor = "other";
          inherit user pass;
        }
        else {
          host = boxHost;
          inherit user pass;
        };
    in {
      name = "mount-${mName}";
      type = mCfg.protocol;
      inherit (rSlice.rcloneRemote) subdir;
      inherit options;
    };

    mountWhat = mName: mCfg: let
      rSlice = resolved.slices.${mCfg.slice};
      remoteName =
        if mountNeedsProtocolOverride mCfg
        then "mount-${mName}"
        else rSlice.rcloneRemoteName;
      subdir = rSlice.rcloneRemote.subdir or null;
    in
      if subdir != null && subdir != ""
      then "${remoteName}:${subdir}"
      else "${remoteName}:";

    sliceSections =
      map (
        sName: let
          r = resolved.slices.${sName}.rcloneRemote;
        in
          renderIniSection r.name r.type r.options
      )
      requiredSliceNames;

    overrideMountNames =
      lib.filter (
        mName: let
          mCfg = enabledMounts.${mName};
        in
          (cfg.slices ? ${mCfg.slice}) && mountNeedsProtocolOverride mCfg
      )
      mountNames;

    overrideSections =
      map (
        mName: let
          r = mountOverrideRemote mName enabledMounts.${mName};
        in
          renderIniSection r.name r.type r.options
      )
      overrideMountNames;

    rcloneTemplateContent =
      lib.concatStringsSep "\n\n" (
        ["# Managed by nixconf implementation.rclone"]
        ++ sliceSections
        ++ overrideSections
      )
      + "\n";

    templatePath = config.secrets.templates."rclone.conf".path;

    rcloneObscureScript = pkgs.writeShellApplication {
      name = "nixconf-rclone-obscure-config";
      runtimeInputs = [pkgs.coreutils pkgs.rclone];
      meta.description = "Obscure password fields from SOPS-rendered rclone templates into runtime configuration.";
      text = ''
        src="''${1:-${lib.escapeShellArg templatePath}}"
        dst="''${2:-/run/rclone/rclone.conf}"

        if [[ ! -f "$src" ]]; then
          echo "error: rclone template '$src' not found" >&2
          exit 1
        fi

        umask 077
        dst_dir="$(dirname "$dst")"
        install -d -m 0700 "$dst_dir"
        tmp_file="$(mktemp "$dst_dir/.rclone.conf.XXXXXX")"
        trap 'rm -f "$tmp_file"' EXIT

        while IFS= read -r line || [[ -n "$line" ]]; do
          if [[ "$line" =~ ^(pass|password|password2)\ =\ (.*)$ ]]; then
            key="''${BASH_REMATCH[1]}"
            val="''${BASH_REMATCH[2]}"
            if [[ -n "$val" ]]; then
              obscured="$(printf '%s' "$val" | rclone obscure -)"
              printf '%s = %s\n' "$key" "$obscured" >> "$tmp_file"
            else
              printf '%s = \n' "$key" >> "$tmp_file"
            fi
          else
            printf '%s\n' "$line" >> "$tmp_file"
          fi
        done < "$src"

        chmod 0400 "$tmp_file"
        mv -f "$tmp_file" "$dst"
      '';
    };

    rcloneConfigSetupScript = pkgs.writeShellApplication {
      name = "nixconf-rclone-config-setup";
      runtimeInputs = [pkgs.coreutils rcloneObscureScript];
      meta.description = "Initialize runtime rclone directories, VFS cache directory, and obscured rclone.conf.";
      text = ''
        install -d -m 0700 /run/rclone
        install -d -m 0750 /var/cache/rclone
        exec nixconf-rclone-obscure-config
      '';
    };
  in {
    inherit
      mountIsProtocolSupported
      mountWhat
      rcloneTemplateContent
      rcloneObscureScript
      rcloneConfigSetupScript
      ;
  };
}
