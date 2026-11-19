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
    loki ? false,
  }:
    if targets != null
    then targets
    else if expr == null
    then builtins.throw "Panel builder requires either `targets` or `expr`."
    else if loki
    then [(d.lokiTarget {inherit expr legend instant;})]
    else [(d.promTarget {inherit expr legend instant format;})];

  primaryDatasource = targets:
    if targets != [] && (builtins.head targets) ? datasource
    then (builtins.head targets).datasource
    else d.ds.prometheus;

  mkStat = {
    title,
    targets ? null,
    expr ? null,
    legend ? "",
    loki ? false,
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
  }: let
    resolvedTargets = resolveTargets {inherit targets expr legend instant loki;};
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
            // lib.optionalAttrs (noValue != null) {inherit noValue;};
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

  mkBarGauge = {
    title,
    targets ? null,
    expr ? null,
    legend ? "",
    loki ? false,
    instant ? true,
    unit ? "percent",
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
    resolvedTargets = resolveTargets {inherit targets expr legend instant loki;};
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
    loki ? false,
    instant ? false,
    unit ? "short",
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
    resolvedTargets = resolveTargets {inherit targets expr legend instant loki;};
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
    loki ? false,
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
  }: let
    resolvedTargets = resolveTargets {inherit targets expr legend instant format loki;};
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
            // lib.optionalAttrs (noValue != null) {inherit noValue;};
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
  }:
    mkTable {
      inherit title expr w h noValue description;
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

  mkLogs = {
    title,
    targets ? null,
    expr ? null,
    legend ? "",
    loki ? true,
    instant ? false,
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
    resolvedTargets = resolveTargets {inherit targets expr legend instant loki;};
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
      mkBarGauge
      mkTimeseries
      mkTable
      mkSystemdUnitsTable
      mkLogs
      ;
  };
}
