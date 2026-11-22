use std::collections::BTreeMap;
use std::env;
use std::fs;
use std::io::{BufRead, BufReader, Read, Write};
use std::net::{TcpListener, TcpStream};
use std::path::Path;
use std::process::{Child, Command, Stdio};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{Duration, SystemTime, UNIX_EPOCH};

struct Config {
    addr: String,
    local_host: String,
    local_home: String,
    remote_url: String,
    grafana_url: String,
    vm_addr: String,
    known_hosts: Vec<String>,
    agy_bin: String,
    systemctl_bin: String,
    sudo_bin: String,
    date_bin: String,
}

struct LoginSession {
    child: Child,
}

struct AppState {
    cfg: Config,
    login: Mutex<Option<LoginSession>>,
}

#[derive(Default, Clone)]
struct HostStatus {
    name: String,
    local: bool,
    online: bool,
    daemon: String,
    uptime: Option<String>,
    oauth_status: String,
    oauth_detail: String,
    oauth_expiry: Option<i64>,
    email: String,
    conversations: Option<u64>,
    storage_bytes: Option<u64>,
    last_seen_secs: Option<u64>,
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

fn url_encode(s: &str) -> String {
    let mut out = String::with_capacity(s.len() * 2);
    for b in s.bytes() {
        if b.is_ascii_alphanumeric() || matches!(b, b'-' | b'_' | b'.' | b'~') {
            out.push(b as char);
        } else {
            out.push_str(&format!("%{:02X}", b));
        }
    }
    out
}

fn now_unix() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0)
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

fn extract_json_string(src: &str, key: &str) -> Option<String> {
    let needle = format!("\"{}\"", key);
    let idx = src.find(&needle)?;
    let rest = &src[idx + needle.len()..];
    let colon = rest.find(':')?;
    let after = rest[colon + 1..].trim_start();
    if !after.starts_with('"') {
        return None;
    }
    let mut out = String::new();
    let mut chars = after[1..].chars();
    while let Some(c) = chars.next() {
        if c == '\\' {
            if let Some(n) = chars.next() {
                out.push(n);
            }
        } else if c == '"' {
            return Some(out);
        } else {
            out.push(c);
        }
    }
    None
}

fn parse_rfc3339_unix(date_bin: &str, s: &str) -> Option<i64> {
    let out = Command::new(date_bin).args(["-d", s, "+%s"]).output().ok()?;
    if !out.status.success() {
        return None;
    }
    String::from_utf8_lossy(&out.stdout).trim().parse::<i64>().ok()
}

fn format_oauth_detail(expiry: Option<i64>, fallback: &str) -> String {
    if let Some(exp) = expiry {
        if exp > 0 {
            let rem = exp - now_unix();
            if rem > 0 {
                return format!("Access token valid · {} left (auto-refreshes)", format_duration(rem as u64));
            }
            return "Refreshable OAuth session active".to_string();
        }
    }
    fallback.to_string()
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
    fs::read_dir(path).map(|rd| rd.flatten().count() as u64).unwrap_or(0)
}

fn monotonic_uptime_secs() -> Option<u64> {
    let raw = fs::read_to_string("/proc/uptime").ok()?;
    raw.split_whitespace().next()?.parse::<f64>().ok().map(|v| v as u64)
}

