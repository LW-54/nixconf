use std::env;
use std::fs;
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::path::Path;
use std::process::Command;
use std::sync::Arc;
use std::thread;
use std::time::{SystemTime, UNIX_EPOCH};

struct Config {
    addr: String,
    local_host: String,
    local_home: String,
    remote_url: String,
    login_url: String,
    peers: Vec<(String, String)>,
    systemctl_bin: String,
    sudo_bin: String,
    ssh_bin: String,
}

struct HostStatus {
    name: String,
    local: bool,
    online: bool,
    daemon: String,
    uptime: Option<String>,
    oauth_status: String,
    oauth_detail: String,
    conversations: Option<u64>,
    storage_bytes: Option<u64>,
    login_url: String,
}

fn json_escape(s: &str) -> String {
    let mut out = String::with_capacity(s.len() + 2);
    for c in s.chars() {
        match c {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if (c as u32) < 0x20 => out.push(' '),
            c => out.push(c),
        }
    }
    out
}

fn format_duration(secs: u64) -> String {
    let days = secs / 86400;
    let hours = (secs % 86400) / 3600;
    let mins = (secs % 3600) / 60;
    let mut parts = Vec::new();
    if days > 0 {
        parts.push(format!("{}d", days));
    }
    if hours > 0 {
        parts.push(format!("{}h", hours));
    }
    if mins > 0 || parts.is_empty() {
        parts.push(format!("{}m", mins));
    }
    parts.join(" ")
}

fn dir_size_bytes(path: &Path) -> u64 {
    let mut total = 0u64;
    if let Ok(entries) = fs::read_dir(path) {
        for entry in entries.flatten() {
            let p = entry.path();
            if let Ok(meta) = fs::symlink_metadata(&p) {
                if meta.is_file() {
                    total = total.saturating_add(meta.len());
                } else if meta.is_dir() {
                    total = total.saturating_add(dir_size_bytes(&p));
                }
            }
        }
    }
    total
}

fn count_entries(path: &Path) -> u64 {
    fs::read_dir(path)
        .map(|rd| rd.flatten().count() as u64)
        .unwrap_or(0)
}

fn monotonic_uptime_secs() -> Option<u64> {
    let raw = fs::read_to_string("/proc/uptime").ok()?;
    let first = raw.split_whitespace().next()?;
    first.parse::<f64>().ok().map(|v| v as u64)
}

fn inspect_local_oauth(path: &Path) -> (String, String) {
    let meta = match fs::metadata(path) {
        Ok(m) if m.len() > 0 => m,
        _ => return ("missing".into(), "No OAuth token found".into()),
    };
    let age_note = meta
        .modified()
        .ok()
        .and_then(|m| SystemTime::now().duration_since(m).ok())
        .map(|d| format!("updated {} ago", format_duration(d.as_secs())))
        .unwrap_or_else(|| "present".into());

    if let Ok(raw) = fs::read_to_string(path) {
        let trimmed = raw.trim();
        if trimmed.contains("refresh_token") || trimmed.contains("refreshToken") {
            return (
                "authenticated".into(),
                format!("Refreshable OAuth token ({})", age_note),
            );
        }
    }
    (
        "authenticated".into(),
        format!("OAuth token present ({})", age_note),
    )
}

fn local_status(cfg: &Config) -> HostStatus {
    let gemini_dir = Path::new(&cfg.local_home).join(".gemini");
    let cli_dir = gemini_dir.join("antigravity-cli");
    let (oauth_status, oauth_detail) =
        inspect_local_oauth(&cli_dir.join("antigravity-oauth-token"));

    let mut daemon = String::from("unknown");
    let mut uptime = None;
    if let Ok(out) = Command::new(&cfg.systemctl_bin)
        .args([
            "show",
            "agy-remote-control.service",
            "--property=ActiveState,ActiveEnterTimestampMonotonic",
            "--no-pager",
        ])
        .output()
    {
        let text = String::from_utf8_lossy(&out.stdout);
        let mut enter_us = 0u64;
        for line in text.lines() {
            if let Some((k, v)) = line.split_once('=') {
                if k == "ActiveState" && !v.is_empty() {
                    daemon = v.to_string();
                } else if k == "ActiveEnterTimestampMonotonic" {
                    enter_us = v.parse::<u64>().unwrap_or(0);
                }
            }
        }
        if daemon == "active" && enter_us > 0 {
            if let Some(now_secs) = monotonic_uptime_secs() {
                let enter_secs = enter_us / 1_000_000;
                if now_secs >= enter_secs {
                    uptime = Some(format_duration(now_secs - enter_secs));
                }
            }
        }
    }

    HostStatus {
        name: cfg.local_host.clone(),
        local: true,
        online: true,
        daemon,
        uptime,
        oauth_status,
        oauth_detail,
        conversations: Some(count_entries(&cli_dir.join("conversations"))),
        storage_bytes: Some(dir_size_bytes(&gemini_dir)),
        login_url: cfg.login_url.clone(),
    }
}

