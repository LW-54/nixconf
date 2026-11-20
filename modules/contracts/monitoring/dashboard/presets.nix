{lib, ...}: let
  ds = {
    metrics = {
      type = "prometheus";
      uid = "prometheus";
    };
    prometheus = {
      type = "prometheus";
      uid = "prometheus";
    };
    logs = {
      type = "victoriametrics-logs-datasource";
      uid = "victorialogs";
    };
  };

  promTarget = {
    expr,
    legend ? "",
    refId ? "A",
    instant ? false,
    range ? !instant,
    format ? "time_series",
  }: {
    datasource = ds.metrics;
    inherit expr refId instant range format;
    legendFormat = legend;
  };

  logsTarget = {
    expr,
    legend ? "",
    refId ? "A",
    queryType ? "instant",
    maxLines ? null,
  }:
    {
      datasource = ds.logs;
      editorMode = "code";
      inherit expr refId queryType;
      legendFormat = legend;
    }
    // lib.optionalAttrs (maxLines != null) {inherit maxLines;};

  links = {
    toTaskManager = {
      title = "Open Task Manager";
      url = ''/d/nixconf-task-manager?var-host=''${__data.fields.Host}&''${__url_time_range}'';
    };
    toTimeMachine = {
      title = "Open Incident Time Machine";
      url = ''/d/nixconf-time-machine?var-host=''${__data.fields.Host}&''${__url_time_range}'';
    };
    toHostHardware = {
      title = "Open Host & Hardware";
      url = ''/d/nixconf-host-hardware?var-host=''${__data.fields.Host}&''${__url_time_range}'';
    };
    toService = {
      title = "Inspect Service";
      url = ''/d/nixconf-service-inspector?var-service=''${__data.fields.Service}&''${__url_time_range}'';
    };
    toUnitLogs = {
      title = "View Unit Logs";
      url = ''/d/nixconf-logs-explorer?var-host=''${__data.fields.Host}&var-unit=''${__data.fields.Unit}&''${__url_time_range}'';
    };
  };

  mkEventAnnotations = hasHostVar: let
    withHostSel = extra:
      if hasHostVar
      then
        if extra == ""
        then ''host=~"$host"''
        else ''host=~"$host",${extra}''
      else extra;
    rebootSel = withHostSel "";
    deploySel = withHostSel "";
    oomSel = withHostSel "";
    failedSel = withHostSel ''state="failed"'';
  in [
    {
      datasource = ds.metrics;
      enable = true;
      expr = ''changes(node_boot_time_seconds{${rebootSel}}[2m]) > 0'';
      hide = false;
      iconColor = "orange";
      name = "Reboots";
      step = "60s";
      tagKeys = "host";
      textFormat = "{{host}} booted";
      titleFormat = "Host Reboot";
      useValueForTime = false;
    }
    {
      datasource = ds.metrics;
      enable = true;
      expr = ''changes(nixconf_deployment_timestamp_seconds{${deploySel}}[2m]) > 0'';
      hide = false;
      iconColor = "blue";
      name = "NixOS Deployments";
      step = "60s";
      tagKeys = "host,rev";
      textFormat = "{{host}} deployed {{rev}}";
      titleFormat = "NixOS Deploy";
      useValueForTime = false;
    }
    {
      datasource = ds.metrics;
      enable = true;
      expr = ''increase(container_oom_events_total{${oomSel}}[2m]) > 0'';
      hide = false;
      iconColor = "red";
      name = "OOM Kills";
      step = "60s";
      tagKeys = "host,unit";
      textFormat = "OOM in {{unit}} on {{host}}";
      titleFormat = "OOM Event";
      useValueForTime = false;
    }
    {
      datasource = ds.metrics;
      enable = true;
      expr = ''changes(node_systemd_unit_state{${failedSel}}[2m]) > 0 and node_systemd_unit_state{${failedSel}} == 1'';
      hide = false;
      iconColor = "purple";
      name = "Unit Failures";
      step = "60s";
      tagKeys = "host,name";
      textFormat = "{{name}} failed on {{host}}";
      titleFormat = "Unit Failed";
      useValueForTime = false;
    }
  ];

  thresholds = {
    percent = {
      mode = "absolute";
      steps = [
        {
          color = "green";
          value = null;
        }
        {
          color = "yellow";
          value = 75;
        }
        {
          color = "red";
          value = 90;
        }
      ];
    };
    percentHigh = {
      mode = "absolute";
      steps = [
        {
          color = "green";
          value = null;
        }
        {
          color = "orange";
          value = 80;
        }
        {
          color = "red";
          value = 90;
        }
      ];
    };
    percent100Ok = {
      mode = "absolute";
      steps = [
        {
          color = "red";
          value = null;
        }
        {
          color = "green";
          value = 100;
        }
      ];
    };
    upDown = {
      mode = "absolute";
      steps = [
        {
          color = "red";
          value = null;
        }
        {
          color = "green";
          value = 1;
        }
      ];
    };
    zeroOk = {
      mode = "absolute";
      steps = [
        {
          color = "green";
          value = null;
        }
        {
          color = "red";
          value = 1;
        }
      ];
    };
    zeroWarn = {
      mode = "absolute";
      steps = [
        {
          color = "green";
          value = null;
        }
        {
          color = "orange";
          value = 1;
        }
        {
          color = "red";
          value = 5;
        }
      ];
    };
    latencySec = {
      mode = "absolute";
      steps = [
        {
          color = "green";
          value = null;
        }
        {
          color = "yellow";
          value = 0.25;
        }
        {
          color = "red";
          value = 1;
        }
      ];
    };
    tempC = {
      mode = "absolute";
      steps = [
        {
          color = "green";
          value = null;
        }
        {
          color = "yellow";
          value = 75;
        }
        {
          color = "red";
          value = 90;
        }
      ];
    };
    neutral = {
      mode = "absolute";
      steps = [
        {
          color = "blue";
          value = null;
        }
      ];
    };
  };

  mkValueMappings = entries: [
    {
      type = "value";
      options = builtins.listToAttrs (lib.imap0 (index: entry: {
          name = entry.key;
          value = {
            inherit index;
            inherit (entry) color text;
          };
        })
        entries);
    }
  ];

  mappings = {
    upDown = mkValueMappings [
      {
        key = "0";
        color = "red";
        text = "DOWN";
      }
      {
        key = "1";
        color = "green";
        text = "UP";
      }
    ];
    okFail = mkValueMappings [
      {
        key = "0";
        color = "red";
        text = "FAIL";
      }
      {
        key = "1";
        color = "green";
        text = "OK";
      }
    ];
    systemdState = mkValueMappings [
      {
        key = "active";
        color = "green";
        text = "active";
      }
      {
        key = "activating";
        color = "yellow";
        text = "activating";
      }
      {
        key = "inactive";
        color = "text";
        text = "inactive";
      }
      {
        key = "failed";
        color = "red";
        text = "failed";
      }
    ];
    alertState = mkValueMappings [
      {
        key = "firing";
        color = "red";
        text = "firing";
      }
      {
        key = "pending";
        color = "orange";
        text = "pending";
      }
    ];
  };

  defaultThresholds = thresholds;

  overrideByName = name: properties: {
    matcher = {
      id = "byName";
      options = name;
    };
    inherit properties;
  };

  overrideByRegexp = regexp: properties: {
    matcher = {
      id = "byRegexp";
      options = regexp;
    };
    inherit properties;
  };

  overrideByRefId = refId: properties: {
    matcher = {
      id = "byFrameRefID";
      options = refId;
    };
    inherit properties;
  };

  colorFixed = color: {
    id = "color";
    value = {
      mode = "fixed";
      fixedColor = color;
    };
  };

  unitOverride = colName: unit:
    overrideByName colName [
      {
        id = "unit";
        value = unit;
      }
    ];

  decimalsOverride = colName: decimals:
    overrideByName colName [
      {
        id = "decimals";
        value = decimals;
      }
    ];

  negativeYOverride = regexp:
    overrideByRegexp regexp [
      {
        id = "custom.transform";
        value = "negative-Y";
      }
    ];

  dashedLineOverride = regexp: color:
    overrideByRegexp regexp [
      {
        id = "custom.lineStyle";
        value = {
          fill = "dash";
          dash = [6 4];
        };
      }
      {
        id = "custom.fillOpacity";
        value = 0;
      }
      {
        id = "custom.stacking";
        value = {
          mode = "none";
          group = "A";
        };
      }
      (colorFixed color)
    ];

  cellBadgeOverride = colName: maps:
    overrideByName colName [
      {
        id = "mappings";
        value = maps;
      }
      {
        id = "custom.cellOptions";
        value = {
          mode = "basic";
          type = "color-background";
        };
      }
    ];

  cellGaugeOverride = {
    colName,
    unit ? "percent",
    min ? 0,
    max ? 100,
    decimals ? 1,
    thresholds ? defaultThresholds.percentHigh,
    mode ? "gradient",
  }:
    overrideByName colName [
      {
        id = "unit";
        value = unit;
      }
      {
        id = "decimals";
        value = decimals;
      }
      {
        id = "min";
        value = min;
      }
      {
        id = "max";
        value = max;
      }
      {
        id = "thresholds";
        value = thresholds;
      }
      {
        id = "color";
        value = {
          mode = "thresholds";
        };
      }
      {
        id = "custom.cellOptions";
        value = {
          type = "gauge";
          inherit mode;
          valueDisplayMode = "color";
        };
      }
    ];

  statusColorOverrides = _: [
    (overrideByRegexp "/^(HTTP )?2[0-9]{2}$/" [(colorFixed "green")])
    (overrideByRegexp "/^(HTTP )?3[0-9]{2}$/" [(colorFixed "blue")])
    (overrideByRegexp "/^(HTTP )?4[0-9]{2}$/" [(colorFixed "orange")])
    (overrideByRegexp "/^(HTTP )?5[0-9]{2}$/" [(colorFixed "red")])
  ];

  logLevelColorOverrides = _: [
    (overrideByRegexp "/^(emerg|emergency|alert|crit|critical|err|error)$/" [(colorFixed "red")])
    (overrideByRegexp "/^warning$/" [(colorFixed "orange")])
    (overrideByRegexp "/^notice$/" [(colorFixed "yellow")])
    (overrideByRegexp "/^info$/" [(colorFixed "blue")])
    (overrideByRegexp "/^debug$/" [(colorFixed "purple")])
  ];

  cpuModeColorOverrides = _: [
    (overrideByName "user" [(colorFixed "green")])
    (overrideByName "system" [(colorFixed "blue")])
    (overrideByName "iowait" [(colorFixed "orange")])
    (overrideByName "steal" [(colorFixed "red")])
    (overrideByName "softirq" [(colorFixed "purple")])
    (overrideByName "irq" [(colorFixed "yellow")])
  ];

  organizeTransform = {
    exclude ? [],
    rename ? {},
    index ? {},
  }: {
    id = "organize";
    options = {
      excludeByName = lib.genAttrs exclude (_: true);
      indexByName = index;
      renameByName = rename;
    };
  };

  mergeTransform = _: {
    id = "merge";
    options = {};
  };
in {
  internal.monitoring.dashboard = {
    inherit
      ds
      promTarget
      logsTarget
      links
      mkEventAnnotations
      thresholds
      mappings
      overrideByName
      overrideByRegexp
      overrideByRefId
      colorFixed
      unitOverride
      decimalsOverride
      negativeYOverride
      dashedLineOverride
      cellBadgeOverride
      cellGaugeOverride
      statusColorOverrides
      logLevelColorOverrides
      cpuModeColorOverrides
      organizeTransform
      mergeTransform
      ;
  };
}
