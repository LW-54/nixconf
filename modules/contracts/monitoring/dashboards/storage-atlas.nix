{config, ...}: let
  d = config.internal.monitoring.dashboard;

  # Deduplicated local filesystems (excludes impermanence btrfs bind-mount duplicates and podman shm mounts while keeping / or /persist and loopback volumes).
  fsSize = ''(node_filesystem_size_bytes{host=~"$host",fstype!~"btrfs|ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var/run|run|sys|proc|dev).*|.*overlay-containers.*"} or node_filesystem_size_bytes{host=~"$host",fstype="btrfs",mountpoint=~"/|/persist"})'';
  fsAvail = ''(node_filesystem_avail_bytes{host=~"$host",fstype!~"btrfs|ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var/run|run|sys|proc|dev).*|.*overlay-containers.*"} or node_filesystem_avail_bytes{host=~"$host",fstype="btrfs",mountpoint=~"/|/persist"})'';
  fsUsed = ''(${fsSize} - ${fsAvail})'';

  sharedTargets = [
    # A: Local filesystems used bytes
    (d.promTarget {
      refId = "A";
      expr = ''max by (host, mountpoint, fstype) (${fsUsed})'';
      instant = true;
      format = "table";
    })
    # B: Local filesystems total bytes
    (d.promTarget {
      refId = "B";
      expr = ''max by (host, mountpoint, fstype) (${fsSize})'';
      instant = true;
      format = "table";
    })
    # C: Local filesystems growth (bytes/day over $window)
    (d.promTarget {
      refId = "C";
      expr = ''max by (host, mountpoint) (deriv(${fsUsed}[$window:])) * 86400'';
      instant = true;
      format = "table";
    })
    # D: Remote storage slices used bytes
    (d.promTarget {
      refId = "D";
      expr = ''max by (host, provider, slice, scope) (nixconf_storage_budget_used_bytes{host=~"$host"})'';
      instant = true;
      format = "table";
    })
    # E: Remote storage slices limit bytes
    (d.promTarget {
      refId = "E";
      expr = ''max by (host, provider, slice, scope) (nixconf_storage_budget_limit_bytes{host=~"$host"})'';
      instant = true;
      format = "table";
    })
    # F: Remote storage slices growth (bytes/day over $window)
    (d.promTarget {
      refId = "F";
      expr = ''max by (host, provider, slice) (deriv(nixconf_storage_budget_used_bytes{host=~"$host"}[$window:])) * 86400'';
      instant = true;
      format = "table";
    })
    # G: Directory & service tree scanner bytes
    (d.promTarget {
      refId = "G";
      expr = ''max by (host, category, service, path, parent, depth) (nixconf_storage_dir_bytes{host=~"$host"})'';
      instant = true;
      format = "table";
    })
    # H: Directory & service tree growth (bytes/day over $window)
    (d.promTarget {
      refId = "H";
      expr = ''max by (host, path) (deriv(nixconf_storage_dir_bytes{host=~"$host"}[$window:])) * 86400'';
      instant = true;
      format = "table";
    })
  ];

  mkTreemapScript = forcedView: ''
    const viewMode = ${
      if forcedView != null
      then builtins.toJSON forcedView
      else ''(context.grafana.replaceVariables('$view') || 'fleet')''
    };
    const colorMode = context.grafana.replaceVariables('$color_mode') || 'growth';
    const isDark = !context.grafana.theme || context.grafana.theme.isDark !== false;
    const textColor = isDark ? '#e2e8f0' : '#0f172a';
    const borderColor = isDark ? '#0f172a' : '#ffffff';
    const headerBg = isDark ? '#1e293b' : '#e2e8f0';

    const colVals = (f) => {
      if (!f || !f.values) return [];
      if (Array.isArray(f.values)) return f.values;
      if (typeof f.values.toArray === 'function') return f.values.toArray();
      if (f.values.buffer) return Array.from(f.values.buffer);
      const out = [];
      for (let i = 0; i < (f.values.length || 0); i++) {
        out.push(typeof f.values.get === 'function' ? f.values.get(i) : f.values[i]);
      }
      return out;
    };

    const readTable = (refId) => {
      const frame = (context.panel.data.series || []).find((s) => s.refId === refId);
      if (!frame || !frame.fields || frame.fields.length === 0) return [];
      const cols = frame.fields.map((f) => ({ name: f.name, type: f.type, vals: colVals(f) }));
      const numCol = cols.filter((c) => c.type === 'number' && c.name !== 'Time').slice(-1)[0];
      if (!numCol) return [];
      const rows = [];
      for (let i = 0; i < numCol.vals.length; i++) {
        const v = Number(numCol.vals[i]);
        if (!Number.isFinite(v)) continue;
        const row = { value: v };
        for (const c of cols) {
          if (c.type === 'string') row[c.name] = String(c.vals[i] ?? "");
        }
        rows.push(row);
      }
      return rows;
    };

    const fmtBytes = (b) => {
      const sign = b < 0 ? '-' : "";
      let n = Math.abs(Number(b) || 0);
      const units = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB'];
      let u = 0;
      while (n >= 1024 && u < units.length - 1) { n /= 1024; u++; }
      return sign + (n >= 100 || u === 0 ? n.toFixed(0) : n >= 10 ? n.toFixed(1) : n.toFixed(2)) + ' ' + units[u];
    };

    const fmtSignedGrowth = (g) => {
      if (!Number.isFinite(g) || Math.abs(g) < 1024) return '0 B/d';
      return (g > 0 ? '+' : "") + fmtBytes(g) + '/d';
    };

    const inferProvider = (row) => {
      if (row.provider && row.provider !== "" && row.provider !== 'unknown') return row.provider;
      const s = row.slice || "";
      if (s.startsWith('hbox')) return 'hbox';
      if (s.startsWith('gdrive')) return 'gdrive';
      if (s.startsWith('b2')) return 'b2';
      if (s === 'uchiyomi' || s === 'copyparty') return 'hbox';
      return 'remote';
    };

    const normalizeService = (raw) => {
      const s = String(raw || 'other');
      if (s === 'authelia-main') return 'authelia';
      if (s === 'ntfy-sh') return 'ntfy';
      if (s.startsWith('restic-backups-') || s.startsWith('host-snapshot-') || s === 'nixconf-backup' || s.includes('-backup-')) return 'backups';
      return s;
    };

    const fsUsedRows = readTable('A');
    const fsSizeMap = new Map(readTable('B').map((r) => [r.host + '|' + r.mountpoint, r.value]));
    const fsGrowthMap = new Map(readTable('C').map((r) => [r.host + '|' + r.mountpoint, r.value]));

    const remUsedRows = readTable('D');
    const remLimitMap = new Map(readTable('E').map((r) => [r.host + '|' + inferProvider(r) + '|' + r.slice, r.value]));
    const remGrowthMap = new Map(readTable('F').map((r) => [r.host + '|' + inferProvider(r) + '|' + r.slice, r.value]));

    const dirRows = readTable('G');
    const dirGrowthMap = new Map(readTable('H').map((r) => [r.host + '|' + r.path, r.value]));

    // Palette for categorical WizTree mode
    const catColors = {
      local: '#2563eb',
      hbox: '#7c3aed',
      gdrive: '#059669',
      b2: '#d97706',
      remote: '#6366f1',
      service_state: '#0891b2',
      service_cache: '#ea580c',
      system: '#4f46e5',
      home: '#db2777',
      logs: '#0d9488',
      reserved: '#64748b',
      backups: '#8b5cf6',
      uchiyomi: '#e11d48',
      victoriametrics: '#0284c7',
      victorialogs: '#0369a1',
      containers: '#2563eb',
      grafana: '#f59e0b',
      'nix-store': '#4f46e5',
      copyparty: '#10b981',
      alloy: '#14b8a6',
    };
    const fallbackPalette = ['#2563eb', '#7c3aed', '#059669', '#d97706', '#0891b2', '#db2777', '#4f46e5', '#ea580c', '#0d9488', '#6366f1'];
    const hashColor = (key) => {
      if (catColors[key]) return catColors[key];
      let h = 0;
      for (let i = 0; i < key.length; i++) h = ((h << 5) - h + key.charCodeAt(i)) | 0;
      return fallbackPalette[Math.abs(h) % fallbackPalette.length];
    };

    const pickColor = (meta, groupKey) => {
      if (colorMode === 'growth') {
        const g = meta.growthDay || 0;
        if (g < -10 * 1048576) return '#15803d';
        if (g < -1048576) return '#166534';
        if (g <= 1048576) return isDark ? '#334155' : '#64748b';
        if (g <= 25 * 1048576) return '#a16207';
        if (g <= 100 * 1048576) return '#c2410c';
        if (g <= 500 * 1048576) return '#dc2626';
        return '#991b1b';
      }
      if (colorMode === 'usage') {
        if (!Number.isFinite(meta.usagePct)) return isDark ? '#334155' : '#64748b';
        if (meta.usagePct >= 90) return '#b91c1c';
        if (meta.usagePct >= 80) return '#dc2626';
        if (meta.usagePct >= 65) return '#d97706';
        if (meta.usagePct >= 45) return '#0369a1';
        return '#0f766e';
      }
      return hashColor(groupKey || meta.groupKey || 'local');
    };

    const mkLeaf = (name, bytes, meta, groupKey) => ({
      name,
      value: Math.max(bytes, 1),
      rawBytes: bytes,
      meta: { ...meta, groupKey: groupKey || meta.groupKey || name },
      itemStyle: { color: pickColor(meta, groupKey) },
    });

    // Compute per-host loopback ext4 volume sum so /persist isn't double-counted in fleet/provider views.
    const loopVolSumByHost = new Map();
    for (const r of fsUsedRows) {
      if (r.fstype === 'ext4' && (r.mountpoint.startsWith('/var/') || r.mountpoint.startsWith('/persist/'))) {
        loopVolSumByHost.set(r.host, (loopVolSumByHost.get(r.host) || 0) + r.value);
      }
    }

    const pushGroup = (map, key, label) => {
      if (!map.has(key)) map.set(key, { name: label || key, children: [] });
      return map.get(key);
    };

    // Build nested directory tree for a set of nixconf_storage_dir_bytes rows without double-counting parent vs children.
    const buildDirSubtree = (rows, host) => {
      const byCat = new Map();
      const depth1 = rows.filter((r) => r.depth === '1');
      const depth2ByParent = new Map();
      for (const r of rows) {
        if (r.depth === '2') {
          const list = depth2ByParent.get(r.parent) || [];
          list.push(r);
          depth2ByParent.set(r.parent, list);
        }
      }
      for (const d1 of depth1) {
        if (d1.value <= 0) continue;
        const catGroup = pushGroup(byCat, d1.category || 'system', d1.category || 'system');
        const kids = (depth2ByParent.get(d1.path) || []).filter((k) => k.value > 0);
        const d1Growth = dirGrowthMap.get(host + '|' + d1.path) || 0;
        if (kids.length === 0) {
          catGroup.children.push(
            mkLeaf(d1.path, d1.value, {
              kind: 'Directory',
              host,
              provider: 'local',
              fullPath: d1.path,
              growthDay: d1Growth,
            }, d1.category)
          );
        } else {
          let kidSum = 0;
          const kidNodes = kids.map((k) => {
            kidSum += k.value;
            const kGrowth = dirGrowthMap.get(host + '|' + k.path) || 0;
            const shortName = k.path.replace(d1.path + '/', "");
            return mkLeaf(shortName, k.value, {
              kind: 'Directory',
              host,
              provider: 'local',
              fullPath: k.path,
              growthDay: kGrowth,
            }, d1.category);
          });
          const rem = d1.value - kidSum;
          if (rem > 1048576) {
            kidNodes.push(
              mkLeaf('(files & small dirs)', rem, {
                kind: 'Directory remainder',
                host,
                provider: 'local',
                fullPath: d1.path + '/*',
                growthDay: 0,
              }, d1.category)
            );
          }
          catGroup.children.push({
            name: d1.path,
            children: kidNodes,
          });
        }
      }
      return Array.from(byCat.values()).filter((g) => g.children.length > 0);
    };

    let treeData = [];

    if (viewMode === 'fleet') {
      const byHost = new Map();
      for (const r of fsUsedRows) {
        if (r.value <= 0) continue;
        const hostNode = pushGroup(byHost, r.host, r.host);
        let localNode = hostNode.children.find((c) => c.name === 'local');
        if (!localNode) {
          localNode = { name: 'local', children: [] };
          hostNode.children.push(localNode);
        }
        const total = fsSizeMap.get(r.host + '|' + r.mountpoint);
        const growth = fsGrowthMap.get(r.host + '|' + r.mountpoint) || 0;
        let bytes = r.value;
        let label = r.mountpoint;
        if (r.mountpoint === '/persist') {
          const volSum = loopVolSumByHost.get(r.host) || 0;
          bytes = Math.max(r.value - volSum, 1);
          if (volSum > 0) label = '/persist (base)';
        }
        const usagePct = total > 0 ? (r.value / total) * 100 : NaN;
        localNode.children.push(
          mkLeaf(label, bytes, {
            kind: 'Local FS (' + r.fstype + ')',
            host: r.host,
            provider: 'local',
            fullPath: r.host + ':' + r.mountpoint,
            limit: total,
            usagePct,
            growthDay: growth,
          }, 'local')
        );
      }
      for (const r of remUsedRows) {
        if (r.value <= 0) continue;
        const prov = inferProvider(r);
        const hostNode = pushGroup(byHost, r.host, r.host);
        let provNode = hostNode.children.find((c) => c.name === prov);
        if (!provNode) {
          provNode = { name: prov, children: [] };
          hostNode.children.push(provNode);
        }
        const limit = remLimitMap.get(r.host + '|' + prov + '|' + r.slice);
        const growth = remGrowthMap.get(r.host + '|' + prov + '|' + r.slice) || 0;
        const usagePct = limit > 0 ? (r.value / limit) * 100 : NaN;
        provNode.children.push(
          mkLeaf(r.slice, r.value, {
            kind: 'Remote Slice (' + (r.scope || 'shared') + ')',
            host: r.host,
            provider: prov,
            fullPath: prov + ':' + r.slice,
            limit,
            usagePct,
            growthDay: growth,
          }, prov)
        );
      }
      treeData = Array.from(byHost.values());
    } else if (viewMode === 'provider') {
      const byProv = new Map();
      // Local filesystems grouped under local -> host
      for (const r of fsUsedRows) {
        if (r.value <= 0) continue;
        const provNode = pushGroup(byProv, 'local', 'local (disks & volumes)');
        let hostNode = provNode.children.find((c) => c.name === r.host);
        if (!hostNode) {
          hostNode = { name: r.host, children: [] };
          provNode.children.push(hostNode);
        }
        const total = fsSizeMap.get(r.host + '|' + r.mountpoint);
        const growth = fsGrowthMap.get(r.host + '|' + r.mountpoint) || 0;
        let bytes = r.value;
        let label = r.mountpoint;
        if (r.mountpoint === '/persist') {
          const volSum = loopVolSumByHost.get(r.host) || 0;
          bytes = Math.max(r.value - volSum, 1);
          if (volSum > 0) label = '/persist (base)';
        }
        const usagePct = total > 0 ? (r.value / total) * 100 : NaN;
        hostNode.children.push(
          mkLeaf(label, bytes, {
            kind: 'Local FS (' + r.fstype + ')',
            host: r.host,
            provider: 'local',
            fullPath: r.host + ':' + r.mountpoint,
            limit: total,
            usagePct,
            growthDay: growth,
          }, 'local')
        );
      }
      // Deduplicate shared remote slices across hosts by taking max per (provider, slice)
      const dedupRemote = new Map();
      for (const r of remUsedRows) {
        if (r.value <= 0) continue;
        const prov = inferProvider(r);
        const key = (r.scope === 'per-host') ? (prov + '|' + r.host + '|' + r.slice) : (prov + '|shared|' + r.slice);
        const prev = dedupRemote.get(key);
        if (!prev || r.value > prev.value) dedupRemote.set(key, { ...r, prov });
      }
      for (const r of dedupRemote.values()) {
        const provNode = pushGroup(byProv, r.prov, r.prov);
        const limit = remLimitMap.get(r.host + '|' + r.prov + '|' + r.slice);
        const growth = remGrowthMap.get(r.host + '|' + r.prov + '|' + r.slice) || 0;
        const usagePct = limit > 0 ? (r.value / limit) * 100 : NaN;
        const label = r.scope === 'per-host' ? (r.slice + ' (' + r.host + ')') : r.slice;
        provNode.children.push(
          mkLeaf(label, r.value, {
            kind: 'Remote Slice (' + (r.scope || 'shared') + ')',
            host: r.host,
            provider: r.prov,
            fullPath: r.prov + ':' + r.slice,
            limit,
            usagePct,
            growthDay: growth,
          }, r.prov)
        );
      }
      treeData = Array.from(byProv.values());
    } else if (viewMode === 'service') {
      const byService = new Map();
      // Local service state/cache/system from directory scanner (depth=1 avoids double-counting)
      for (const r of dirRows) {
        if (r.depth !== '1' || r.value <= 0) continue;
        const svc = normalizeService(r.service);
        const svcNode = pushGroup(byService, svc, svc);
        const growth = dirGrowthMap.get(r.host + '|' + r.path) || 0;
        svcNode.children.push(
          mkLeaf(r.host + ' · ' + r.path, r.value, {
            kind: 'Local (' + r.category + ')',
            host: r.host,
            provider: 'local',
            fullPath: r.host + ':' + r.path,
            growthDay: growth,
          }, svc)
        );
      }
      // Fallback to loopback volumes if directory scanner has not run yet
      if (dirRows.length === 0) {
        for (const r of fsUsedRows) {
          if (r.value <= 0) continue;
          const rawName = r.mountpoint.replace(/^\/var\/(lib|cache)\//, "").replace(/^\//, "") || 'root';
          const svc = normalizeService(rawName);
          const svcNode = pushGroup(byService, svc, svc);
          const total = fsSizeMap.get(r.host + '|' + r.mountpoint);
          const growth = fsGrowthMap.get(r.host + '|' + r.mountpoint) || 0;
          svcNode.children.push(
            mkLeaf(r.host + ' · ' + r.mountpoint, r.value, {
              kind: 'Local FS (' + r.fstype + ')',
              host: r.host,
              provider: 'local',
              fullPath: r.host + ':' + r.mountpoint,
              limit: total,
              usagePct: total > 0 ? (r.value / total) * 100 : NaN,
              growthDay: growth,
            }, svc)
          );
        }
      }
      // Remote storage slices mapped into their owning service
      const seenRemote = new Set();
      for (const r of remUsedRows) {
        if (r.value <= 0) continue;
        const prov = inferProvider(r);
        const dedupKey = (r.scope === 'per-host') ? (r.host + '|' + prov + '|' + r.slice) : (prov + '|' + r.slice);
        if (seenRemote.has(dedupKey)) continue;
        seenRemote.add(dedupKey);
        const svc = normalizeService(r.slice);
        const svcNode = pushGroup(byService, svc, svc);
        const limit = remLimitMap.get(r.host + '|' + prov + '|' + r.slice);
        const growth = remGrowthMap.get(r.host + '|' + prov + '|' + r.slice) || 0;
        svcNode.children.push(
          mkLeaf('remote · ' + prov + ':' + r.slice, r.value, {
            kind: 'Remote Slice (' + (r.scope || 'shared') + ')',
            host: r.host,
            provider: prov,
            fullPath: prov + ':' + r.slice,
            limit,
            usagePct: limit > 0 ? (r.value / limit) * 100 : NaN,
            growthDay: growth,
          }, svc)
        );
      }
      treeData = Array.from(byService.values());
    } else {
      // WizTree Directory breakdown: Host -> Category -> Top Dir -> Subdirs
      const hosts = Array.from(new Set(dirRows.map((r) => r.host)));
      if (hosts.length > 0) {
        treeData = hosts.map((h) => ({
          name: h,
          children: buildDirSubtree(dirRows.filter((r) => r.host === h), h),
        }));
      } else {
        // Graceful fallback before first scan runs: show local filesystems
        const byHost = new Map();
        for (const r of fsUsedRows) {
          if (r.value <= 0) continue;
          const hostNode = pushGroup(byHost, r.host, r.host);
          const total = fsSizeMap.get(r.host + '|' + r.mountpoint);
          const growth = fsGrowthMap.get(r.host + '|' + r.mountpoint) || 0;
          hostNode.children.push(
            mkLeaf(r.mountpoint, r.value, {
              kind: 'Local FS (awaiting first directory scan)',
              host: r.host,
              provider: 'local',
              fullPath: r.host + ':' + r.mountpoint,
              limit: total,
              usagePct: total > 0 ? (r.value / total) * 100 : NaN,
              growthDay: growth,
            }, 'local')
          );
        }
        treeData = Array.from(byHost.values());
      }
    }

    // Recursively roll up totals & growth so parent tooltips and percentage shares are exact.
    const finalizeNode = (node) => {
      if (!node.children || node.children.length === 0) {
        return {
          bytes: node.rawBytes ?? node.value ?? 0,
          growth: (node.meta && Number.isFinite(node.meta.growthDay)) ? node.meta.growthDay : 0,
        };
      }
      let sumB = 0;
      let sumG = 0;
      for (const c of node.children) {
        const res = finalizeNode(c);
        sumB += res.bytes;
        sumG += res.growth;
      }
      node.rawBytes = sumB;
      node.meta = { ...(node.meta || {}), growthDay: sumG };
      return { bytes: sumB, growth: sumG };
    };
    let grandTotal = 0;
    for (const root of treeData) {
      grandTotal += finalizeNode(root).bytes;
    }

    return {
      backgroundColor: 'transparent',
      tooltip: {
        confine: true,
        backgroundColor: isDark ? 'rgba(15, 23, 42, 0.95)' : 'rgba(255, 255, 255, 0.96)',
        borderColor: isDark ? '#334155' : '#cbd5e1',
        textStyle: { color: textColor, fontSize: 12 },
        formatter: (info) => {
          const d = info.data || {};
          const m = d.meta || {};
          const bytes = Number(d.rawBytes ?? info.value ?? 0);
          const pathNames = (info.treePathInfo || []).slice(1).map((p) => p.name);
          const parentInfo = info.treePathInfo && info.treePathInfo.length >= 2
            ? info.treePathInfo[info.treePathInfo.length - 2]
            : null;
          const parentVal = parentInfo ? Number(parentInfo.value || 0) : grandTotal;
          const pctParent = parentVal > 0 ? ((bytes / parentVal) * 100).toFixed(1) : '100.0';
          const pctTotal = grandTotal > 0 ? ((bytes / grandTotal) * 100).toFixed(1) : '100.0';
          const lines = [
            '<div style="font-weight:700;margin-bottom:4px">' + pathNames.join(' / ') + '</div>',
            '<div>Size: <b>' + fmtBytes(bytes) + '</b> (' + pctParent + '% of parent · ' + pctTotal + '% of view)</div>',
          ];
          if (m.kind) lines.push('<div>Type: ' + m.kind + '</div>');
          if (Number.isFinite(m.limit) && m.limit > 0) {
            lines.push('<div>Capacity: ' + fmtBytes(m.limit) + ' (' + (m.usagePct || 0).toFixed(1) + '% used)</div>');
          }
          if (Number.isFinite(m.growthDay)) {
            lines.push('<div>Growth / Day: <b>' + fmtSignedGrowth(m.growthDay) + '</b></div>');
          }
          return lines.join("");
        },
      },
      series: [
        {
          name: 'Storage (' + fmtBytes(grandTotal) + ')',
          type: 'treemap',
          roam: false,
          nodeClick: 'zoomToNode',
          width: '100%',
          height: '92%',
          top: 4,
          bottom: 34,
          squareRatio: 0.72,
          visibleMin: 220,
          childrenVisibleMin: 400,
          breadcrumb: {
            show: true,
            bottom: 4,
            height: 24,
            itemStyle: {
              color: headerBg,
              borderColor: isDark ? '#334155' : '#cbd5e1',
              borderWidth: 1,
              textStyle: { color: textColor, fontSize: 12 },
            },
          },
          label: {
            show: true,
            color: '#f8fafc',
            fontSize: 11,
            lineHeight: 15,
            overflow: 'truncate',
            formatter: (params) => {
              const d = params.data || {};
              const m = d.meta || {};
              const bytes = Number(d.rawBytes ?? params.value ?? 0);
              const sizeStr = fmtBytes(bytes);
              if (colorMode === 'growth' && Number.isFinite(m.growthDay) && Math.abs(m.growthDay) >= 1024) {
                return d.name + '\n' + sizeStr + '\n' + fmtSignedGrowth(m.growthDay);
              }
              if (colorMode === 'usage' && Number.isFinite(m.usagePct)) {
                return d.name + '\n' + sizeStr + ' (' + m.usagePct.toFixed(0) + '%)';
              }
              return d.name + '\n' + sizeStr;
            },
          },
          upperLabel: {
            show: true,
            height: 22,
            color: textColor,
            fontWeight: 600,
            fontSize: 11,
            padding: [2, 6],
            formatter: (params) => {
              const d = params.data || {};
              const bytes = Number(d.rawBytes ?? params.value ?? 0);
              return d.name + '  (' + fmtBytes(bytes) + ')';
            },
          },
          itemStyle: {
            borderColor: borderColor,
            borderWidth: 1,
            gapWidth: 1,
          },
          levels: [
            {
              itemStyle: {
                borderColor: isDark ? '#334155' : '#94a3b8',
                borderWidth: 2,
                gapWidth: 3,
              },
              upperLabel: {
                show: true,
                backgroundColor: headerBg,
              },
            },
            {
              itemStyle: {
                borderColor: isDark ? '#1e293b' : '#cbd5e1',
                borderWidth: 2,
                gapWidth: 2,
              },
              upperLabel: {
                show: true,
                backgroundColor: isDark ? '#172033' : '#f1f5f9',
              },
            },
            {
              itemStyle: {
                borderColor: borderColor,
                borderWidth: 1,
                gapWidth: 1,
              },
            },
          ],
          data: treeData,
        },
      ],
    };
  '';
in {
  internal.monitoring.dashboard.mkStorageAtlasDashboard = _:
    d.mkDashboard {
      uid = "nixconf-storage-atlas";
      title = "Storage Atlas (Treemap)";
      description = "Interactive WizTree & stock-market heatmap visualization of storage across hosts, storage providers (local, hbox, gdrive, b2), services, and local directory trees. Click any rectangle to zoom in and use breadcrumbs to navigate back.";
      tags = ["storage" "treemap" "wiztree" "disk" "providers" "capacity"];
      refresh = "1m";
      timeFrom = "now-7d";
      graphTooltip = 0;
      variables = [
        (d.vars.host {})
        (d.vars.custom {
          name = "view";
          label = "Hierarchy";
          includeAll = false;
          multi = false;
          current = {
            text = "All (Host → Provider → Slice/FS)";
            value = "fleet";
          };
          options = [
            {
              text = "All (Host → Provider → Slice/FS)";
              value = "fleet";
            }
            {
              text = "By Storage Provider (local / hbox / gdrive / b2)";
              value = "provider";
            }
            {
              text = "By Service (Local State + Cache + Remote)";
              value = "service";
            }
            {
              text = "By Directory (WizTree Local Tree)";
              value = "directory";
            }
          ];
        })
        (d.vars.custom {
          name = "color_mode";
          label = "Color Mode";
          includeAll = false;
          multi = false;
          current = {
            text = "Stock Market Heatmap (Growth / Day)";
            value = "growth";
          };
          options = [
            {
              text = "Stock Market Heatmap (Growth / Day)";
              value = "growth";
            }
            {
              text = "Capacity Pressure (Usage %)";
              value = "usage";
            }
            {
              text = "WizTree Category Palette";
              value = "category";
            }
          ];
        })
        (d.vars.custom {
          name = "window";
          label = "Growth Window";
          includeAll = false;
          multi = false;
          current = {
            text = "7d";
            value = "7d";
          };
          options = ["24h" "7d" "30d"];
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Local /persist & Root Used";
            w = 5;
            unit = "bytes";
            decimals = 1;
            expr = ''sum(max by (host, mountpoint) (node_filesystem_size_bytes{host=~"$host",mountpoint=~"/|/persist"} - node_filesystem_avail_bytes{host=~"$host",mountpoint=~"/|/persist"}))'';
            legend = "Local Used";
          })
          (d.mkStat {
            title = "Remote Storage Used";
            w = 5;
            unit = "bytes";
            decimals = 1;
            noValue = "0 B";
            expr = ''sum(max by (slice) (nixconf_storage_budget_used_bytes{host=~"$host"}))'';
            legend = "Remote Used";
          })
          (d.mkStat {
            title = "Remote Budget Headroom";
            w = 5;
            unit = "bytes";
            decimals = 1;
            noValue = "—";
            expr = ''sum(max by (slice) (clamp_min(nixconf_storage_budget_limit_bytes{host=~"$host"} - nixconf_storage_budget_used_bytes{host=~"$host"}, 0)))'';
            legend = "Free Budget";
          })
          (d.mkStat {
            title = "Largest Local Directory";
            w = 5;
            unit = "bytes";
            decimals = 1;
            noValue = "Scanning…";
            expr = ''max(nixconf_storage_dir_bytes{host=~"$host",depth="1"})'';
            legend = "Top Dir";
          })
          (d.mkStat {
            title = "Net Local Growth ($window)";
            w = 4;
            unit = "bytes";
            decimals = 1;
            description = "Combined daily local disk growth (bytes/day) over $window.";
            expr = ''sum(max by (host, mountpoint) (deriv((node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"} - node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"})[$window:])) * 86400)'';
            legend = "B / day";
          })
        ])
        (d.mkRow [
          (d.mkEcharts {
            title = "Interactive Storage Treemap — $view ($color_mode)";
            description = "Click any rectangle to zoom into nested providers, services, or subdirectories. Use the breadcrumb bar at the bottom to step back up. Switch Hierarchy and Color Mode in the top bar.";
            w = 24;
            h = 16;
            targets = sharedTargets;
            getOption = mkTreemapScript null;
          })
        ])
        (d.mkSection {
          title = "Dedicated Quick Views — WizTree Directory Map & Service Footprint";
          rows = [
            [
              (d.mkEcharts {
                title = "WizTree Local Directory Map ($host)";
                description = "Always-visible interactive local directory treemap (Host → Category → Directory → Subdirectories).";
                w = 12;
                h = 12;
                targets = sharedTargets;
                getOption = mkTreemapScript "directory";
              })
              (d.mkEcharts {
                title = "Storage by Provider (Local vs Cloud)";
                description = "Side-by-side comparison of local disks/volumes against every remote storage provider (hbox, gdrive, b2).";
                w = 12;
                h = 12;
                targets = sharedTargets;
                getOption = mkTreemapScript "provider";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Exact Directory & Remote Breakdown Tables";
          collapsed = true;
          rows = [
            [
              (d.mkTable {
                title = "Local Directories & Services (Depth 1–2, >= 1 MiB)";
                w = 14;
                h = 10;
                noValue = "Awaiting first nixconf-storage-scan run";
                sortBy = [
                  {
                    desc = true;
                    displayName = "Size";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      category = "Category";
                      service = "Service";
                      path = "Path";
                      depth = "Depth";
                      "Value #A" = "Size";
                      "Value #B" = "Growth / Day";
                    };
                    index = {
                      host = 0;
                      category = 1;
                      service = 2;
                      path = 3;
                      depth = 4;
                      "Value #A" = 5;
                      "Value #B" = 6;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Size" "bytes")
                  (d.unitOverride "Growth / Day" "bytes")
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host, category, service, path, depth) (nixconf_storage_dir_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host, category, service, path, depth) (deriv(nixconf_storage_dir_bytes{host=~"$host"}[$window:])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
              (d.mkTable {
                title = "Remote Storage Providers & Slices";
                w = 10;
                h = 10;
                noValue = "No remote storage budgets configured";
                sortBy = [
                  {
                    desc = true;
                    displayName = "Used";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      provider = "Provider";
                      slice = "Slice";
                      scope = "Scope";
                      "Value #A" = "Used";
                      "Value #B" = "Limit";
                      "Value #C" = "Usage %";
                      "Value #D" = "Growth / Day";
                    };
                    index = {
                      host = 0;
                      provider = 1;
                      slice = 2;
                      scope = 3;
                      "Value #A" = 4;
                      "Value #B" = 5;
                      "Value #C" = 6;
                      "Value #D" = 7;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Used" "bytes")
                  (d.unitOverride "Limit" "bytes")
                  (d.cellGaugeOverride {
                    colName = "Usage %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.unitOverride "Growth / Day" "bytes")
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host, provider, slice, scope) (nixconf_storage_budget_used_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host, provider, slice, scope) (nixconf_storage_budget_limit_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, provider, slice, scope) ((nixconf_storage_budget_used_bytes{host=~"$host"} / clamp_min(nixconf_storage_budget_limit_bytes{host=~"$host"}, 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, provider, slice, scope) (deriv(nixconf_storage_budget_used_bytes{host=~"$host"}[$window:])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
          ];
        })
      ];
    };
}
