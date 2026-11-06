# Parallel documentation module for hosts: declares docs/hosts/README.md
# and each host instance (docs/hosts/<name>.md).
{lib, ...}: {
  docs = {config, ...}: {
    docs.pages =
      {
        hosts = {
          path = "docs/hosts/README.md";
          sections = {
            header = {
              order = 10;
              content = ctx: ''
                # Hosts

                Declarative target host definitions binding concrete hardware configurations, platform architectures, active implementations, and enabled system features into bootable NixOS systems.

                ${ctx.backTo "readme" "Main README"}
              '';
            };

            specification = {
              order = 15;
              content = ctx: ''
                ## Specification

                ${ctx.md.bullets [
                  "**Declared as**: `host.<name>` in any flake-parts module under `modules/hosts/`"
                  "**Primitive definition**: ${ctx.sourceLink "primitives/host/default.nix"}"
                  "**Instances**: ${toString (builtins.length (builtins.attrNames (config.host or {})))}"
                ]}
              '';
            };

            schema = {
              order = 20;
              content = ctx: ''
                ## Option Schema (`host.<name>`)

                ${ctx.schemaOptionsTable "host"}
              '';
            };

            example = {
              order = 30;
              content = ctx: ctx.exampleBlock "host";
            };

            catalog = {
              order = 50;
              content = ctx: ''
                ## Catalog

                ${ctx.md.table {
                  headers = ["Host" "Description" "System" "Definition" "Docs"];
                  columns = [
                    (name: ctx.instanceLink "host" name)
                    (name: ctx.md.oneLine (config.host.${name}.description or ""))
                    (name: "`${config.host.${name}.system or "x86_64-linux"}`")
                    (name: ctx.sourceLink (ctx.sourceOf "host" name))
                    (name: ctx.moreLink "host" name)
                  ];
                  rows = builtins.attrNames (config.host or {});
                }}
              '';
            };
          };
        };
      }
      // (lib.mapAttrs' (name: host:
        lib.nameValuePair "hosts/${name}" {
          path = "docs/hosts/${name}.md";
          sections = {
            header = {
              order = 10;
              content = ctx: ''
                # Host: `${name}`

                ${host.description or ""}

                ${ctx.backTo "hosts" "Hosts Documentation"} | ${ctx.backTo "readme" "Main README"}

                - **Host**: `${name}`
                - **System**: `${host.system or "x86_64-linux"}`
                - **State Version**: `${ctx.query.eval name ["system" "stateVersion"] (host.stateVersion or "25.11")}`
                - **Definition File**: ${ctx.sourceLink (ctx.sourceOf "host" name)}
              '';
            };

            diagram = {
              order = 20;
              content = ctx: ctx.neighborhoodDiagram {nodeId = "urn:nixconf:eval:configuration:${name}";};
            };

            contracts = {
              order = 30;
              content = ctx: let
                contracts = ctx.activeContracts name;
              in
                if contracts == []
                then null
                else ''
                  ## Active Contracts

                  The following contracts are materialized on `${name}` through its active implementation providers:

                  ${ctx.md.table {
                    headers = ["Contract" "Contract Description" "Implementation" "Implementation Description" "Docs"];
                    columns = [
                      (c: ctx.instanceLink "contract" c.contract)
                      (c: ctx.md.oneLine (c.contractDescription or ""))
                      (c: ctx.instanceLink "implementation" c.implementation)
                      (c: ctx.md.oneLine (c.implementationDescription or ""))
                      (c: ctx.moreLink "contract" c.contract)
                    ];
                    rows = contracts;
                  }}
                '';
            };

            features = {
              order = 35;
              content = ctx: let
                feats = ctx.enabledFeatures name;

                formatFeatureOutputs = featName: let
                  isFromFeat = n:
                    (n.origin.primitive or null)
                    == "feature"
                    && (n.origin.instance or null) == featName;

                  featMods = lib.filter isFromFeat (ctx.nodes "module");
                  featPkgs = lib.filter isFromFeat (ctx.nodes "package");

                  modLinks = map (m: "[`${m.name}`](${ctx.link "docs/modules/${m.name}.md"}) (module)") featMods;
                  pkgLinks = map (p: "[`${p.name}`](${ctx.link "docs/packages.md"}#${p.name}) (package)") featPkgs;

                  all = modLinks ++ pkgLinks;
                in
                  if all == []
                  then "—"
                  else lib.concatStringsSep ", " all;
              in
                if feats == []
                then null
                else ''
                  ## Enabled Features

                  The following system and desktop features are imported by `${name}`:

                  ${ctx.md.table {
                    headers = ["Feature" "Description" "Outputs Used" "Docs"];
                    columns = [
                      (f: ctx.instanceLink "feature" f.name)
                      (f: ctx.md.oneLine f.description)
                      (f: formatFeatureOutputs f.name)
                      (f: ctx.moreLink "feature" f.name)
                    ];
                    rows = feats;
                  }}
                '';
            };

            modules = {
              order = 40;
              content = ctx: let
                subs = ctx.hostSubModules name;
              in
                if subs == []
                then null
                else ''
                  ## Host Submodules

                  Host-specific configuration submodules partitioning hardware, disks, and local system services:

                  ${ctx.md.blocks (map (
                      sub:
                        ctx.md.details "<code><a href=\"../modules/${sub.name}.md\">${sub.name}</a></code>" (ctx.md.code "nix" (sub.code or ""))
                    )
                    subs)}
                '';
            };

            consumedContracts = {
              order = 70;
              content = ctx: let
                node = ctx.instanceNode "host" name;
                edges =
                  if node == null
                  then []
                  else lib.filter (e: e.source == node.id && lib.toUpper (e.relation or "") == "CONSUMES") ctx.graph.edges;
                grouped = lib.groupBy (e: e.target) edges;
                optionsOf = otherId: lib.unique (lib.filter (o: o != null) (map (e: e.qualifier or (e.properties.optionWritten or null)) grouped.${otherId}));

                hostFile = ctx.sourceOf "host" name;

                renderConsumedContract = otherId: let
                  cNode = ctx.graph.nodes.${otherId} or null;
                  cName =
                    if cNode != null
                    then cNode.name
                    else lib.last (lib.splitString ":" otherId);
                  opts = optionsOf otherId;
                  optsStr =
                    if opts != []
                    then lib.concatStringsSep ", " (map (o: "`${o}`") opts)
                    else "*general contract configuration*";

                  codeSnippet = ctx.targetedSnippet {
                    file = hostFile;
                    options = opts;
                    terms = ["${cName}." "${cName} ="];
                    hostName = name;
                  };
                in ''
                  <details>
                  <summary><code><a href="../contracts/${cName}.md">${cName}</a></code></summary>

                  **Configures options**: ${optsStr}

                  ```nix
                  ${codeSnippet}
                  ```

                  </details>
                '';
              in
                if edges == []
                then null
                else ''
                  ## Consumed Contracts

                  Capability contracts configured by `${name}`:

                  ${lib.concatMapStringsSep "\n\n" renderConsumedContract (builtins.attrNames grouped)}
                '';
            };

            installation = {
              order = 90;
              content = ctx: ''
                ## Installation & Deployment

                ### Track 1: Remote Automated Provisioning (`nixos-anywhere`)

                For remote servers or headless machines booted into a live environment:

                ```bash
                # Remote deployment over SSH with SOPS secret key copy
                nix run github:nix-community/nixos-anywhere -- \
                  --flake .#${name} \
                  --copy-secret /path/to/host-key.txt /persist/var/lib/sops-nix/key.txt \
                  root@<TARGET-IP>
                ```

                ### Track 2: Local Installation from Live ISO

                For physical machines booted from a NixOS Live ISO installer drive:

                ```bash
                # 1. Elevate to root in the live environment
                sudo -i

                # 2. Clone repository to live memory
                git clone ${config.docs.project.url} /tmp/nixconf
                cd /tmp/nixconf

                # 3. Format disk and mount partitions declaratively via Disko
                nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- \
                  --mode zap_create_mount \
                  --flake .#${name}

                # 4. Provision SOPS age secret key on mounted persistence volume
                install -d -m 0700 /mnt/persist/var/lib/sops-nix
                install -m 0400 /path/to/host-key.txt /mnt/persist/var/lib/sops-nix/key.txt

                # 5. Install NixOS to target disk and reboot
                nixos-install --flake .#${name} --no-root-passwd
                reboot
                ```

                ### Track 3: Routine Maintenance & System Rebuilds

                ```bash
                # Local rebuild and switch on running system
                sudo nixos-rebuild switch --flake .#${name}

                # Remote rebuild over SSH from a management machine
                nixos-rebuild switch --flake .#${name} --target-host root@<TARGET-IP>
                ```
              '';
            };
          };
        })
      (config.host or {}));
  };
}
