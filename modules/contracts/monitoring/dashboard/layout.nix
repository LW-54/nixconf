{lib, ...}: let
  mkRow = panels: {
    _kind = "row";
    inherit panels;
  };

  mkSection = {
    title,
    collapsed ? false,
    rows,
  }: {
    _kind = "section";
    inherit title collapsed rows;
  };

  layoutRow = startY: startId: rawPanels: let
    norm =
      map (
        item:
          if item ? panel
          then item
          else {
            h = item.gridPos.h or 8;
            w = item.gridPos.w or null;
            panel = item;
          }
      )
      rawPanels;

    explicitSum =
      lib.foldl' (acc: p:
        acc
        + (
          if p.w != null
          then p.w
          else 0
        ))
      0
      norm;
    unsetCount = lib.length (lib.filter (p: p.w == null) norm);
    availWidth = lib.max 0 (24 - explicitSum);
    autoBaseW =
      if unsetCount > 0
      then lib.max 1 (availWidth / unsetCount)
      else 0;
    autoRemW =
      if unsetCount > 0
      then availWidth - (autoBaseW * unsetCount)
      else 0;

    withWidths =
      (lib.foldl' (
          acc: p:
            if p.w != null
            then
              acc
              // {
                items = acc.items ++ [{inherit (p) h w panel;}];
              }
            else let
              isLastUnset = acc.remIdx + 1 == unsetCount;
              pw =
                autoBaseW
                + (
                  if isLastUnset
                  then autoRemW
                  else 0
                );
            in {
              remIdx = acc.remIdx + 1;
              items =
                acc.items
                ++ [
                  {
                    inherit (p) h panel;
                    w = pw;
                  }
                ];
            }
        ) {
          remIdx = 0;
          items = [];
        }
        norm)
      .items;

    placed =
      lib.foldl' (
        acc: item: let
          wrapped = acc.x > 0 && (acc.x + item.w > 24);
          px =
            if wrapped
            then 0
            else acc.x;
          py =
            if wrapped
            then acc.y + acc.lineH
            else acc.y;
          nextLineH =
            if wrapped
            then item.h
            else lib.max acc.lineH item.h;
          builtPanel =
            item.panel
            // {
              id = acc.nextId;
              gridPos = {
                x = px;
                y = py;
                inherit (item) w h;
              };
            };
        in {
          x = px + item.w;
          y = py;
          lineH = nextLineH;
          nextId = acc.nextId + 1;
          panels = acc.panels ++ [builtPanel];
        }
      ) {
        x = 0;
        y = startY;
        lineH = 0;
        nextId = startId;
        panels = [];
      }
      withWidths;
  in {
    nextY = placed.y + placed.lineH;
    inherit (placed) nextId panels;
  };

  layoutRows = startY: startId: rows:
    lib.foldl' (
      acc: rowItem: let
        rowPanels =
          if (rowItem._kind or null) == "row"
          then rowItem.panels
          else if builtins.isList rowItem
          then rowItem
          else [rowItem];
        res = layoutRow acc.nextY acc.nextId rowPanels;
      in {
        inherit (res) nextY nextId;
        panels = acc.panels ++ res.panels;
      }
    ) {
      nextY = startY;
      nextId = startId;
      panels = [];
    }
    rows;

  mkDashboard = {
    uid,
    title,
    description ? "",
    tags ? [],
    refresh ? "30s",
    timeFrom ? "now-3h",
    timeTo ? "now",
    variables ? [],
    sections ? [],
    links ? null,
  }: let
    defaultLinks =
      [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = ["nixconf"];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
      ]
      ++ lib.optional (uid != "nixconf-logs-explorer") {
        icon = "doc";
        includeVars = true;
        keepTime = true;
        targetBlank = false;
        title = "Logs Explorer";
        tooltip = "Open centralized journald logs explorer";
        type = "link";
        url = "/d/nixconf-logs-explorer";
      }
      ++ lib.optional (uid != "nixconf-service-inspector") {
        icon = "dashboard";
        includeVars = true;
        keepTime = true;
        targetBlank = false;
        title = "Service Inspector";
        tooltip = "Inspect metrics, units, and logs for a specific service";
        type = "link";
        url = "/d/nixconf-service-inspector";
      };

    assembled =
      lib.foldl' (
        acc: sec:
          if (sec._kind or null) == "row"
          then let
            res = layoutRow acc.nextY acc.nextId sec.panels;
          in {
            inherit (res) nextY nextId;
            panels = acc.panels ++ res.panels;
          }
          else if (sec._kind or null) == "section"
          then let
            rowId = acc.nextId;
            rowY = acc.nextY;
            children = layoutRows (rowY + 1) (rowId + 1) sec.rows;
            collapsed = sec.collapsed or false;
            rowDivider = {
              id = rowId;
              type = "row";
              inherit (sec) title;
              inherit collapsed;
              gridPos = {
                h = 1;
                w = 24;
                x = 0;
                y = rowY;
              };
              panels =
                if collapsed
                then children.panels
                else [];
            };
          in {
            nextY =
              if collapsed
              then rowY + 1
              else children.nextY;
            inherit (children) nextId;
            panels =
              acc.panels
              ++ [rowDivider]
              ++ lib.optionals (!collapsed) children.panels;
          }
          else let
            res = layoutRow acc.nextY acc.nextId [sec];
          in {
            inherit (res) nextY nextId;
            panels = acc.panels ++ res.panels;
          }
      ) {
        nextY = 0;
        nextId = 1;
        panels = [];
      }
      sections;
  in
    {
      inherit uid title refresh;
      annotations.list = [
        {
          builtIn = 1;
          datasource = {
            type = "grafana";
            uid = "-- Grafana --";
          };
          enable = true;
          hide = true;
          iconColor = "rgba(0, 211, 255, 1)";
          name = "Annotations & Alerts";
          type = "dashboard";
        }
      ];
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 1;
      links =
        if links != null
        then links
        else defaultLinks;
      liveNow = false;
      inherit (assembled) panels;
      schemaVersion = 39;
      tags = lib.unique (["nixconf"] ++ tags);
      templating.list = variables;
      time = {
        from = timeFrom;
        to = timeTo;
      };
      timezone = "browser";
    }
    // lib.optionalAttrs (description != "") {inherit description;};
in {
  internal.monitoring.dashboard = {
    inherit mkRow mkSection mkDashboard;
  };
}
