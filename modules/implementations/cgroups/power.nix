{
  internal.cgroups.mkPower = {
    cfg,
    lib,
    pkgs,
    sliceName,
  }: let
    batteryTiers = lib.filterAttrs (_: t: t.onBattery.enable) cfg.tiers;
    enabled = cfg.power.enable && batteryTiers != {};

    mkSetProps = slice: pairs: let
      args = map (p: "${p.key}=${p.val}") pairs;
    in ''
      systemctl set-property --runtime ${lib.escapeShellArg slice} ${lib.escapeShellArgs args}
    '';

    batteryCommands = lib.concatStrings (lib.mapAttrsToList (tName: t: let
      slice = sliceName tName;
      bWeight =
        if t.onBattery.cpu.weight != null
        then t.onBattery.cpu.weight
        else (t.cpu.weight or 100);
      bQuota =
        if t.onBattery.cpu.quota != null
        then t.onBattery.cpu.quota
        else (t.cpu.quota or "");
      bIoWeight =
        if t.onBattery.io.weight != null
        then t.onBattery.io.weight
        else (t.io.weight or 100);
    in
      mkSetProps slice [
        {
          key = "CPUWeight";
          val = toString bWeight;
        }
        {
          key = "CPUQuota";
          val = bQuota;
        }
        {
          key = "IOWeight";
          val = toString bIoWeight;
        }
      ])
    batteryTiers);

    acCommands = lib.concatStrings (lib.mapAttrsToList (tName: t: let
      slice = sliceName tName;
      acWeight =
        if t.cpu.weight != null
        then t.cpu.weight
        else 100;
      acQuota =
        if t.cpu.quota != null
        then t.cpu.quota
        else "";
      acIoWeight =
        if t.io.weight != null
        then t.io.weight
        else 100;
    in
      mkSetProps slice [
        {
          key = "CPUWeight";
          val = toString acWeight;
        }
        {
          key = "CPUQuota";
          val = acQuota;
        }
        {
          key = "IOWeight";
          val = toString acIoWeight;
        }
      ])
    batteryTiers);

    powerScript = pkgs.writeShellApplication {
      name = "nixconf-power-policy";
      runtimeInputs = [pkgs.coreutils pkgs.systemd];
      meta.description = "Apply AC or battery cgroup resource throttling policy across configured tiers.";
      text = ''
        mode="ac"
        has_mains=0
        any_online=0

        for ps in /sys/class/power_supply/*; do
          [ -e "$ps" ] || continue
          if [ -r "$ps/type" ] && [ "$(cat "$ps/type")" = "Mains" ]; then
            has_mains=1
            if [ -r "$ps/online" ] && [ "$(cat "$ps/online")" = "1" ]; then
              any_online=1
            fi
          fi
        done

        if [ "$has_mains" -eq 1 ] && [ "$any_online" -eq 0 ]; then
          mode="battery"
        fi

        echo "Applying $mode power resource policy..."
        if [ "$mode" = "battery" ]; then
          ${batteryCommands}
        else
          ${acCommands}
        fi
      '';
    };
  in
    lib.mkIf enabled {
      systemd.services.resources-power-policy = {
        description = "Apply AC or battery cgroup resource throttling policy";
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = lib.getExe powerScript;
        };
      };

      services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl restart --no-block resources-power-policy.service"
      '';
    };
}
