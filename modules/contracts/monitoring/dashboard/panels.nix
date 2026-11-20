{
  config,
  lib,
  ...
}: let
  d = config.internal.monitoring.dashboard;

  resolveTargets = {
    targets ? null,
    expr ? null,
    legend ? "",
    instant ? false,
    format ? "time_series",
    logs ? false,
    logsQueryType ? "instant",
    maxLines ? null,
  }:
    if targets != null
    then targets
    else if expr == null
    then builtins.throw "Panel builder requires either `targets` or `expr`."
    else if logs
    then [
      (d.logsTarget {
        inherit expr legend maxLines;
        queryType = logsQueryType;
      })
    ]
    else [(d.promTarget {inherit expr legend instant format;})];

  primaryDatasource = targets:
    if targets != [] && (builtins.head targets) ? datasource
    then (builtins.head targets).datasource
    else d.ds.metrics;

  mkStat = {
    title,
    targets ? null,
    expr ? null,
    legend ? "",
    logs ? false,
    graphMode ? "none",
    instant ? (graphMode == "none"),
    unit ? "short",
    decimals ? null,
    thresholds ? d.thresholds.neutral,
    mappings ? [],
    colorMode ? "value",
    textMode ? "auto",
    reduceCalcs ? ["lastNotNull"],
    noValue ? null,
    description ? null,
    h ? 4,
    w ? null,
    overrides ? [],
    links ? [],
  }: let
    resolvedTargets = resolveTargets {
      inherit targets expr legend instant logs;
      logsQueryType = "stats";
    };
  in {
    inherit h w;
    panel =
      {
        type = "stat";
        inherit title;
        targets = resolvedTargets;
        datasource = primaryDatasource resolvedTargets;
        fieldConfig = {
          defaults =
            {
              inherit unit thresholds mappings;
              color.mode = "thresholds";
            }
            // lib.optionalAttrs (decimals != null) {inherit decimals;}
            // lib.optionalAttrs (noValue != null) {inherit noValue;}
            // lib.optionalAttrs (links != []) {inherit links;};
          inherit overrides;
        };
        options = {
          inherit colorMode graphMode textMode;
          justifyMode = "auto";
          orientation = "auto";
          reduceOptions = {
            calcs = reduceCalcs;
            fields = "";
            values = false;
          };
        };
      }
      // lib.optionalAttrs (description != null) {inherit description;};
  };

  mkRatioStat = {
    title,
    percentExpr,
    usedExpr,
    totalExpr,
    percentLegend ? "%",
    usedLegend ? "Used",
    totalLegend ? "Total",
    unit ? "bytes",
    percentDecimals ? 1,
    usedDecimals ? 1,
    totalDecimals ? usedDecimals,
    thresholds ? d.thresholds.percent,
    graphMode ? "none",
    instant ? (graphMode == "none"),
    colorMode ? "value",
    noValue ? null,
    description ? null,
    h ? 4,
    w ? null,
  }:
    mkStat {
      inherit title graphMode instant colorMode noValue description h w;
      unit = "short";
      textMode = "value_and_name";
      thresholds = d.thresholds.neutral;
      targets = [
        (d.promTarget {
          refId = "A";
          expr = percentExpr;
          legend = percentLegend;
          inherit instant;
        })
        (d.promTarget {
          refId = "B";
          expr = usedExpr;
          legend = usedLegend;
          inherit instant;
        })
        (d.promTarget {
          refId = "C";
          expr = totalExpr;
          legend = totalLegend;
          inherit instant;
        })
      ];
      overrides = [
        (d.overrideByRefId "A" [
          {
            id = "unit";
            value = "percent";
          }
          {
            id = "decimals";
            value = percentDecimals;
          }
          {
            id = "thresholds";
            value = thresholds;
          }
        ])
        (d.overrideByRefId "B" [
          {
            id = "unit";
            value = unit;
          }
          {
            id = "decimals";
            value = usedDecimals;
          }
          {
            id = "thresholds";
            value = d.thresholds.neutral;
          }
        ])
        (d.overrideByRefId "C" [
          {
            id = "unit";
            value = unit;
          }
          {
            id = "decimals";
            value = totalDecimals;
          }
          {
            id = "thresholds";
            value = d.thresholds.neutral;
          }
        ])
      ];
    };

  mkBarGauge = {
    title,
    targets ? null,
    expr ? null,
    legend ? "",
    logs ? false,
    instant ? true,
    unit ? "percent",
    decimals ? null,
    min ? 0,
    max ? null,
    thresholds ? d.thresholds.percent,
    displayMode ? "gradient",
    orientation ? "horizontal",
    reduceCalcs ? ["lastNotNull"],
    valueMode ? "color",
    showUnfilled ? true,
    noValue ? null,
    description ? null,
    h ? 8,
    w ? null,
    overrides ? [],
  }: let
    resolvedTargets = resolveTargets {
      inherit targets expr legend instant logs;
      logsQueryType = "stats";
    };
  in {
    inherit h w;
    panel =
      {
        type = "bargauge";
        inherit title;
        targets = resolvedTargets;
        datasource = primaryDatasource resolvedTargets;
        fieldConfig = {
          defaults =
            {
              inherit unit thresholds;
              color.mode = "thresholds";
            }
            // lib.optionalAttrs (decimals != null) {inherit decimals;}
            // lib.optionalAttrs (min != null) {inherit min;}
            // lib.optionalAttrs (max != null) {inherit max;}
            // lib.optionalAttrs (noValue != null) {inherit noValue;};
          inherit overrides;
        };
        options = {
          inherit displayMode orientation showUnfilled valueMode;
          minVizHeight = 10;
          minVizWidth = 0;
          namePlacement = "auto";
          reduceOptions = {
            calcs = reduceCalcs;
            fields = "";
            values = false;
          };
          sizing = "auto";
        };
      }
      // lib.optionalAttrs (description != null) {inherit description;};
  };

  mkTimeseries = {
    title,
    targets ? null,
    expr ? null,
    legend ? "",
    logs ? false,
    instant ? false,
    unit ? "short",
    decimals ? null,
    min ? null,
    max ? null,
    stacked ? false,
    drawStyle ? "line",
    fillOpacity ? (
      if drawStyle == "bars"
      then 80
      else 15
    ),
    lineInterpolation ? "smooth",
    lineWidth ? 2,
    legendMode ? "table",
    legendPlacement ? "bottom",
    legendCalcs ? ["mean" "max" "lastNotNull"],
    thresholds ? null,
    overrides ? [],
    noValue ? null,
    description ? null,
    h ? 8,
    w ? null,
  }: let
    resolvedTargets = resolveTargets {
      inherit targets expr legend instant logs;
      logsQueryType = "statsRange";
    };
  in {
    inherit h w;
    panel =
      {
        type = "timeseries";
        inherit title;
        targets = resolvedTargets;
        datasource = primaryDatasource resolvedTargets;
        fieldConfig = {
          defaults =
            {
              inherit unit;
              color.mode = "palette-classic";
              custom = {
                inherit drawStyle fillOpacity lineInterpolation lineWidth;
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineStyle.fill = "solid";
                pointSize = 5;
                scaleDistribution.type = "linear";
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode =
                    if stacked
                    then "normal"
                    else "none";
                };
                thresholdsStyle.mode =
                  if thresholds != null
                  then "line"
                  else "off";
              };
            }
            // lib.optionalAttrs (decimals != null) {inherit decimals;}
            // lib.optionalAttrs (min != null) {inherit min;}
            // lib.optionalAttrs (max != null) {inherit max;}
            // lib.optionalAttrs (thresholds != null) {inherit thresholds;}
            // lib.optionalAttrs (noValue != null) {inherit noValue;};
          inherit overrides;
        };
        options = {
          legend = {
            calcs = legendCalcs;
            displayMode = legendMode;
            placement = legendPlacement;
            showLegend = legendMode != "hidden";
          };
          tooltip = {
            mode = "multi";
            sort = "desc";
          };
        };
      }
      // lib.optionalAttrs (description != null) {inherit description;};
  };

  mkTable = {
    title,
    targets ? null,
    expr ? null,
    legend ? "",
    logs ? false,
    instant ? true,
    format ? "table",
    transformations ? [],
    overrides ? [],
    sortBy ? [],
    showHeader ? true,
    filterable ? true,
    noValue ? null,
    description ? null,
    h ? 8,
    w ? null,
    links ? [],
  }: let
    resolvedTargets = resolveTargets {
      inherit targets expr legend instant format logs;
      logsQueryType = "stats";
    };
  in {
    inherit h w;
    panel =
      {
        type = "table";
        inherit title;
        targets = resolvedTargets;
        datasource = primaryDatasource resolvedTargets;
        fieldConfig = {
          defaults =
            {
              custom = {
                align = "auto";
                cellOptions.type = "auto";
                inherit filterable;
                inspect = false;
              };
            }
            // lib.optionalAttrs (noValue != null) {inherit noValue;}
            // lib.optionalAttrs (links != []) {inherit links;};
          inherit overrides;
        };
        options = {
          cellHeight = "sm";
          footer = {
            countRows = false;
            fields = "";
            reducer = ["sum"];
            show = false;
          };
          inherit showHeader sortBy;
        };
      }
      // lib.optionalAttrs (transformations != []) {inherit transformations;}
      // lib.optionalAttrs (description != null) {inherit description;};
  };

  mkSystemdUnitsTable = {
    title,
    expr,
    w ? 12,
    h ? 8,
    noValue ? null,
    description ? null,
    links ? [d.links.toUnitLogs],
  }:
    mkTable {
      inherit title expr w h noValue description links;
      transformations = [
        (d.organizeTransform {
          exclude = ["Time" "__name__" "instance" "job" "watched" "Value"];
          rename = {
            host = "Host";
            name = "Unit";
            state = "State";
            type = "Type";
          };
          index = {
            host = 0;
            name = 1;
            state = 2;
            type = 3;
          };
        })
      ];
      overrides = [
        (d.cellBadgeOverride "State" d.mappings.systemdState)
      ];
    };

  mkStorageTable = {
    title,
    selector,
    groupBy ? ["host" "mountpoint" "fstype"],
    columns ? {
      host = "Host";
      mountpoint = "Mountpoint";
      fstype = "FS";
    },
    columnOrder ? ["host" "mountpoint" "fstype"],
    w ? 24,
    h ? 7,
    noValue ? null,
    description ? null,
  }: let
    byClause = lib.concatStringsSep ", " groupBy;
    valueColStart = builtins.length columnOrder;
    colIndices = builtins.listToAttrs (lib.imap0 (i: col: lib.nameValuePair col i) columnOrder);
  in
    mkTable {
      inherit title w h noValue description;
      sortBy = [
        {
          desc = true;
          displayName = "Usage %";
        }
      ];
      transformations = [
        (d.mergeTransform {})
        (d.organizeTransform {
          exclude = ["Time"];
          rename =
            columns
            // {
              "Value #A" = "Used";
              "Value #B" = "Available";
              "Value #C" = "Total";
              "Value #D" = "Usage %";
            };
          index =
            colIndices
            // {
              "Value #A" = valueColStart;
              "Value #B" = valueColStart + 1;
              "Value #C" = valueColStart + 2;
              "Value #D" = valueColStart + 3;
            };
        })
      ];
      overrides = [
        (d.unitOverride "Used" "bytes")
        (d.unitOverride "Available" "bytes")
        (d.unitOverride "Total" "bytes")
        (d.cellGaugeOverride {
          colName = "Usage %";
          thresholds = d.thresholds.percentHigh;
        })
      ];
      targets = [
        (d.promTarget {
          refId = "A";
          expr = ''max by (${byClause}) (node_filesystem_size_bytes{${selector}} - node_filesystem_avail_bytes{${selector}})'';
          instant = true;
          format = "table";
        })
        (d.promTarget {
          refId = "B";
          expr = ''max by (${byClause}) (node_filesystem_avail_bytes{${selector}})'';
          instant = true;
          format = "table";
        })
        (d.promTarget {
          refId = "C";
          expr = ''max by (${byClause}) (node_filesystem_size_bytes{${selector}})'';
          instant = true;
          format = "table";
        })
        (d.promTarget {
          refId = "D";
          expr = ''max by (${byClause}) (((node_filesystem_size_bytes{${selector}} - node_filesystem_avail_bytes{${selector}}) / clamp_min(node_filesystem_size_bytes{${selector}}, 1)) * 100)'';
          instant = true;
          format = "table";
        })
      ];
    };

  mkLogs = {
    title,
    targets ? null,
    expr ? null,
    legend ? "",
    logs ? true,
    maxLines ? 500,
    showTime ? true,
    showLabels ? true,
    showCommonLabels ? false,
    wrapLogMessage ? true,
    prettifyLogMessage ? true,
    enableLogDetails ? true,
    dedupStrategy ? "none",
    sortOrder ? "Descending",
    description ? null,
    h ? 12,
    w ? null,
  }: let
    resolvedTargets = resolveTargets {
      inherit targets expr legend logs maxLines;
      logsQueryType = "instant";
    };
  in {
    inherit h w;
    panel =
      {
        type = "logs";
        inherit title;
        targets = resolvedTargets;
        datasource = primaryDatasource resolvedTargets;
        options = {
          inherit
            dedupStrategy
            enableLogDetails
            prettifyLogMessage
            showCommonLabels
            showLabels
            showTime
            sortOrder
            wrapLogMessage
            ;
        };
      }
      // lib.optionalAttrs (description != null) {inherit description;};
  };
in {
  internal.monitoring.dashboard = {
    inherit
      mkStat
      mkRatioStat
      mkBarGauge
      mkTimeseries
      mkTable
      mkStorageTable
      mkSystemdUnitsTable
      mkLogs
      ;
  };
}
