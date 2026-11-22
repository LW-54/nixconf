{
  config,
  lib,
  ...
}: let
  d = config.internal.monitoring.dashboard;

  vars = {
    promQuery = {
      name,
      label ? name,
      query,
      includeAll ? true,
      multi ? true,
      allValue ? ".*",
      qryType ? 1,
      regex ? "",
      current ? null,
    }:
      {
        inherit name label includeAll multi;
        type = "query";
        datasource = d.ds.metrics;
        definition = query;
        query = {
          inherit qryType query;
        };
        refresh = 2;
        sort = 1;
        hide = 0;
        current =
          if current != null
          then {
            selected = true;
            inherit (current) text value;
          }
          else if includeAll
          then {
            selected = true;
            text = "All";
            value = "$__all";
          }
          else {};
      }
      // lib.optionalAttrs includeAll {inherit allValue;}
      // lib.optionalAttrs (regex != "") {inherit regex;};

    host = {
      label ? "Host",
      includeAll ? true,
      multi ? true,
    }:
      vars.promQuery {
        name = "host";
        inherit label includeAll multi;
        query = "label_values(node_uname_info, host)";
      };

    logsField = {
      name,
      label ? name,
      field ? name,
      query ? "",
      includeAll ? true,
      multi ? true,
      allValue ? "*",
    }:
      {
        inherit name label includeAll multi;
        type = "query";
        datasource = d.ds.logs;
        definition = "fieldValue:${field}";
        query =
          {
            type = "fieldValue";
            inherit field;
          }
          // lib.optionalAttrs (query != "") {inherit query;};
        refresh = 2;
        sort = 1;
        hide = 0;
        current =
          if includeAll
          then {
            selected = true;
            text = "All";
            value = "$__all";
          }
          else {};
      }
      // lib.optionalAttrs includeAll {inherit allValue;};

    custom = {
      name,
      label ? name,
      options,
      includeAll ? true,
      multi ? true,
      allValue ? ".*",
      current ? null,
    }: let
      normOpts =
        map (
          o:
            if builtins.isString o
            then {
              text = o;
              value = o;
            }
            else o
        )
        options;
      resolvedCurrent =
        if current != null
        then {
          selected = true;
          inherit (current) text value;
        }
        else if includeAll
        then {
          selected = true;
          text = "All";
          value = "$__all";
        }
        else {
          selected = true;
          inherit (builtins.head normOpts) text value;
        };
      renderedOpts =
        lib.optional includeAll {
          selected = resolvedCurrent.value == "$__all";
          text = "All";
          value = "$__all";
        }
        ++ map (o: {
          selected = resolvedCurrent.value == o.value;
          inherit (o) text value;
        })
        normOpts;
      queryStr = lib.concatStringsSep "," (map (
          o:
            if o.text == o.value
            then o.value
            else "${o.text} : ${o.value}"
        )
        normOpts);
    in
      {
        inherit name label includeAll multi;
        type = "custom";
        query = queryStr;
        options = renderedOpts;
        current = resolvedCurrent;
        hide = 0;
      }
      // lib.optionalAttrs includeAll {inherit allValue;};

    textbox = {
      name,
      label ? name,
      default ? "",
    }: {
      inherit name label;
      type = "textbox";
      hide = 0;
      query = default;
      current = {
        selected = true;
        text = default;
        value = default;
      };
      options = [
        {
          selected = true;
          text = default;
          value = default;
        }
      ];
    };
  };
in {
  internal.monitoring.dashboard.vars = vars;
}
