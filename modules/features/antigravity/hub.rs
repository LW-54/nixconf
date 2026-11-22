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
    output: Arc<Mutex<String>>,
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
                return format!("access token {} left (auto-refresh)", format_duration(rem as u64));
            }
            return "refresh token active".to_string();
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
    let mut oauth_detail = "not signed in".to_string();
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
            oauth_detail = format_oauth_detail(oauth_expiry, "token present");
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
                oauth_detail: "no telemetry".to_string(),
                ..Default::default()
            },
        );
    }

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
                "daemon active via alloy".into()
            } else {
                "awaiting agy metrics".into()
            };
        }
    }

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
                entry.oauth_detail = format_oauth_detail(Some(s.value as i64), "token present");
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
                    entry.oauth_detail = "online · awaiting agy_metrics".into();
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
        .stderr(Stdio::piped())
        .spawn()
    {
        Ok(c) => c,
        Err(e) => return (false, format!("failed to spawn agy: {}", e)),
    };

    let stdout = match child.stdout.take() {
        Some(s) => s,
        None => {
            let _ = child.kill();
            return (false, "failed to capture stdout".into());
        }
    };
    let stderr = child.stderr.take();

    let output = Arc::new(Mutex::new(String::new()));
    let out_stdout = Arc::clone(&output);
    let out_stderr = Arc::clone(&output);

    if let Some(err_stream) = stderr {
        thread::spawn(move || {
            let reader = BufReader::new(err_stream);
            for line in reader.lines().flatten() {
                let mut buf = out_stderr.lock().unwrap();
                buf.push_str(&line);
                buf.push('\n');
            }
        });
    }

    // IMPORTANT: Keep draining stdout until EOF so agy never receives SIGPIPE!
    let (tx, rx) = std::sync::mpsc::channel();
    thread::spawn(move || {
        let mut sent = false;
        let reader = BufReader::new(stdout);
        for line in reader.lines().flatten() {
            let trimmed = line.trim();
            if !sent && trimmed.starts_with("https://accounts.google.com/") {
                let _ = tx.send(trimmed.to_string());
                sent = true;
            }
            let mut buf = out_stdout.lock().unwrap();
            buf.push_str(&line);
            buf.push('\n');
        }
    });

    match rx.recv_timeout(Duration::from_secs(10)) {
        Ok(url) => {
            *guard = Some(LoginSession { child, output });
            (true, url)
        }
        Err(_) => {
            let _ = child.kill();
            let _ = child.wait();
            let log = output.lock().unwrap().trim().to_string();
            let msg = if log.is_empty() {
                "timed out waiting for google sign-in url".into()
            } else {
                format!("login failed: {}", log)
            };
            (false, msg)
        }
    }
}

