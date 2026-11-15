{
  internal.restic.mkTesting = {
    config,
    lib,
    jobs,
    restore,
  }: let
    cfg = config.backup;
    slices = config.storage.slices or {};

    missingSlices = builtins.filter (d: !(slices ? ${d.slice})) (builtins.attrValues cfg.destinations);

    invalidUnitDests = builtins.concatLists (lib.mapAttrsToList (
        uName: uCfg: let
          explicitDests =
            if uCfg.destinations != null
            then uCfg.destinations
            else [];
          referenced = lib.unique (explicitDests ++ builtins.attrNames uCfg.destinationOverrides);
          unknown = builtins.filter (d: !(cfg.destinations ? ${d})) referenced;
        in
          map (d: "${uName}.${d}") unknown
      )
      cfg.units);

    unregisteredActiveSlices =
      builtins.filter (s: !(builtins.elem s (config.storage.activeSlices or []))) jobs.activeSlices;

    emptyPruneJobs = builtins.attrNames (
      lib.filterAttrs (_: j: (j.pruneOpts or []) == []) jobs.jobs
    );
  in {
    description = "Multi-provider restic backup job, storage slice integration, retention policy, and boot-time restore checks";

    evalChecks = {
      valid-destination-slices = {
        assertion = missingSlices == [];
        message = "Backup destinations reference unknown storage slices: ${lib.concatMapStringsSep ", " (d: d.slice) missingSlices}.";
      };

      valid-unit-destinations = {
        assertion = invalidUnitDests == [];
        message = "Backup units reference unknown destinations: ${lib.concatStringsSep ", " invalidUnitDests}.";
      };

      active-slices-registered = {
        assertion = unregisteredActiveSlices == [];
        message = "Restic backup jobs require storage slices not registered in `storage.activeSlices`: ${lib.concatStringsSep ", " unregisteredActiveSlices}.";
      };

      non-empty-prune-opts = {
        assertion = emptyPruneJobs == [];
        message = "Restic backup jobs generated empty `pruneOpts`: ${lib.concatStringsSep ", " emptyPruneJobs}.";
      };
    };

    inspectChecks = {
      restore-units-generated = {
        description = "Verify restic backup services and boot-time restore units are generated";
        priority = 120;
        script =
          lib.concatLines (
            (map (uName: ''
              test -e "$etc/systemd/system/${uName}.service" || {
                echo "Missing generated restore unit: ${uName}.service" >&2
                exit 1
              }
            '') (builtins.attrNames restore.restoreServices))
            ++ (map (jName: ''
              test -e "$etc/systemd/system/restic-backups-${jName}.service" || {
                echo "Missing generated backup service: restic-backups-${jName}.service" >&2
                exit 1
              }
            '') (builtins.attrNames jobs.jobs))
          )
          + ''
            echo "Verified ${toString (builtins.length (builtins.attrNames jobs.jobs))} backup jobs and ${toString (builtins.length (builtins.attrNames restore.restoreServices))} restore units."
          '';
      };
    };
  };
}