fn peer_status(cfg: &Config, name: &str, target: &str) -> HostStatus {
    let remote_cmd = concat!(
        "state=$(systemctl is-active agy-remote-control.service 2>/dev/null || true); ",
        "tok=\"$HOME/.gemini/antigravity-cli/antigravity-oauth-token\"; ",
        "if [ -s \"$tok\" ]; then auth=\"authenticated\"; else auth=\"missing\"; fi; ",
        "convs=$(find \"$HOME/.gemini/antigravity-cli/conversations\" -maxdepth 1 -mindepth 1 2>/dev/null | wc -l); ",
        "printf \"%s|%s|%s\\n\" \"$state\" \"$auth\" \"$convs\""
    );
    let res = Command::new(&cfg.ssh_bin)
        .args([
            "-o",
            "BatchMode=yes",
            "-o",
            "ConnectTimeout=2",
            "-o",
            "StrictHostKeyChecking=accept-new",
            target,
            remote_cmd,
        ])
        .output();

    match res {
        Ok(out) if out.status.success() => {
            let s = String::from_utf8_lossy(&out.stdout);
            let parts: Vec<&str> = s.trim().split('|').collect();
            let daemon = parts
                .first()
                .copied()
                .filter(|v| !v.is_empty())
                .unwrap_or("unknown")
                .to_string();
            let oauth_status = parts
                .get(1)
                .copied()
                .filter(|v| !v.is_empty())
                .unwrap_or("missing")
                .to_string();
            let convs = parts.get(2).and_then(|v| v.trim().parse::<u64>().ok());
            let oauth_detail = if oauth_status == "authenticated" {
                "OAuth token present on peer".to_string()
            } else {
                "Run `agy` on this host to sign in".to_string()
            };
            HostStatus {
                name: name.to_string(),
                local: false,
                online: true,
                daemon,
                uptime: None,
                oauth_status,
                oauth_detail,
                conversations: convs,
                storage_bytes: None,
                login_url: String::new(),
            }
        }
        _ => HostStatus {
            name: name.to_string(),
            local: false,
            online: false,
            daemon: "offline".to_string(),
            uptime: None,
            oauth_status: "offline".to_string(),
            oauth_detail: "Host unreachable over SSH".to_string(),
            conversations: None,
            storage_bytes: None,
            login_url: String::new(),
        },
    }
}

fn collect_hosts(cfg: &Config) -> Vec<HostStatus> {
    let mut hosts = vec![local_status(cfg)];
    for (name, target) in &cfg.peers {
        hosts.push(peer_status(cfg, name, target));
    }
    hosts
}

fn render_status_json(cfg: &Config) -> String {
    let hosts = collect_hosts(cfg);
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    let mut items = Vec::new();
    for h in hosts {
        let uptime_json = match &h.uptime {
            Some(u) => format!("\"{}\"", json_escape(u)),
            None => "null".to_string(),
        };
        let conv_json = h
            .conversations
            .map(|v| v.to_string())
            .unwrap_or_else(|| "null".to_string());
        let mb_json = h
            .storage_bytes
            .map(|b| format!("{:.1}", (b as f64) / (1024.0 * 1024.0)))
            .unwrap_or_else(|| "null".to_string());
        items.push(format!(
            concat!(
                "{{\"name\":\"{}\",\"local\":{},\"online\":{},\"daemon\":\"{}\",",
                "\"uptime\":{},\"oauth\":{{\"status\":\"{}\",\"detail\":\"{}\"}},",
                "\"usage\":{{\"conversations\":{},\"sizeMb\":{}}},\"loginUrl\":\"{}\"}}"
            ),
            json_escape(&h.name),
            h.local,
            h.online,
            json_escape(&h.daemon),
            uptime_json,
            json_escape(&h.oauth_status),
            json_escape(&h.oauth_detail),
            conv_json,
            mb_json,
            json_escape(&h.login_url)
        ));
    }
    format!(
        "{{\"remoteUrl\":\"{}\",\"timestamp\":{},\"hosts\":[{}]}}",
        json_escape(&cfg.remote_url),
        ts,
        items.join(",")
    )
}