fn complete_login(state: &AppState, code: &str) -> (bool, String) {
    let trimmed = code.trim();
    if trimmed.is_empty() {
        return (false, "empty authorization code".into());
    }

    let mut session = {
        let mut guard = state.login.lock().unwrap();
        match guard.take() {
            Some(s) => s,
            None => return (false, "no active login session; click login again".into()),
        }
    };

    if let Ok(Some(status)) = session.child.try_wait() {
        let log = session.output.lock().unwrap().trim().to_string();
        return (
            false,
            format!(
                "login process exited early ({}): {}",
                status,
                if log.is_empty() { "click login again" } else { &log }
            ),
        );
    }

    if let Some(mut stdin) = session.child.stdin.take() {
        if let Err(e) = writeln!(stdin, "{}", trimmed) {
            let _ = session.child.kill();
            let _ = session.child.wait();
            return (false, format!("failed writing code to agy: {}", e));
        }
        let _ = stdin.flush();
    } else {
        let _ = session.child.kill();
        let _ = session.child.wait();
        return (false, "login stdin already closed; click login again".into());
    }

    for _ in 0..60 {
        match session.child.try_wait() {
            Ok(Some(status)) => {
                if status.success() {
                    let _ = Command::new(&state.cfg.sudo_bin)
                        .args(["-n", &state.cfg.systemctl_bin, "restart", "agy-remote-control.service"])
                        .output();
                    return (true, "authenticated and daemon started".into());
                }
                let log = session.output.lock().unwrap().trim().to_string();
                let tail = log.lines().last().unwrap_or("token exchange failed");
                return (false, format!("auth failed: {}", tail));
            }
            Ok(None) => thread::sleep(Duration::from_millis(250)),
            Err(e) => return (false, format!("login wait error: {}", e)),
        }
    }

    let _ = session.child.kill();
    let _ = session.child.wait();
    (false, "timed out waiting for token exchange".into())
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
        return (false, "unsupported action".into());
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
            "<a class=\"btn\" href=\"{}\" target=\"_blank\" rel=\"noopener\">Grafana ↗</a>",
            cfg.grafana_url
        )
    };
    let tpl = r##"<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>agy // control</title>
  <style>
    :root {
      color-scheme: dark;
      --bg: #0c0e11;
      --panel: #13161b;
      --panel-alt: #181c23;
      --border: #252b34;
      --border-hi: #3c4655;
      --text: #e6edf3;
      --muted: #8b949e;
      --ok: #3fb950;
      --warn: #d29922;
      --err: #f85149;
      --mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      --sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font-family: var(--sans);
      font-size: 14px;
      line-height: 1.45;
    }
    .topbar {
      border-bottom: 1px solid var(--border);
      background: var(--panel);
    }
    .topbar-inner {
      max-width: 1040px;
      margin: 0 auto;
      padding: 12px 20px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }
    .title {
      display: flex;
      align-items: baseline;
      gap: 12px;
      font-family: var(--mono);
      font-weight: 600;
      font-size: 14px;
      letter-spacing: 0.02em;
    }
    .summary {
      font-family: var(--mono);
      font-size: 12px;
      color: var(--muted);
    }
    .actions { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
    .btn {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 6px 12px;
      border-radius: 3px;
      border: 1px solid var(--border-hi);
      background: var(--panel-alt);
      color: var(--text);
      text-decoration: none;
      font-family: var(--mono);
      font-size: 12px;
      font-weight: 500;
      cursor: pointer;
    }
    .btn:hover { background: #212731; border-color: #586477; }
    .btn:disabled { opacity: 0.45; cursor: not-allowed; }
    .btn-primary {
      background: var(--text);
      color: var(--bg);
      border-color: var(--text);
      font-weight: 600;
    }
    .btn-primary:hover { background: #cfd8e3; border-color: #cfd8e3; }
    .btn-warn {
      border-color: var(--warn);
      color: var(--warn);
    }
    .btn-warn:hover { background: rgba(210, 153, 34, 0.12); }
    main {
      max-width: 1040px;
      margin: 0 auto;
      padding: 20px;
      display: grid;
      gap: 16px;
    }
    .panel {
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 3px;
      overflow: hidden;
    }
    .table-wrap { overflow-x: auto; }
    table {
      width: 100%;
      border-collapse: collapse;
      text-align: left;
    }
    th {
      font-family: var(--mono);
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      color: var(--muted);
      background: var(--panel-alt);
      padding: 10px 14px;
      border-bottom: 1px solid var(--border);
    }
    td {
      padding: 12px 14px;
      border-bottom: 1px solid var(--border);
      vertical-align: middle;
    }
    tr:last-child td { border-bottom: none; }
    .mono { font-family: var(--mono); font-size: 12.5px; font-variant-numeric: tabular-nums; }
    .sub { font-size: 12px; color: var(--muted); margin-top: 2px; }
    .tag {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      font-family: var(--mono);
      font-size: 12px;
      font-weight: 500;
    }
    .dot { width: 7px; height: 7px; border-radius: 1px; display: inline-block; }
    .c-ok { color: var(--ok); }
    .c-warn { color: var(--warn); }
    .c-err { color: var(--err); }
    .c-muted { color: var(--muted); }
    .b-ok { background: var(--ok); }
    .b-warn { background: var(--warn); }
    .b-err { background: var(--err); }
    .b-muted { background: #484f58; }
    .login-drawer {
      display: none;
      padding: 16px 18px;
      background: var(--panel);
      border: 1px solid var(--border-hi);
      border-radius: 3px;
      gap: 12px;
    }
    .login-drawer.open { display: grid; }
    .drawer-head {
      display: flex;
      align-items: center;
      justify-content: space-between;
      font-family: var(--mono);
      font-size: 13px;
      font-weight: 600;
    }
    .drawer-row {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      align-items: center;
    }
    input[type="text"] {
      flex: 1;
      min-width: 240px;
      padding: 7px 10px;
      border-radius: 3px;
      border: 1px solid var(--border-hi);
      background: var(--bg);
      color: var(--text);
      font-family: var(--mono);
      font-size: 12.5px;
      outline: none;
    }
    input[type="text"]:focus { border-color: var(--text); }
    .status-bar {
      font-family: var(--mono);
      font-size: 12px;
      color: var(--muted);
      min-height: 1.4em;
    }
    .status-bar.err { color: var(--err); }
    .status-bar.ok { color: var(--ok); }
  </style>
</head>
<body>
  <div class="topbar">
    <div class="topbar-inner">
      <div class="title">
        <span>AGY // HUB</span>
        <span id="summary" class="summary">loading…</span>
      </div>
      <div class="actions">
        __GRAFANA_BTN__
        <a class="btn btn-primary" href="__REMOTE_URL__" target="_blank" rel="noopener">Open Remote Control ↗</a>
      </div>
    </div>
  </div>

  <main>
    <section id="loginDrawer" class="login-drawer">
      <div class="drawer-head">
        <span>OAUTH LOGIN // LOCAL HOST</span>
        <button class="btn" onclick="closeLogin()">Cancel</button>
      </div>
      <div class="sub">
        1. Complete Google sign-in in the opened tab (or click <strong>Open Google Sign-In</strong>).
        2. Copy the code from <code>antigravity.google/oauth-callback</code> and paste below — submits automatically on paste.
      </div>
      <div class="drawer-row">
        <a id="googleLink" class="btn btn-primary" href="#" target="_blank" rel="noopener">Open Google Sign-In ↗</a>
        <input id="codeInput" type="text" placeholder="Paste authorization code or callback URL…" autocomplete="off" />
        <button id="pasteBtn" class="btn" onclick="pasteAndSubmit()">Paste &amp; Sign In</button>
        <button id="completeBtn" class="btn btn-primary" onclick="submitCode()">Submit</button>
      </div>
      <div id="loginMsg" class="status-bar"></div>
    </section>

    <section class="panel">
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Host</th>
              <th>Daemon</th>
              <th>OAuth</th>
              <th>Usage</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody id="tbody">
            <tr><td colspan="5" class="mono c-muted">loading hosts…</td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <div id="statusBar" class="status-bar"></div>
  </main>

  <script>
    function esc(s) {
      return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
    }
    function tag(cls, text) {
      return '<span class="tag c-' + cls + '"><span class="dot b-' + cls + '"></span>' + esc(text) + '</span>';
    }
    function setStatus(msg, cls) {
      var el = document.getElementById("statusBar");
      el.textContent = msg || "";
      el.className = "status-bar" + (cls ? (" " + cls) : "");
    }
    async function act(host, action) {
      setStatus(host + ": running " + action + "…");
      var res = await fetch("/api/host/" + encodeURIComponent(host) + "/" + action, { method: "POST" });
      var data = await res.json();
      setStatus(host + ": " + (data.ok ? (action + " ok") : data.message), data.ok ? "ok" : "err");
      await refresh();
    }
    async function openLogin() {
      var msg = document.getElementById("loginMsg");
      msg.textContent = "starting oauth flow…";
      msg.className = "status-bar";
      document.getElementById("codeInput").value = "";
      var res = await fetch("/api/login/start", { method: "POST" });
      var data = await res.json();
      if (!data.ok) {
        setStatus("login start failed: " + data.message, "err");
        return;
      }
      var link = document.getElementById("googleLink");
      link.href = data.url;
      document.getElementById("loginDrawer").classList.add("open");
      msg.textContent = "ready — waiting for authorization code";
      window.open(data.url, "_blank", "noopener");
      document.getElementById("codeInput").focus();
    }
    async function closeLogin() {
      document.getElementById("loginDrawer").classList.remove("open");
      await fetch("/api/login/cancel", { method: "POST" });
    }
    async function pasteAndSubmit() {
      try {
        var text = await navigator.clipboard.readText();
        if (text && text.trim()) {
          document.getElementById("codeInput").value = text.trim();
          await submitCode();
          return;
        }
      } catch (e) {}
      document.getElementById("codeInput").focus();
      document.getElementById("loginMsg").textContent = "press Ctrl+V in the input field";
    }
    async function submitCode() {
      var btn = document.getElementById("completeBtn");
      var msg = document.getElementById("loginMsg");
      var code = document.getElementById("codeInput").value.trim();
      if (!code) {
        msg.textContent = "paste the authorization code or callback url";
        msg.className = "status-bar err";
        return;
      }
      btn.disabled = true;
      msg.textContent = "exchanging token…";
      msg.className = "status-bar";
      var res = await fetch("/api/login/complete", {
        method: "POST",
        headers: { "Content-Type": "text/plain" },
        body: code
      });
      var data = await res.json();
      btn.disabled = false;
      if (!data.ok) {
        msg.textContent = data.message;
        msg.className = "status-bar err";
        return;
      }
      document.getElementById("loginDrawer").classList.remove("open");
      setStatus("authenticated — remote-control daemon active", "ok");
      await refresh();
    }
    document.getElementById("codeInput").addEventListener("keydown", function(e) {
      if (e.key === "Enter") submitCode();
    });
    document.getElementById("codeInput").addEventListener("paste", function() {
      setTimeout(function() {
        if (document.getElementById("codeInput").value.trim().length > 10) {
          submitCode();
        }
      }, 30);
    });
    async function refresh() {
      var res = await fetch("/api/status");
      var data = await res.json();
      var hosts = data.hosts || [];
      var online = hosts.filter(function(h) { return h.online; }).length;
      var active = hosts.filter(function(h) { return h.daemon === "active"; }).length;
      var sessions = hosts.reduce(function(a, h) { return a + (h.usage && h.usage.conversations ? h.usage.conversations : 0); }, 0);
      document.getElementById("summary").textContent =
        online + "/" + hosts.length + " online · " + active + "/" + hosts.length + " active · " + sessions + " sessions";

      document.getElementById("tbody").innerHTML = hosts.map(function(h) {
        var hostCls = h.online ? "ok" : "muted";
        var daemonCls = h.daemon === "active" ? "ok" : (h.daemon === "offline" ? "muted" : "err");
        var authCls = h.oauth.status === "authenticated" ? "ok" : (h.oauth.status === "offline" ? "muted" : "warn");
        var daemonLabel = h.daemon + (h.uptime ? (" (" + h.uptime + ")") : "");
        var usageMain = (h.usage && h.usage.conversations !== null) ? (h.usage.conversations + " sessions") : "—";
        var usageSub = (h.usage && h.usage.sizeMb !== null) ? (h.usage.sizeMb + " MB") : "";
        var actions = h.local
          ? ('<div class="actions">'
              + '<button class="btn ' + (h.oauth.status !== "authenticated" ? "btn-warn" : "") + '" onclick="openLogin()">'
                + (h.oauth.status === "authenticated" ? "Re-login" : "Login")
              + '</button>'
              + '<button class="btn" onclick="act(\'' + esc(h.name) + '\',\'start\')">Start</button>'
              + '<button class="btn" onclick="act(\'' + esc(h.name) + '\',\'restart\')">Restart</button>'
              + '<button class="btn" onclick="act(\'' + esc(h.name) + '\',\'stop\')">Stop</button>'
            + '</div>')
          : '<span class="mono c-muted">telemetry via alloy</span>';
        return '<tr>'
          + '<td>' + tag(hostCls, h.name) + (h.email ? ('<div class="sub mono">' + esc(h.email) + '</div>') : "") + '</td>'
          + '<td>' + tag(daemonCls, daemonLabel) + '</td>'
          + '<td>' + tag(authCls, h.oauth.status) + '<div class="sub mono">' + esc(h.oauth.detail || "") + '</div></td>'
          + '<td class="mono">' + esc(usageMain) + (usageSub ? ('<div class="sub">' + esc(usageSub) + '</div>') : "") + '</td>'
          + '<td>' + actions + '</td>'
        + '</tr>';
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

fn decode_chunked(raw: &[u8]) -> Option<Vec<u8>> {
    let mut out = Vec::new();
    let mut i = 0;
    while i < raw.len() {
        let rel = raw[i..].windows(2).position(|w| w == b"\r\n")?;
        let size_str = std::str::from_utf8(&raw[i..i + rel]).ok()?.split(';').next()?.trim();
        let size = usize::from_str_radix(size_str, 16).ok()?;
        i += rel + 2;
        if size == 0 {
            return Some(out);
        }
        if i + size + 2 > raw.len() {
            return None;
        }
        out.extend_from_slice(&raw[i..i + size]);
        i += size + 2;
    }
    None
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

    let mut content_len: Option<usize> = None;
    let mut chunked = false;
    for line in lines {
        if let Some((k, v)) = line.split_once(':') {
            if k.eq_ignore_ascii_case("content-length") {
                content_len = Some(v.trim().parse().unwrap_or(0).min(16384));
            } else if k.eq_ignore_ascii_case("transfer-encoding") && v.to_ascii_lowercase().contains("chunked") {
                chunked = true;
            }
        }
    }

    let mut body_bytes = buf[hend + 4..].to_vec();
    if chunked {
        loop {
            if let Some(decoded) = decode_chunked(&body_bytes) {
                return Some((method, path, String::from_utf8_lossy(&decoded).to_string()));
            }
            if body_bytes.len() >= 16384 {
                break;
            }
            let n = stream.read(&mut tmp).ok()?;
            if n == 0 {
                break;
            }
            body_bytes.extend_from_slice(&tmp[..n]);
        }
        return Some((method, path, String::new()));
    }

    let target = content_len.unwrap_or(0);
    while body_bytes.len() < target {
        let n = stream.read(&mut tmp).ok()?;
        if n == 0 {
            break;
        }
        body_bytes.extend_from_slice(&tmp[..n]);
    }
    body_bytes.truncate(target);
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
                write_response(&mut stream, "400 Bad Request", "application/json", "{\"ok\":false,\"message\":\"only local host can be controlled directly\"}");
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
