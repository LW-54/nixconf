{
  internal.cgroups.mkAllocations = {
    config,
    cfg,
    lib,
    pkgs,
    toBytes,
  }: let
    monEnabled = config.monitoring.enable or false;
    enabledUnits = lib.filterAttrs (_: u: u.enable) cfg.units;

    textfileDir = let
      d = config.monitoring.exporters.unix.textfileDirectory or null;
    in
      if d != null
      then d
      else "/var/lib/alloy/textfile";

    parsePctRatio = v:
      if builtins.isString v && lib.hasSuffix "%" v
      then (builtins.fromJSON (lib.removeSuffix "%" v)) / 100.0
      else null;

    mkMetricBlock = name: help: samples:
      lib.optionalString (samples != []) (
        lib.concatStringsSep "\n" (
          [
            "# HELP ${name} ${help}"
            "# TYPE ${name} gauge"
          ]
          ++ samples
        )
        + "\n"
      );

    collectEntries = items: mkLabels: extractor:
      lib.concatLists (
        lib.mapAttrsToList (
          k: v: let
            val = extractor v;
          in
            lib.optional (val != null) "{${mkLabels k v}} ${toString val}"
        )
        items
      );

    mkFamily = name: help: items: mkLabels: extractor:
      mkMetricBlock name help (
        map (s: "${name}${s}") (collectEntries items mkLabels extractor)
      );

    memBytes = field: item: let
      v = (item.memory or {}).${field} or null;
    in
      if v == null || v == "infinity" || (builtins.isString v && lib.hasSuffix "%" v)
      then null
      else toBytes v;

    memRatio = field: item: let
      v = (item.memory or {}).${field} or null;
    in
      if builtins.isString v && lib.hasSuffix "%" v
      then parsePctRatio v
      else null;

    sliceLabels = sName: _: "slice=${builtins.toJSON sName}";
    unitLabels = uName: u: "slice=${builtins.toJSON u.tier},unit=${builtins.toJSON uName}";

    mkScopeBlocks = prefix: scopeDesc: items: mkLabels:
      lib.concatStrings [
        (mkFamily "${prefix}_info" "Declarative ${scopeDesc} managed by the resources contract." items mkLabels (_: 1))
        (mkFamily "${prefix}_cpu_weight" "Declared cgroup CPUWeight for ${scopeDesc}." items mkLabels (x: x.cpu.weight or null))
        (mkFamily "${prefix}_io_weight" "Declared cgroup IOWeight for ${scopeDesc}." items mkLabels (x: x.io.weight or null))
        (mkFamily "${prefix}_cpu_quota_cores" "Declared cgroup CPUQuota in cores for ${scopeDesc}." items mkLabels (x: parsePctRatio (x.cpu.quota or null)))
        (mkFamily "${prefix}_memory_min_bytes" "Declared MemoryMin in bytes for ${scopeDesc}." items mkLabels (memBytes "min"))
        (mkFamily "${prefix}_memory_min_ratio" "Declared MemoryMin fraction of host RAM for ${scopeDesc}." items mkLabels (memRatio "min"))
        (mkFamily "${prefix}_memory_low_bytes" "Declared MemoryLow in bytes for ${scopeDesc}." items mkLabels (memBytes "low"))
        (mkFamily "${prefix}_memory_low_ratio" "Declared MemoryLow fraction of host RAM for ${scopeDesc}." items mkLabels (memRatio "low"))
        (mkFamily "${prefix}_memory_high_bytes" "Declared MemoryHigh in bytes for ${scopeDesc}." items mkLabels (memBytes "high"))
        (mkFamily "${prefix}_memory_high_ratio" "Declared MemoryHigh fraction of host RAM for ${scopeDesc}." items mkLabels (memRatio "high"))
        (mkFamily "${prefix}_memory_max_bytes" "Declared MemoryMax in bytes for ${scopeDesc}." items mkLabels (memBytes "max"))
        (mkFamily "${prefix}_memory_max_ratio" "Declared MemoryMax fraction of host RAM for ${scopeDesc}." items mkLabels (memRatio "max"))
      ];

    allocationsPromContent =
      (mkScopeBlocks "nixconf_resource_slice" "workload slice" cfg.tiers sliceLabels)
      + (mkScopeBlocks "nixconf_resource_unit" "managed systemd unit" enabledUnits unitLabels);

    allocationsPromFile = pkgs.writeText "allocations.prom" allocationsPromContent;
  in
    lib.mkIf monEnabled {
      systemd.tmpfiles.rules = [
        "L+ ${textfileDir}/allocations.prom - - - - ${allocationsPromFile}"
      ];

      monitoring.rules.resources-recording = {
        backend = "metrics";
        interval = "5m";
        rules = [
          {
            record = "nixconf:slice_memory_high_bytes";
            expr = ''max by (host, slice) (nixconf_resource_slice_memory_high_bytes or (nixconf_resource_slice_memory_high_ratio * on (host) group_left () node_memory_MemTotal_bytes))'';
          }
          {
            record = "nixconf:slice_memory_max_bytes";
            expr = ''max by (host, slice) (nixconf_resource_slice_memory_max_bytes or (nixconf_resource_slice_memory_max_ratio * on (host) group_left () node_memory_MemTotal_bytes) or (container_spec_memory_limit_bytes{id=~"/[^/]+\\.slice",slice!=""} > 0))'';
          }
          {
            record = "nixconf:unit_memory_high_bytes";
            expr = ''max by (host, slice, unit) (nixconf_resource_unit_memory_high_bytes or (nixconf_resource_unit_memory_high_ratio * on (host) group_left () node_memory_MemTotal_bytes))'';
          }
          {
            record = "nixconf:unit_memory_max_bytes";
            expr = ''max by (host, slice, unit) (nixconf_resource_unit_memory_max_bytes or (nixconf_resource_unit_memory_max_ratio * on (host) group_left () node_memory_MemTotal_bytes) or (container_spec_memory_limit_bytes{unit!=""} > 0))'';
          }
          {
            record = "nixconf:host_cpu_utilization_percent:rate5m";
            expr = ''100 - (avg by (host) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)'';
          }
          {
            record = "nixconf:host_memory_used_bytes";
            expr = ''max by (host) (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes)'';
          }
          {
            record = "nixconf:slice_cpu_cores:rate5m";
            expr = ''sum by (host, slice) (rate(container_cpu_usage_seconds_total{id=~"/[^/]+\\.slice",slice!=""}[5m]))'';
          }
          {
            record = "nixconf:unit_cpu_cores:rate5m";
            expr = ''max by (host, slice, unit) (rate(container_cpu_usage_seconds_total{unit!=""}[5m]))'';
          }
          {
            record = "nixconf:process_cpu_cores:rate5m";
            expr = ''sum by (host, groupname) (rate(namedprocess_namegroup_cpu_seconds_total[5m]))'';
          }
        ];
      };
    };
}