fn render_metrics(cfg: &Config) -> String {
    let hosts = collect_hosts(cfg);
    let mut out = String::new();
    out.push_str("# HELP agy_host_online Whether the host is reachable (1=online, 0=offline)\n");
    out.push_str("# TYPE agy_host_online gauge\n");
    for h in &hosts {
        out.push_str(&format!(
            "agy_host_online{{host=\"{}\"}} {}\n",
            json_escape(&h.name),
            if h.online { 1 } else { 0 }
        ));
    }
    out.push_str("# HELP agy_daemon_active Whether agy-remote-control.service is active (1=active, 0=inactive)\n");
    out.push_str("# TYPE agy_daemon_active gauge\n");
    for h in &hosts {
        out.push_str(&format!(
            "agy_daemon_active{{host=\"{}\"}} {}\n",
            json_escape(&h.name),
            if h.daemon == "active" { 1 } else { 0 }
        ));
    }
    out.push_str("# HELP agy_oauth_authenticated Whether an OAuth token is present (1=authenticated, 0=not)\n");
    out.push_str("# TYPE agy_oauth_authenticated gauge\n");
    for h in &hosts {
        out.push_str(&format!(
            "agy_oauth_authenticated{{host=\"{}\"}} {}\n",
            json_escape(&h.name),
            if h.oauth_status == "authenticated" { 1 } else { 0 }
        ));
    }
    out.push_str("# HELP agy_conversations_total Number of stored Antigravity conversations\n");
    out.push_str("# TYPE agy_conversations_total gauge\n");
    for h in &hosts {
        if let Some(c) = h.conversations {
            out.push_str(&format!(
                "agy_conversations_total{{host=\"{}\"}} {}\n",
                json_escape(&h.name),
                c
            ));
        }
    }
    out.push_str("# HELP agy_storage_bytes Disk usage of ~/.gemini in bytes\n");
    out.push_str("# TYPE agy_storage_bytes gauge\n");
    for h in &hosts {
        if let Some(b) = h.storage_bytes {
            out.push_str(&format!(
                "agy_storage_bytes{{host=\"{}\"}} {}\n",
                json_escape(&h.name),
                b
            ));
        }
    }
    out
}

fn control_host(cfg: &Config, host: &str, action: &str) -> (bool, String) {
    if !matches!(action, "start" | "stop" | "restart") {
        return (false, "Unsupported action".into());
    }
    if host == cfg.local_host {
        let res = Command::new(&cfg.sudo_bin)
            .args(["-n", &cfg.systemctl_bin, action, "agy-remote-control.service"])
            .output();
        return match res {
            Ok(o) => {
                let msg = String::from_utf8_lossy(if o.stderr.is_empty() {
                    &o.stdout
                } else {
                    &o.stderr
                })
                .trim()
                .to_string();
                (o.status.success(), if msg.is_empty() { "ok".into() } else { msg })
            }
            Err(e) => (false, e.to_string()),
        };
    }
    if let Some((_, target)) = cfg.peers.iter().find(|(n, _)| n == host) {
        let remote_cmd = format!("sudo -n systemctl {} agy-remote-control.service", action);
        let res = Command::new(&cfg.ssh_bin)
            .args([
                "-o",
                "BatchMode=yes",
                "-o",
                "ConnectTimeout=3",
                target,
                &remote_cmd,
            ])
            .output();
        return match res {
            Ok(o) => {
                let msg = String::from_utf8_lossy(if o.stderr.is_empty() {
                    &o.stdout
                } else {
                    &o.stderr
                })
                .trim()
                .to_string();
                (o.status.success(), if msg.is_empty() { "ok".into() } else { msg })
            }
            Err(e) => (false, e.to_string()),
        };
    }
    (false, "Unknown host".into())
}

