{lib, ...}: let
  ds = {
    prometheus = {
      type = "prometheus";
      uid = "prometheus";
    };
    loki = {
      type = "loki";
      uid = "loki";
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
    datasource = ds.prometheus;
    inherit expr refId instant range format;
    legendFormat = legend;
  };

  lokiTarget = {
    expr,
    legend ? "",
    refId ? "A",
    instant ? false,
    queryType ? (
      if instant
      then "instant"
      else "range"
    ),
  }: {
    datasource = ds.loki;
    inherit expr refId instant queryType;
    legendFormat = legend;
  };

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
      lokiTarget
      thresholds
      mappings
      overrideByName
      overrideByRegexp
      colorFixed
      unitOverride
      negativeYOverride
      dashedLineOverride
      cellBadgeOverride
      statusColorOverrides
      logLevelColorOverrides
      cpuModeColorOverrides
      organizeTransform
      mergeTransform
      ;
  };
}