fn local_status(cfg: &Config) -> HostStatus {
    let gemini_dir = Path::new(&cfg.local_home).join(".gemini");
    let cli_dir = gemini_dir.join("antigravity-cli");
    let tok_path = cli_dir.join("antigravity-oauth-token");

    let mut oauth_status = "missing".to_string();
    let mut oauth_detail = "Not signed in yet".to_string();
    let mut oauth_expiry = None;
    let mut email = String::new();

    if let Ok(meta) = fs::metadata(&tok_path) {
        if meta.len() > 0 {
            oauth_status = "authenticated".to_string();
            let raw = fs::read_to_string(&tok_path).unwrap_or_default();
            if let Some(e) = extract_json_string(&raw, "id_token_email") {
                email = e;
            }
            if let Some(exp_str) = extract_json_string(&raw, "expiry") {
                oauth_expiry = parse_rfc3339_unix(&cfg.date_bin, &exp_str);
            }
            oauth_detail = format_oauth_detail(oauth_expiry, "OAuth token present");
        }
    }

    let mut daemon = "inactive".to_string();
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
            if let Some(now_s) = monotonic_uptime_secs() {
                let enter_s = enter_us / 1_000_000;
                if now_s >= enter_s {
                    uptime = Some(format_duration(now_s - enter_s));
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
        oauth_expiry,
        email,
        conversations: Some(count_entries(&cli_dir.join("conversations"))),
        storage_bytes: Some(dir_size_bytes(&gemini_dir)),
        last_seen_secs: Some(0),
    }
}

struct VmSample {
    host: String,
    email: String,
    value: f64,
}

fn query_vm(vm_addr: &str, promql: &str) -> Vec<VmSample> {
    if vm_addr.is_empty() {
        return Vec::new();
    }
    let mut stream = match TcpStream::connect(vm_addr) {
        Ok(s) => s,
        Err(_) => return Vec::new(),
    };
    let _ = stream.set_read_timeout(Some(Duration::from_secs(2)));
    let _ = stream.set_write_timeout(Some(Duration::from_secs(2)));
    let req = format!(
        "GET /api/v1/query?query={} HTTP/1.1\r\nHost: {}\r\nConnection: close\r\n\r\n",
        url_encode(promql),
        vm_addr
    );
    if stream.write_all(req.as_bytes()).is_err() {
        return Vec::new();
    }
    let mut raw = String::new();
    if stream.read_to_string(&mut raw).is_err() {
        return Vec::new();
    }
    let body = match raw.split_once("\r\n\r\n") {
        Some((_, b)) => b,
        None => return Vec::new(),
    };

    let mut samples = Vec::new();
    let mut cursor = body;
    while let Some(pos) = cursor.find("\"metric\":{") {
        let slice = &cursor[pos + 9..];
        let metric_end = match slice.find('}') {
            Some(e) => e,
            None => break,
        };
        let metric_obj = &slice[..metric_end + 1];
        let after_metric = &slice[metric_end + 1..];
        let host = extract_json_string(metric_obj, "host")
            .or_else(|| extract_json_string(metric_obj, "instance"))
            .unwrap_or_default();
        let email = extract_json_string(metric_obj, "email").unwrap_or_default();

        if let Some(vpos) = after_metric.find("\"value\":[") {
            let vslice = &after_metric[vpos + 9..];
            if let Some(vend) = vslice.find(']') {
                let inner = &vslice[..vend];
                if let Some((_, val_quoted)) = inner.split_once(',') {
                    let val_str = val_quoted.trim().trim_matches('"');
                    if let Ok(val) = val_str.parse::<f64>() {
                        if !host.is_empty() {
                            samples.push(VmSample { host, email, value: val });
                        }
                    }
                }
            }
        }
        cursor = after_metric;
    }
    samples
}

fn collect_hosts(cfg: &Config) -> Vec<HostStatus> {
    let mut map: BTreeMap<String, HostStatus> = BTreeMap::new();

    for h in &cfg.known_hosts {
        map.insert(
            h.clone(),
            HostStatus {
                name: h.clone(),
                local: false,
                online: false,
                daemon: "offline".to_string(),
                oauth_status: "offline".to_string(),
                oauth_detail: "Waiting for telemetry from host".to_string(),
                ..Default::default()
            },
        );
    }

    // 1) Check host liveness via node_systemd_unit_state or up in VictoriaMetrics (works even before agy-metrics timer runs)
    for s in query_vm(&cfg.vm_addr, "node_systemd_unit_state{name=\"agy-remote-control.service\",state=\"active\"}") {
        if s.host == cfg.local_host {
            continue;
        }
        let entry = map.entry(s.host.clone()).or_insert_with(|| HostStatus {
            name: s.host.clone(),
            ..Default::default()
        });
        entry.online = true;
        entry.daemon = if s.value >= 0.5 { "active".into() } else { "inactive".into() };
        if entry.oauth_status.is_empty() || entry.oauth_status == "offline" {
            entry.oauth_status = if s.value >= 0.5 { "authenticated".into() } else { "unknown".into() };
            entry.oauth_detail = if s.value >= 0.5 {
                "Daemon active · telemetry via Alloy".into()
            } else {
                "Host online · awaiting agy metrics".into()
            };
        }
    }

    // 2) Enrich with agy_* metrics pushed by Alloy textfile collector
    let now = now_unix();
    for s in query_vm(&cfg.vm_addr, "agy_metrics_updated_seconds") {
        if s.host == cfg.local_host {
            continue;
        }
        let age = (now - s.value as i64).max(0) as u64;
        let entry = map.entry(s.host.clone()).or_insert_with(|| HostStatus {
            name: s.host.clone(),
            ..Default::default()
        });
        entry.last_seen_secs = Some(age);
        entry.online = age < 180;
    }

    for s in query_vm(&cfg.vm_addr, "agy_daemon_active") {
        if s.host == cfg.local_host {
            continue;
        }
        if let Some(entry) = map.get_mut(&s.host) {
            if entry.online {
                entry.daemon = if s.value >= 0.5 { "active".into() } else { "inactive".into() };
            }
        }
    }

    for s in query_vm(&cfg.vm_addr, "agy_oauth_authenticated") {
        if s.host == cfg.local_host {
            continue;
        }
        if let Some(entry) = map.get_mut(&s.host) {
            if entry.online {
                entry.oauth_status = if s.value >= 0.5 { "authenticated".into() } else { "missing".into() };
            }
        }
    }

    for s in query_vm(&cfg.vm_addr, "agy_oauth_expiry_seconds") {
        if s.host == cfg.local_host {
            continue;
        }
        if let Some(entry) = map.get_mut(&s.host) {
            if entry.online && s.value > 0.0 {
                entry.oauth_expiry = Some(s.value as i64);
                entry.oauth_detail = format_oauth_detail(Some(s.value as i64), "OAuth token present");
            }
        }
    }

    for s in query_vm(&cfg.vm_addr, "agy_conversations_total") {
        if s.host == cfg.local_host {
            continue;
        }
        if let Some(entry) = map.get_mut(&s.host) {
            entry.conversations = Some(s.value.max(0.0) as u64);
        }
    }

    for s in query_vm(&cfg.vm_addr, "agy_storage_bytes") {
        if s.host == cfg.local_host {
            continue;
        }
        if let Some(entry) = map.get_mut(&s.host) {
            entry.storage_bytes = Some(s.value.max(0.0) as u64);
        }
    }

    for s in query_vm(&cfg.vm_addr, "agy_info") {
        if s.host == cfg.local_host {
            continue;
        }
        if let Some(entry) = map.get_mut(&s.host) {
            if !s.email.is_empty() {
                entry.email = s.email;
            }
        }
    }

    // Fallback online check via Alloy `up` metric if host is up even before agy switch
    for s in query_vm(&cfg.vm_addr, "max by (host) (node_boot_time_seconds)") {
        if s.host == cfg.local_host {
            continue;
        }
        if let Some(entry) = map.get_mut(&s.host) {
            if !entry.online {
                entry.online = true;
                if entry.daemon == "offline" {
                    entry.daemon = "inactive".into();
                }
                if entry.oauth_status == "offline" {
                    entry.oauth_status = "unknown".into();
                    entry.oauth_detail = "Host online · switch host to publish agy metrics".into();
                }
            }
        }
    }

    let mut out = vec![local_status(cfg)];
    out.extend(map.into_values());
    out
}

fn render_status_json(cfg: &Config) -> String {
    let hosts = collect_hosts(cfg);
    let mut items = Vec::new();
    for h in hosts {
        let uptime_json = h
            .uptime
            .as_ref()
            .map(|u| format!("\"{}\"", json_escape(u)))
            .unwrap_or_else(|| "null".into());
        let conv_json = h.conversations.map(|v| v.to_string()).unwrap_or_else(|| "null".into());
        let mb_json = h
            .storage_bytes
            .map(|b| format!("{:.1}", (b as f64) / (1024.0 * 1024.0)))
            .unwrap_or_else(|| "null".into());
        let exp_json = h.oauth_expiry.map(|v| v.to_string()).unwrap_or_else(|| "null".into());
        items.push(format!(
            concat!(
                "{{\"name\":\"{}\",\"local\":{},\"online\":{},\"daemon\":\"{}\",",
                "\"uptime\":{},\"email\":\"{}\",\"oauth\":{{\"status\":\"{}\",\"detail\":\"{}\",\"expiry\":{}}},",
                "\"usage\":{{\"conversations\":{},\"sizeMb\":{}}}}}"
            ),
            json_escape(&h.name),
            h.local,
            h.online,
            json_escape(&h.daemon),
            uptime_json,
            json_escape(&h.email),
            json_escape(&h.oauth_status),
            json_escape(&h.oauth_detail),
            exp_json,
            conv_json,
            mb_json
        ));
    }
    format!(
        "{{\"remoteUrl\":\"{}\",\"grafanaUrl\":\"{}\",\"timestamp\":{},\"hosts\":[{}]}}",
        json_escape(&cfg.remote_url),
        json_escape(&cfg.grafana_url),
        now_unix(),
        items.join(",")
    )
}

fn start_login(state: &AppState) -> (bool, String) {
    let mut guard = state.login.lock().unwrap();
    if let Some(mut old) = guard.take() {
        let _ = old.child.kill();
        let _ = old.child.wait();
    }

    let mut child = match Command::new(&state.cfg.agy_bin)
        .args(["acp", "--login"])
        .env("HOME", &state.cfg.local_home)
        .env("SSH_CONNECTION", "1 2 3 4")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
    {
        Ok(c) => c,
        Err(e) => return (false, format!("Failed to start agy login: {}", e)),
    };

    let stdout = match child.stdout.take() {
        Some(s) => s,
        None => {
            let _ = child.kill();
            return (false, "Failed to capture agy login output".into());
        }
    };

    let (tx, rx) = std::sync::mpsc::channel();
    thread::spawn(move || {
        let reader = BufReader::new(stdout);
        for line in reader.lines().flatten() {
            let trimmed = line.trim();
            if trimmed.starts_with("https://accounts.google.com/") {
                let _ = tx.send(trimmed.to_string());
                return;
            }
        }
    });

    match rx.recv_timeout(Duration::from_secs(10)) {
        Ok(url) => {
            *guard = Some(LoginSession { child });
            (true, url)
        }
        Err(_) => {
            let _ = child.kill();
            let _ = child.wait();
            (false, "Timed out waiting for Google sign-in URL from agy".into())
        }
    }
}

fn complete_login(state: &AppState, code: &str) -> (bool, String) {
    let trimmed = code.trim();
    if trimmed.is_empty() {
        return (false, "Please paste the authorization code or callback URL".into());
    }
    let mut session = {
        let mut guard = state.login.lock().unwrap();
        match guard.take() {
            Some(s) => s,
            None => return (false, "No active login session; click Sign in with Google again".into()),
        }
    };

    if let Some(mut stdin) = session.child.stdin.take() {
        if let Err(e) = writeln!(stdin, "{}", trimmed) {
            let _ = session.child.kill();
            return (false, format!("Failed to send code to agy: {}", e));
        }
    }

    for _ in 0..40 {
        match session.child.try_wait() {
            Ok(Some(status)) => {
                if status.success() {
                    let _ = Command::new(&state.cfg.sudo_bin)
                        .args(["-n", &state.cfg.systemctl_bin, "restart", "agy-remote-control.service"])
                        .output();
                    return (true, "Authenticated and daemon started".into());
                }
                return (false, "Google rejected the authorization code; please try again".into());
            }
            Ok(None) => thread::sleep(Duration::from_millis(250)),
            Err(e) => return (false, format!("Login process error: {}", e)),
        }
    }
    let _ = session.child.kill();
    let _ = session.child.wait();
    (false, "Timed out completing token exchange".into())
}

fn cancel_login(state: &AppState) {
    let mut guard = state.login.lock().unwrap();
    if let Some(mut old) = guard.take() {
        let _ = old.child.kill();
        let _ = old.child.wait();
    }
}

fn control_local(cfg: &Config, action: &str) -> (bool, String) {
    if !matches!(action, "start" | "stop" | "restart") {
        return (false, "Unsupported action".into());
    }
    match Command::new(&cfg.sudo_bin)
        .args(["-n", &cfg.systemctl_bin, action, "agy-remote-control.service"])
        .output()
    {
        Ok(o) => {
            let msg = String::from_utf8_lossy(if o.stderr.is_empty() { &o.stdout } else { &o.stderr })
                .trim()
                .to_string();
            (o.status.success(), if msg.is_empty() { "ok".into() } else { msg })
        }
        Err(e) => (false, e.to_string()),
    }
}

fn html_page(cfg: &Config) -> String {
    let grafana_btn = if cfg.grafana_url.is_empty() {
        String::new()
    } else {
        format!(
            "<a class=\"btn btn-ghost\" href=\"{}\" target=\"_blank\" rel=\"noopener\">Grafana ↗</a>",
            cfg.grafana_url
        )
    };
    let tpl = r##"<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Antigravity Hub</title>
  <style>
    :root {
      color-scheme: dark;
      --bg: #0b0d14;
      --surface: rgba(22, 26, 39, 0.84);
      --surface-hi: rgba(30, 36, 54, 0.92);
      --border: rgba(148, 163, 184, 0.14);
      --border-hi: rgba(129, 140, 248, 0.42);
      --text: #eef2ff;
      --muted: #94a3b8;
      --green: #34d399;
      --amber: #fbbf24;
      --red: #fb7185;
      --accent: #6366f1;
      --accent2: #38bdf8;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, sans-serif;
      background:
        radial-gradient(900px 500px at 15% -10%, rgba(99, 102, 241, 0.18), transparent 60%),
        radial-gradient(700px 420px at 88% 0%, rgba(56, 189, 248, 0.14), transparent 55%),
        var(--bg);
      color: var(--text);
      padding: 28px 20px 48px;
    }
    .wrap { max-width: 980px; margin: 0 auto; }
    header {
      display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between;
      gap: 16px; margin-bottom: 24px;
    }
    .brand { display: flex; align-items: center; gap: 14px; }
    .logo {
      width: 42px; height: 42px; border-radius: 12px;
      background: linear-gradient(135deg, var(--accent), var(--accent2));
      display: grid; place-items: center; font-weight: 800; font-size: 1.05rem; color: #fff;
      box-shadow: 0 8px 24px rgba(99, 102, 241, 0.35);
    }
    h1 { margin: 0; font-size: 1.4rem; letter-spacing: -0.02em; }
    .sub { color: var(--muted); font-size: 0.88rem; margin-top: 3px; }
    .hdr-actions { display: flex; flex-wrap: wrap; gap: 10px; }
    .btn {
      display: inline-flex; align-items: center; justify-content: center; gap: 7px;
      padding: 9px 15px; border-radius: 10px; border: 1px solid var(--border);
      background: var(--surface-hi); color: var(--text); text-decoration: none;
      font-size: 0.88rem; font-weight: 600; cursor: pointer; transition: all 0.15s ease;
    }
    .btn:hover { border-color: var(--border-hi); transform: translateY(-1px); }
    .btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }
    .btn-primary {
      background: linear-gradient(135deg, var(--accent), var(--accent2));
      border-color: transparent; color: #fff;
      box-shadow: 0 6px 18px rgba(99, 102, 241, 0.32);
    }
    .btn-ghost { background: transparent; }
    .btn-google {
      background: #fff; color: #111827; border-color: transparent;
      box-shadow: 0 4px 14px rgba(255, 255, 255, 0.12);
    }
    .btn-google:hover { background: #f8fafc; border-color: transparent; }
    .btn-sm { padding: 7px 11px; font-size: 0.82rem; border-radius: 8px; }
    .kpis {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(175px, 1fr));
      gap: 12px; margin-bottom: 22px;
    }
    .kpi {
      background: var(--surface); border: 1px solid var(--border); border-radius: 14px;
      padding: 14px 16px; backdrop-filter: blur(12px);
    }
    .kpi-label { font-size: 0.76rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.06em; }
    .kpi-val { font-size: 1.45rem; font-weight: 700; margin-top: 6px; font-variant-numeric: tabular-nums; }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 16px; }
    .card {
      background: var(--surface); border: 1px solid var(--border); border-radius: 16px;
      padding: 20px; display: flex; flex-direction: column; gap: 16px;
      backdrop-filter: blur(14px); transition: border-color 0.15s ease;
    }
    .card:hover { border-color: rgba(148, 163, 184, 0.28); }
    .row { display: flex; align-items: center; justify-content: space-between; gap: 10px; }
    .host-title { display: flex; align-items: center; gap: 10px; font-size: 1.08rem; font-weight: 700; }
    .dot { width: 9px; height: 9px; border-radius: 50%; display: inline-block; }
    .dot-on { background: var(--green); box-shadow: 0 0 0 4px rgba(52, 211, 153, 0.18); }
    .dot-off { background: #64748b; }
    .pill {
      padding: 4px 10px; border-radius: 999px; font-size: 0.74rem; font-weight: 700;
      letter-spacing: 0.03em; text-transform: uppercase;
    }
    .ok { background: rgba(52, 211, 153, 0.14); color: var(--green); }
    .warn { background: rgba(251, 191, 36, 0.15); color: var(--amber); }
    .err { background: rgba(251, 113, 133, 0.15); color: var(--red); }
    .muted { background: rgba(148, 163, 184, 0.14); color: var(--muted); }
    .email { font-size: 0.82rem; color: var(--muted); margin-top: -10px; }
    .rows {
      display: grid; gap: 10px; padding: 12px 14px; border-radius: 12px;
      background: rgba(11, 13, 20, 0.55); border: 1px solid rgba(148, 163, 184, 0.08);
      font-size: 0.86rem;
    }
    .label { color: var(--muted); }
    .detail { font-size: 0.8rem; color: var(--muted); }
    .actions { display: flex; flex-wrap: wrap; gap: 8px; margin-top: auto; }
    .toast {
      position: fixed; bottom: 20px; right: 20px; padding: 10px 16px; border-radius: 10px;
      background: var(--surface-hi); border: 1px solid var(--border-hi); font-size: 0.86rem;
      box-shadow: 0 12px 32px rgba(0, 0, 0, 0.45); opacity: 0; pointer-events: none; transition: opacity 0.2s;
    }
    .toast.show { opacity: 1; }
    .modal-bg {
      position: fixed; inset: 0; background: rgba(6, 8, 14, 0.76); backdrop-filter: blur(6px);
      display: none; align-items: center; justify-content: center; padding: 20px; z-index: 50;
    }
    .modal-bg.open { display: flex; }
    .modal {
      width: 100%; max-width: 480px; background: #141826; border: 1px solid var(--border-hi);
      border-radius: 18px; padding: 24px; display: flex; flex-direction: column; gap: 16px;
      box-shadow: 0 24px 60px rgba(0, 0, 0, 0.6);
    }
    .modal h2 { margin: 0; font-size: 1.18rem; }
    .step { font-size: 0.86rem; color: var(--muted); line-height: 1.5; }
    .step strong { color: var(--text); }
    input[type="text"] {
      width: 100%; padding: 11px 13px; border-radius: 10px; border: 1px solid var(--border);
      background: #0b0d14; color: var(--text); font-size: 0.9rem; outline: none;
    }
    input[type="text"]:focus { border-color: var(--accent2); }
    .modal-err { color: var(--red); font-size: 0.84rem; min-height: 1.1em; }
  </style>
</head>
<body>
  <div class="wrap">
    <header>
      <div class="brand">
        <div class="logo">AGY</div>
        <div>
          <h1>Antigravity Control Hub</h1>
          <div class="sub">Remote-control daemons, OAuth health &amp; host telemetry</div>
        </div>
      </div>
      <div class="hdr-actions">
        __GRAFANA_BTN__
        <a class="btn btn-primary" href="__REMOTE_URL__" target="_blank" rel="noopener">Open Remote Control ↗</a>
      </div>
    </header>
    <div id="kpis" class="kpis"></div>
    <div id="grid" class="grid"></div>
  </div>

  <div id="toast" class="toast"></div>

  <div id="loginModal" class="modal-bg">
    <div class="modal">
      <div class="row">
        <h2>Sign in with Google</h2>
        <button class="btn btn-sm btn-ghost" onclick="closeLogin()">Close</button>
      </div>
      <div class="step">
        <strong>1.</strong> Click below to open Google Sign-In in a new tab (this hub stays open).
      </div>
      <a id="googleLink" class="btn btn-google" href="#" target="_blank" rel="noopener">Continue with Google ↗</a>
      <div class="step">
        <strong>2.</strong> Google will display an authorization code on <code>antigravity.google/oauth-callback</code>. Paste the code (or full URL) below:
      </div>
      <input id="codeInput" type="text" placeholder="Paste authorization code or callback URL…" autocomplete="off" />
      <div id="modalErr" class="modal-err"></div>
      <div class="row">
        <button class="btn btn-ghost btn-sm" onclick="closeLogin()">Cancel</button>
        <button id="completeBtn" class="btn btn-primary" onclick="submitCode()">Complete Sign-In</button>
      </div>
    </div>
  </div>

  <script>
    function esc(s) {
      return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
    }
    function pill(cls, text) {
      return '<span class="pill ' + cls + '">' + esc(text) + '</span>';
    }
    var toastTimer = null;
    function notify(msg) {
      var el = document.getElementById("toast");
      el.textContent = msg;
      el.classList.add("show");
      clearTimeout(toastTimer);
      toastTimer = setTimeout(function() { el.classList.remove("show"); }, 3500);
    }
    async function act(host, action) {
      notify("Running " + action + " on " + host + "…");
      var res = await fetch("/api/host/" + encodeURIComponent(host) + "/" + action, { method: "POST" });
      var data = await res.json();
      notify(data.ok ? (host + ": " + action + " succeeded") : (host + ": " + data.message));
      await refresh();
    }
    async function openLogin() {
      document.getElementById("modalErr").textContent = "";
      document.getElementById("codeInput").value = "";
      notify("Starting Google sign-in…");
      var res = await fetch("/api/login/start", { method: "POST" });
      var data = await res.json();
      if (!data.ok) {
        notify("Login error: " + data.message);
        return;
      }
      document.getElementById("googleLink").href = data.url;
      document.getElementById("loginModal").classList.add("open");
      document.getElementById("codeInput").focus();
    }
    async function closeLogin() {
      document.getElementById("loginModal").classList.remove("open");
      await fetch("/api/login/cancel", { method: "POST" });
    }
    async function submitCode() {
      var btn = document.getElementById("completeBtn");
      var err = document.getElementById("modalErr");
      var code = document.getElementById("codeInput").value.trim();
      if (!code) { err.textContent = "Please paste the code or callback URL."; return; }
      btn.disabled = true;
      err.textContent = "";
      var res = await fetch("/api/login/complete", { method: "POST", body: code });
      var data = await res.json();
      btn.disabled = false;
      if (!data.ok) {
        err.textContent = data.message;
        return;
      }
      document.getElementById("loginModal").classList.remove("open");
      notify("Signed in! Remote-control daemon is active.");
      await refresh();
    }
    document.getElementById("codeInput").addEventListener("keydown", function(e) {
      if (e.key === "Enter") submitCode();
    });
    async function refresh() {
      var res = await fetch("/api/status");
      var data = await res.json();
      var hosts = data.hosts || [];
      var onlineCount = hosts.filter(function(h) { return h.online; }).length;
      var activeCount = hosts.filter(function(h) { return h.daemon === "active"; }).length;
      var authCount = hosts.filter(function(h) { return h.oauth.status === "authenticated"; }).length;
      var totalSessions = hosts.reduce(function(acc, h) { return acc + (h.usage && h.usage.conversations ? h.usage.conversations : 0); }, 0);

      document.getElementById("kpis").innerHTML =
        '<div class="kpi"><div class="kpi-label">Hosts Online</div><div class="kpi-val">' + onlineCount + ' / ' + hosts.length + '</div></div>'
        + '<div class="kpi"><div class="kpi-label">Active Daemons</div><div class="kpi-val">' + activeCount + ' / ' + hosts.length + '</div></div>'
        + '<div class="kpi"><div class="kpi-label">OAuth Healthy</div><div class="kpi-val">' + authCount + ' / ' + hosts.length + '</div></div>'
        + '<div class="kpi"><div class="kpi-label">Stored Sessions</div><div class="kpi-val">' + totalSessions + '</div></div>';

      document.getElementById("grid").innerHTML = hosts.map(function(h) {
        var dot = '<span class="dot ' + (h.online ? 'dot-on' : 'dot-off') + '"></span>';
        var onlinePill = h.online ? pill("ok", "Online") : pill("muted", "Offline");
        var daemonCls = h.daemon === "active" ? "ok" : (h.daemon === "offline" ? "muted" : "err");
        var authCls = h.oauth.status === "authenticated" ? "ok" : (h.oauth.status === "offline" ? "muted" : "warn");
        var usageText = h.usage && h.usage.conversations !== null
          ? (h.usage.conversations + " sessions" + (h.usage.sizeMb !== null ? (" · " + h.usage.sizeMb + " MB") : ""))
          : "No usage metrics yet";
        var emailHtml = h.email ? ('<div class="email">' + esc(h.email) + '</div>') : "";
        var actionsHtml = h.local
          ? ('<button class="btn btn-sm ' + (h.oauth.status !== "authenticated" ? "btn-google" : "") + '" onclick="openLogin()">'
              + (h.oauth.status === "authenticated" ? "Re-authenticate" : "Sign in with Google")
            + '</button>'
            + '<button class="btn btn-sm" onclick="act(\'' + esc(h.name) + '\',\'start\')">Start</button>'
            + '<button class="btn btn-sm" onclick="act(\'' + esc(h.name) + '\',\'restart\')">Restart</button>'
            + '<button class="btn btn-sm" onclick="act(\'' + esc(h.name) + '\',\'stop\')">Stop</button>')
          : '<span class="detail">Live telemetry pushed via Grafana Alloy</span>';
        return '<div class="card">'
          + '<div class="row"><div class="host-title">' + dot + esc(h.name) + '</div>' + onlinePill + '</div>'
          + emailHtml
          + '<div class="rows">'
            + '<div class="row"><span class="label">Daemon</span>' + pill(daemonCls, h.daemon + (h.uptime ? (" · " + h.uptime) : "")) + '</div>'
            + '<div class="row"><span class="label">OAuth</span>' + pill(authCls, h.oauth.status) + '</div>'
            + '<div class="detail">' + esc(h.oauth.detail || "") + '</div>'
            + '<div class="row"><span class="label">Usage</span><span>' + esc(usageText) + '</span></div>'
          + '</div>'
          + '<div class="actions">' + actionsHtml + '</div>'
        + '</div>';
      }).join("");
    }
    refresh();
    setInterval(refresh, 10000);
  </script>
</body>
</html>
"##;
    tpl.replace("__REMOTE_URL__", &cfg.remote_url)
        .replace("__GRAFANA_BTN__", &grafana_btn)
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

fn read_http_request(stream: &mut TcpStream) -> Option<(String, String, String)> {
    let _ = stream.set_read_timeout(Some(Duration::from_secs(5)));
    let mut buf = Vec::new();
    let mut tmp = [0u8; 4096];
    let mut header_end = None;
    while header_end.is_none() && buf.len() < 32768 {
        let n = stream.read(&mut tmp).ok()?;
        if n == 0 {
            break;
        }
        buf.extend_from_slice(&tmp[..n]);
        if let Some(pos) = buf.windows(4).position(|w| w == b"\r\n\r\n") {
            header_end = Some(pos);
        }
    }
    let hend = header_end?;
    let header_str = String::from_utf8_lossy(&buf[..hend]).to_string();
    let mut lines = header_str.lines();
    let mut first = lines.next()?.split_whitespace();
    let method = first.next()?.to_string();
    let path = first.next()?.split('?').next().unwrap_or("/").to_string();

    let mut content_len: usize = 0;
    for line in lines {
        if let Some((k, v)) = line.split_once(':') {
            if k.eq_ignore_ascii_case("content-length") {
                content_len = v.trim().parse().unwrap_or(0).min(16384);
            }
        }
    }

    let mut body_bytes = buf[hend + 4..].to_vec();
    while body_bytes.len() < content_len {
        let n = stream.read(&mut tmp).ok()?;
        if n == 0 {
            break;
        }
        body_bytes.extend_from_slice(&tmp[..n]);
    }
    body_bytes.truncate(content_len);
    Some((method, path, String::from_utf8_lossy(&body_bytes).to_string()))
}

fn handle_client(mut stream: TcpStream, state: Arc<AppState>) {
    let (method, path, body) = match read_http_request(&mut stream) {
        Some(r) => r,
        None => return,
    };

    match (method.as_str(), path.as_str()) {
        ("GET", "/healthz") => write_response(&mut stream, "200 OK", "text/plain; charset=utf-8", "ok\n"),
        ("GET", "/api/status") => {
            let out = render_status_json(&state.cfg);
            write_response(&mut stream, "200 OK", "application/json", &out);
        }
        ("GET", "/") => {
            let out = html_page(&state.cfg);
            write_response(&mut stream, "200 OK", "text/html; charset=utf-8", &out);
        }
        ("POST", "/api/login/start") => {
            let (ok, val) = start_login(&state);
            let out = if ok {
                format!("{{\"ok\":true,\"url\":\"{}\"}}", json_escape(&val))
            } else {
                format!("{{\"ok\":false,\"message\":\"{}\"}}", json_escape(&val))
            };
            write_response(&mut stream, if ok { "200 OK" } else { "500 Internal Server Error" }, "application/json", &out);
        }
        ("POST", "/api/login/complete") => {
            let (ok, msg) = complete_login(&state, &body);
            let out = format!("{{\"ok\":{},\"message\":\"{}\"}}", ok, json_escape(&msg));
            write_response(&mut stream, if ok { "200 OK" } else { "400 Bad Request" }, "application/json", &out);
        }
        ("POST", "/api/login/cancel") => {
            cancel_login(&state);
            write_response(&mut stream, "200 OK", "application/json", "{\"ok\":true}");
        }
        ("POST", p) if p.starts_with("/api/host/") => {
            let parts: Vec<&str> = p.trim_start_matches('/').split('/').collect();
            if parts.len() == 4 && parts[2] == state.cfg.local_host {
                let (ok, msg) = control_local(&state.cfg, parts[3]);
                let out = format!("{{\"ok\":{},\"message\":\"{}\"}}", ok, json_escape(&msg));
                write_response(&mut stream, if ok { "200 OK" } else { "400 Bad Request" }, "application/json", &out);
            } else {
                write_response(&mut stream, "400 Bad Request", "application/json", "{\"ok\":false,\"message\":\"Only local host can be controlled directly\"}");
            }
        }
        _ => write_response(&mut stream, "404 Not Found", "text/plain; charset=utf-8", "Not found\n"),
    }
}

fn main() {
    let known_hosts = env::var("AGY_HUB_KNOWN_HOSTS")
        .unwrap_or_default()
        .split(',')
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .collect();

    let state = Arc::new(AppState {
        cfg: Config {
            addr: env::var("AGY_HUB_ADDR").expect("AGY_HUB_ADDR"),
            local_host: env::var("AGY_HUB_HOST").expect("AGY_HUB_HOST"),
            local_home: env::var("AGY_HUB_HOME").expect("AGY_HUB_HOME"),
            remote_url: env::var("AGY_HUB_REMOTE_URL").expect("AGY_HUB_REMOTE_URL"),
            grafana_url: env::var("AGY_HUB_GRAFANA_URL").unwrap_or_default(),
            vm_addr: env::var("AGY_HUB_VM_ADDR").unwrap_or_default(),
            known_hosts,
            agy_bin: env::var("AGY_HUB_AGY_BIN").expect("AGY_HUB_AGY_BIN"),
            systemctl_bin: env::var("AGY_HUB_SYSTEMCTL").expect("AGY_HUB_SYSTEMCTL"),
            sudo_bin: env::var("AGY_HUB_SUDO").expect("AGY_HUB_SUDO"),
            date_bin: env::var("AGY_HUB_DATE").expect("AGY_HUB_DATE"),
        },
        login: Mutex::new(None),
    });

    let listener = TcpListener::bind(&state.cfg.addr).expect("failed to bind AGY_HUB_ADDR");
    for stream in listener.incoming().flatten() {
        let st = Arc::clone(&state);
        thread::spawn(move || handle_client(stream, st));
    }
}