fn html_page(remote_url: &str) -> String {
    let tpl = r#"<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Antigravity Remote Control Hub</title>
  <style>
    :root { color-scheme: dark; --bg:#11111b; --card:#1e1e2e; --border:#313244; --text:#cdd6f4; --muted:#a6adc8; --green:#a6e3a1; --yellow:#f9e2af; --red:#f38ba8; --blue:#89b4fa; }
    * { box-sizing: border-box; }
    body { margin:0; font-family: system-ui, -apple-system, sans-serif; background:var(--bg); color:var(--text); padding:24px; }
    .wrap { max-width:920px; margin:0 auto; }
    header { display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; gap:16px; margin-bottom:24px; }
    h1 { margin:0; font-size:1.5rem; }
    .sub { color:var(--muted); font-size:0.9rem; margin-top:4px; }
    .btn { display:inline-flex; align-items:center; gap:6px; padding:9px 14px; border-radius:8px; border:1px solid var(--border); background:#181825; color:var(--text); text-decoration:none; font-size:0.9rem; font-weight:600; cursor:pointer; }
    .btn:hover { border-color:var(--blue); }
    .btn-primary { background:var(--blue); color:#11111b; border-color:var(--blue); }
    .btn-warn { background:var(--yellow); color:#11111b; border-color:var(--yellow); }
    .btn-sm { padding:6px 10px; font-size:0.82rem; }
    .grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(320px,1fr)); gap:16px; }
    .card { background:var(--card); border:1px solid var(--border); border-radius:12px; padding:18px; display:flex; flex-direction:column; gap:12px; }
    .row { display:flex; align-items:center; justify-content:space-between; gap:8px; }
    .badge { padding:3px 9px; border-radius:999px; font-size:0.78rem; font-weight:700; text-transform:uppercase; }
    .ok { background:rgba(166,227,161,0.15); color:var(--green); }
    .warn { background:rgba(249,226,175,0.15); color:var(--yellow); }
    .err { background:rgba(243,139,168,0.15); color:var(--red); }
    .muted { background:rgba(166,173,200,0.12); color:var(--muted); }
    .meta { font-size:0.86rem; color:var(--muted); display:grid; gap:6px; }
    .actions { display:flex; flex-wrap:wrap; gap:8px; margin-top:4px; }
    .toast { margin-top:16px; font-size:0.85rem; color:var(--muted); min-height:1.2em; }
  </style>
</head>
<body>
  <div class="wrap">
    <header>
      <div>
        <h1>Antigravity Remote Control Hub</h1>
        <div class="sub">Monitor daemons, OAuth state, and sessions across hosts</div>
      </div>
      <a class="btn btn-primary" href="__REMOTE_URL__" target="_blank" rel="noopener">Open Remote Control ↗</a>
    </header>
    <div id="grid" class="grid">Loading host status…</div>
    <div id="toast" class="toast"></div>
  </div>
  <script>
    function esc(s) {
      return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
    }
    function badge(cls, text) {
      return '<span class="badge ' + cls + '">' + esc(text) + '</span>';
    }
    async function act(host, action) {
      var toast = document.getElementById("toast");
      toast.textContent = "Running " + action + " on " + host + "...";
      var res = await fetch("/api/host/" + encodeURIComponent(host) + "/" + action, { method: "POST" });
      var data = await res.json();
      toast.textContent = data.ok ? (host + ": " + action + " succeeded") : (host + ": " + data.message);
      await refresh();
    }
    async function refresh() {
      var res = await fetch("/api/status");
      var data = await res.json();
      var grid = document.getElementById("grid");
      grid.innerHTML = data.hosts.map(function(h) {
        var onlineBadge = h.online ? badge("ok", "Online") : badge("muted", "Offline");
        var daemonCls = h.daemon === "active" ? "ok" : (h.daemon === "offline" ? "muted" : "err");
        var authCls = h.oauth.status === "authenticated" ? "ok" : (h.oauth.status === "offline" ? "muted" : "warn");
        var usageLine = h.usage && h.usage.conversations !== null
          ? ("Sessions: " + h.usage.conversations + (h.usage.sizeMb !== null ? (" · Disk: " + h.usage.sizeMb + " MB") : ""))
          : "No live telemetry";
        var loginBtn = h.loginUrl
          ? ('<a class="btn btn-sm ' + (h.oauth.status !== "authenticated" ? "btn-warn" : "") + '" href="' + esc(h.loginUrl) + '">' + (h.oauth.status === "authenticated" ? "Re-authenticate" : "Login with Google ↗") + '</a>')
          : "";
        var controls = h.online
          ? ('<button class="btn btn-sm" onclick="act(\'' + esc(h.name) + '\',\'start\')">Start</button>'
            + '<button class="btn btn-sm" onclick="act(\'' + esc(h.name) + '\',\'restart\')">Restart</button>'
            + '<button class="btn btn-sm" onclick="act(\'' + esc(h.name) + '\',\'stop\')">Stop</button>')
          : "";
        return '<div class="card">'
          + '<div class="row"><strong>' + esc(h.name) + '</strong>' + onlineBadge + '</div>'
          + '<div class="meta">'
          + '<div class="row"><span>Daemon</span>' + badge(daemonCls, h.daemon + (h.uptime ? (" · " + h.uptime) : "")) + '</div>'
          + '<div class="row"><span>OAuth</span>' + badge(authCls, h.oauth.status) + '</div>'
          + '<div>' + esc(h.oauth.detail || "") + '</div>'
          + '<div>' + esc(usageLine) + '</div>'
          + '</div>'
          + '<div class="actions">' + loginBtn + controls + '</div>'
          + '</div>';
      }).join("");
    }
    refresh();
    setInterval(refresh, 10000);
  </script>
</body>
</html>
"#;
    tpl.replace("__REMOTE_URL__", remote_url)
}

fn write_response(stream: &mut TcpStream, status: &str, content_type: &str, body: &str) {
    let resp = format!(
        "HTTP/1.1 {}\r\nContent-Type: {}\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
        status,
        content_type,
        body.len(),
        body
    );
    let _ = stream.write_all(resp.as_bytes());
}

fn handle_client(mut stream: TcpStream, cfg: Arc<Config>) {
    let mut buf = [0u8; 4096];
    let n = match stream.read(&mut buf) {
        Ok(n) if n > 0 => n,
        _ => return,
    };
    let req = String::from_utf8_lossy(&buf[..n]);
    let mut first = req.lines().next().unwrap_or("").split_whitespace();
    let method = first.next().unwrap_or("");
    let raw_path = first.next().unwrap_or("/");
    let path = raw_path.split('?').next().unwrap_or("/");

    match (method, path) {
        ("GET", "/healthz") => write_response(&mut stream, "200 OK", "text/plain; charset=utf-8", "ok\n"),
        ("GET", "/metrics") => {
            let body = render_metrics(&cfg);
            write_response(&mut stream, "200 OK", "text/plain; version=0.0.4; charset=utf-8", &body);
        }
        ("GET", "/api/status") => {
            let body = render_status_json(&cfg);
            write_response(&mut stream, "200 OK", "application/json", &body);
        }
        ("GET", "/") => {
            let body = html_page(&cfg.remote_url);
            write_response(&mut stream, "200 OK", "text/html; charset=utf-8", &body);
        }
        ("POST", p) if p.starts_with("/api/host/") => {
            let parts: Vec<&str> = p.trim_start_matches('/').split('/').collect();
            if parts.len() == 4 {
                let (ok, msg) = control_host(&cfg, parts[2], parts[3]);
                let status = if ok { "200 OK" } else { "400 Bad Request" };
                let body = format!("{{\"ok\":{},\"message\":\"{}\"}}", ok, json_escape(&msg));
                write_response(&mut stream, status, "application/json", &body);
            } else {
                write_response(&mut stream, "404 Not Found", "application/json", "{\"ok\":false,\"message\":\"Not found\"}");
            }
        }
        _ => write_response(&mut stream, "404 Not Found", "text/plain; charset=utf-8", "Not found\n"),
    }
}

fn main() {
    let peers_raw = env::var("AGY_HUB_PEERS").unwrap_or_default();
    let peers = peers_raw
        .split(',')
        .filter_map(|item| {
            let item = item.trim();
            let (k, v) = item.split_once('=')?;
            if k.is_empty() || v.is_empty() {
                None
            } else {
                Some((k.to_string(), v.to_string()))
            }
        })
        .collect();

    let cfg = Arc::new(Config {
        addr: env::var("AGY_HUB_ADDR").expect("AGY_HUB_ADDR"),
        local_host: env::var("AGY_HUB_HOST").expect("AGY_HUB_HOST"),
        local_home: env::var("AGY_HUB_HOME").expect("AGY_HUB_HOME"),
        remote_url: env::var("AGY_HUB_REMOTE_URL").expect("AGY_HUB_REMOTE_URL"),
        login_url: env::var("AGY_HUB_LOGIN_URL").unwrap_or_default(),
        peers,
        systemctl_bin: env::var("AGY_HUB_SYSTEMCTL").expect("AGY_HUB_SYSTEMCTL"),
        sudo_bin: env::var("AGY_HUB_SUDO").expect("AGY_HUB_SUDO"),
        ssh_bin: env::var("AGY_HUB_SSH").expect("AGY_HUB_SSH"),
    });

    let listener = TcpListener::bind(&cfg.addr).expect("failed to bind AGY_HUB_ADDR");
    for stream in listener.incoming().flatten() {
        let c = Arc::clone(&cfg);
        thread::spawn(move || handle_client(stream, c));
    }
}
