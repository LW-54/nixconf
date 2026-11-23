use std::collections::{BTreeMap, HashMap, HashSet};
use std::env;
use std::fs;
use std::io;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process;

const MERMAID_MARKER: &str = "<!--NIXCONF_MERMAID:";
const SNIPPET_MARKER: &str = "<!--NIXCONF_SNIPPET:";
const MARKER_END: &str = "-->";

const MERMAID_CLASS_DEFS: &str = "\
classDef hostNode fill:#1e293b,stroke:#38bdf8,stroke-width:2px,color:#f8fafc;\n\
classDef contractNode fill:#1e1b4b,stroke:#818cf8,stroke-width:2px,color:#f8fafc;\n\
classDef implNode fill:#0f172a,stroke:#34d399,stroke-width:2px,color:#f8fafc;\n\
classDef featureNode fill:#134e4a,stroke:#2dd4bf,stroke-width:2px,color:#f8fafc;\n\
classDef optNode fill:#422006,stroke:#facc15,stroke-width:1px,color:#fefce8;\n\
classDef typeNode fill:#3b0764,stroke:#c084fc,stroke-width:1px,color:#faf5ff;\n\
classDef pkgNode fill:#4c0519,stroke:#fb7185,stroke-width:1px,color:#fff1f2;\n\
classDef devShellNode fill:#451a03,stroke:#fb923c,stroke-width:1px,color:#fff7ed;\n\
classDef drvNode fill:#18181b,stroke:#a1a1aa,stroke-width:1px,color:#f4f4f5;\n\
classDef defaultNode fill:#1e293b,stroke:#64748b,stroke-width:1px,color:#f8fafc;";

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 4 || args.len() > 5 {
        eprintln!("Usage: nixconf-docs-sync <materialize|write|check> <src> <dst> [repo_root]");
        process::exit(2);
    }

    let res = match args[1].as_str() {
        "materialize" => {
            let repo_root = args.get(4).map(|s| Path::new(s.as_str()));
            cmd_materialize(Path::new(&args[2]), Path::new(&args[3]), repo_root)
        }
        "write" => cmd_write(Path::new(&args[2]), Path::new(&args[3])),
        "check" => cmd_check(Path::new(&args[2]), Path::new(&args[3])),
        other => {
            eprintln!("Unknown subcommand: {other}");
            process::exit(2);
        }
    };

    if let Err(err) = res {
        eprintln!("nixconf-docs-sync error: {err}");
        process::exit(1);
    }
}

/// Parses a flat JSON object mapping relative paths to UTF-8 markdown contents
/// (as produced by `builtins.toJSON`), expands deferred Mermaid and snippet
/// markers in native Rust, and writes every file under `out_dir`.
fn cmd_materialize(
    manifest_path: &Path,
    out_dir: &Path,
    repo_root: Option<&Path>,
) -> io::Result<()> {
    let bytes = fs::read(manifest_path)?;
    let mut parser = JsonParser::new(&bytes);
    let entries = parser
        .parse_string_map()
        .map_err(|msg| io::Error::new(io::ErrorKind::InvalidData, msg))?;

    let mut file_cache: HashMap<String, Option<CachedFile>> = HashMap::new();
    fs::create_dir_all(out_dir)?;

    for (rel, raw_content) in entries {
        let content = expand_markdown(&raw_content, repo_root, &mut file_cache)
            .map_err(|msg| io::Error::new(io::ErrorKind::InvalidData, format!("{rel}: {msg}")))?;
        let target = out_dir.join(&rel);
        if let Some(parent) = target.parent() {
            fs::create_dir_all(parent)?;
        }
        fs::write(&target, content.as_bytes())?;
    }
    Ok(())
}

/// Synchronizes files from `src_root` into `dst_root`, writing only files whose
/// contents changed, and removes stale `docs/**/*.md` files and empty dirs.
fn cmd_write(src_root: &Path, dst_root: &Path) -> io::Result<()> {
    let mut expected = HashSet::new();
    let mut src_files = Vec::new();
    collect_files(src_root, src_root, &mut src_files)?;

    let mut written = 0usize;
    for rel in &src_files {
        expected.insert(rel.clone());
        let src_path = src_root.join(rel);
        let dst_path = dst_root.join(rel);
        let data = fs::read(&src_path)?;

        let unchanged = match fs::read(&dst_path) {
            Ok(existing) => existing == data,
            Err(_) => false,
        };

        if !unchanged {
            if let Some(parent) = dst_path.parent() {
                fs::create_dir_all(parent)?;
            }
            fs::write(&dst_path, &data)?;
            fs::set_permissions(&dst_path, fs::Permissions::from_mode(0o644))?;
            written += 1;
        }
    }

    let docs_dir = dst_root.join("docs");
    if docs_dir.is_dir() {
        prune_stale_docs(dst_root, &docs_dir, &expected)?;
    }

    println!(
        "Documentation synchronized: {} files ({} updated).",
        src_files.len(),
        written
    );
    Ok(())
}

/// Verifies that `dst_root` matches `src_root` bit-for-bit with no missing,
/// out-of-sync, or stale `docs/**/*.md` files. Exits with code 1 on drift.
fn cmd_check(src_root: &Path, dst_root: &Path) -> io::Result<()> {
    let mut src_files = Vec::new();
    collect_files(src_root, src_root, &mut src_files)?;
    src_files.sort();

    let mut expected = HashSet::with_capacity(src_files.len());
    let mut failed = false;

    for rel in &src_files {
        expected.insert(rel.clone());
        let src_path = src_root.join(rel);
        let dst_path = dst_root.join(rel);
        if !dst_path.is_file() {
            eprintln!("Missing generated file: {}", rel.display());
            failed = true;
            continue;
        }
        let src_bytes = fs::read(&src_path)?;
        let dst_bytes = fs::read(&dst_path)?;
        if src_bytes != dst_bytes {
            eprintln!("Out of sync: {}", rel.display());
            failed = true;
        }
    }

    let docs_dir = dst_root.join("docs");
    if docs_dir.is_dir() {
        let mut existing_docs = Vec::new();
        collect_files(dst_root, &docs_dir, &mut existing_docs)?;
        existing_docs.sort();
        for rel in existing_docs {
            if rel.extension().and_then(|e| e.to_str()) == Some("md") && !expected.contains(&rel) {
                eprintln!("Stale file (no longer generated): {}", rel.display());
                failed = true;
            }
        }
    }

    if failed {
        process::exit(1);
    }
    Ok(())
}

fn collect_files(root: &Path, dir: &Path, out: &mut Vec<PathBuf>) -> io::Result<()> {
    for entry in fs::read_dir(dir)? {
        let entry = entry?;
        let path = entry.path();
        let meta = fs::metadata(&path)?;
        if meta.is_dir() {
            collect_files(root, &path, out)?;
        } else if meta.is_file() {
            if let Ok(rel) = path.strip_prefix(root) {
                out.push(rel.to_path_buf());
            }
        }
    }
    Ok(())
}

fn prune_stale_docs(
    dst_root: &Path,
    dir: &Path,
    expected: &HashSet<PathBuf>,
) -> io::Result<()> {
    for entry in fs::read_dir(dir)? {
        let entry = entry?;
        let path = entry.path();
        let meta = fs::symlink_metadata(&path)?;
        if meta.is_dir() {
            prune_stale_docs(dst_root, &path, expected)?;
            if fs::read_dir(&path)?.next().is_none() {
                let _ = fs::remove_dir(&path);
            }
        } else if meta.is_file() && path.extension().and_then(|e| e.to_str()) == Some("md") {
            if let Ok(rel) = path.strip_prefix(dst_root) {
                if !expected.contains(rel) {
                    fs::remove_file(&path)?;
                    println!("Removed stale file: {}", rel.display());
                }
            }
        }
    }
    Ok(())
}

// ============================================================================
// Deferred Markdown Expansion (Mermaid diagrams & targeted source snippets)
// ============================================================================

struct CachedFile {
    raw_text: String,
    lines: Vec<String>,
    code_lines: Vec<(usize, String, String)>, // (1-based idx, raw line, trimmed line)
}

fn load_cached_file<'a>(
    rel: &str,
    repo_root: Option<&Path>,
    cache: &'a mut HashMap<String, Option<CachedFile>>,
) -> Option<&'a CachedFile> {
    if !cache.contains_key(rel) {
        let loaded = repo_root.and_then(|root| {
            let full = root.join(rel);
            let raw_text = fs::read_to_string(full).ok()?;
            let lines: Vec<String> = raw_text.split('\n').map(|s| s.to_string()).collect();
            let mut code_lines = Vec::new();
            for (i, line) in lines.iter().enumerate() {
                let trimmed = line.trim();
                if !trimmed.is_empty()
                    && !trimmed.starts_with('#')
                    && !trimmed.starts_with("//")
                    && !trimmed.starts_with("/*")
                {
                    code_lines.push((i + 1, line.clone(), trimmed.to_string()));
                }
            }
            Some(CachedFile {
                raw_text,
                lines,
                code_lines,
            })
        });
        cache.insert(rel.to_string(), loaded);
    }
    cache.get(rel).and_then(|o| o.as_ref())
}

fn expand_markdown(
    input: &str,
    repo_root: Option<&Path>,
    file_cache: &mut HashMap<String, Option<CachedFile>>,
) -> Result<String, String> {
    if !input.contains("<!--NIXCONF_") {
        return Ok(input.to_string());
    }

    let bytes = input.as_bytes();
    let mut out = String::with_capacity(input.len() + 1024);
    let mut cursor = 0usize;

    while cursor < input.len() {
        let rest = &input[cursor..];
        let next_m = rest.find(MERMAID_MARKER);
        let next_s = rest.find(SNIPPET_MARKER);

        let (offset, is_mermaid, prefix_len) = match (next_m, next_s) {
            (Some(m), Some(s)) if m <= s => (m, true, MERMAID_MARKER.len()),
            (Some(_), Some(s)) => (s, false, SNIPPET_MARKER.len()),
            (Some(m), None) => (m, true, MERMAID_MARKER.len()),
            (None, Some(s)) => (s, false, SNIPPET_MARKER.len()),
            (None, None) => {
                out.push_str(rest);
                break;
            }
        };

        out.push_str(&rest[..offset]);
        let json_start = cursor + offset + prefix_len;
        let mut parser = JsonParser::new(&bytes[json_start..]);
        let val = parser.parse_value()?;
        parser.skip_ws();
        let after_json = json_start + parser.pos;
        if !input[after_json..].starts_with(MARKER_END) {
            return Err(format!("unterminated NIXCONF marker at byte {json_start}"));
        }

        let expanded = if is_mermaid {
            render_mermaid(&val)?
        } else {
            render_snippet(&val, repo_root, file_cache)?
        };
        out.push_str(&expanded);
        cursor = after_json + MARKER_END.len();
    }

    Ok(out)
}

fn render_snippet(
    spec: &JsonValue,
    repo_root: Option<&Path>,
    file_cache: &mut HashMap<String, Option<CachedFile>>,
) -> Result<String, String> {
    let files = spec
        .get_array("files")
        .map(|arr| {
            let mut seen = HashSet::new();
            let mut out = Vec::new();
            for v in arr {
                if let Some(s) = v.as_str() {
                    if !s.is_empty() && seen.insert(s.to_string()) {
                        out.push(s.to_string());
                    }
                }
            }
            out
        })
        .unwrap_or_default();

    let all_terms: Vec<String> = spec
        .get_array("terms")
        .map(|arr| {
            let mut seen = HashSet::new();
            let mut out = Vec::new();
            for v in arr {
                if let Some(s) = v.as_str() {
                    if !s.is_empty() && seen.insert(s.to_string()) {
                        out.push(s.to_string());
                    }
                }
            }
            out
        })
        .unwrap_or_default();

    let mut file_snippets = Vec::new();

    if !all_terms.is_empty() {
        for f in &files {
            let Some(entry) = load_cached_file(f, repo_root, file_cache) else {
                continue;
            };
            let present_terms: Vec<&str> = all_terms
                .iter()
                .map(|s| s.as_str())
                .filter(|t| entry.raw_text.contains(*t))
                .collect();
            if present_terms.is_empty() {
                continue;
            }

            let num_lines = entry.lines.len();
            let mut formatted_matches = Vec::new();
            for (idx, raw_line, trimmed) in &entry.code_lines {
                if !present_terms.iter().any(|t| raw_line.contains(*t)) {
                    continue;
                }
                let needs_block = trimmed.ends_with('{') || trimmed.ends_with('=');
                if needs_block {
                    let end = (*idx + 3).min(num_lines);
                    let mut block = Vec::with_capacity(end - *idx + 1);
                    for i in *idx..=end {
                        block.push(format!("{i}: {}", entry.lines[i - 1].trim()));
                    }
                    formatted_matches.push(block.join("\n"));
                } else {
                    formatted_matches.push(format!("{idx}: {trimmed}"));
                }
            }

            if !formatted_matches.is_empty() {
                file_snippets.push(format!(
                    "# {f}\n...\n{}\n...",
                    formatted_matches.join("\n...\n")
                ));
            }
        }
    }

    if !file_snippets.is_empty() {
        Ok(file_snippets.join("\n\n"))
    } else if let Some(fb) = spec.get_str("fallback") {
        Ok(fb.to_string())
    } else {
        Ok(String::new())
    }
}

fn sanitize_id(s: &str) -> String {
    let mut out = String::with_capacity(s.len() + 8);
    for ch in s.chars() {
        match ch {
            ':' => out.push_str("__"),
            '.' | '-' | '/' | '@' | '~' | ' ' => out.push('_'),
            other => out.push(other),
        }
    }
    out
}

fn escape_label(s: &str) -> String {
    s.replace('"', "'")
}

fn get_node_class(kind: &str) -> &'static str {
    match kind {
        "host" | "configuration" => "hostNode",
        "contract" => "contractNode",
        "implementation" | "impl" => "implNode",
        "feature" => "featureNode",
        "option" | "opt" => "optNode",
        "type" => "typeNode",
        "package" | "pkg" => "pkgNode",
        "devShell" | "shell" => "devShellNode",
        "derivation" | "drv" => "drvNode",
        _ => "defaultNode",
    }
}

fn format_node(id: &str, label: &str, kind: &str) -> String {
    let safe_id = sanitize_id(id);
    let esc_label = escape_label(label);
    let cls = get_node_class(kind);
    match kind {
        "host" | "configuration" => format!("{safe_id}([\"{esc_label}\"]):::{cls}"),
        "contract" => format!("{safe_id}{{{{\"{esc_label}\"}}}}:::{cls}"),
        "implementation" | "impl" => format!("{safe_id}[\"{esc_label}\"]:::{cls}"),
        "feature" => format!("{safe_id}(\"{esc_label}\"):::{cls}"),
        "option" | "opt" => format!("{safe_id}[/\"{esc_label}\"/]:::{cls}"),
        "type" => format!("{safe_id}[[\"{esc_label}\"]]:::{cls}"),
        "package" | "pkg" => format!("{safe_id}[(\"{esc_label}\")]:::{cls}"),
        "devShell" | "shell" => format!("{safe_id}[\"{esc_label}\"]:::{cls}"),
        _ => format!("{safe_id}[\"{esc_label}\"]:::{cls}"),
    }
}

fn format_edge(source: &str, target: &str, rel: &str) -> String {
    let src = sanitize_id(source);
    let tgt = sanitize_id(target);
    match rel {
        "implements" | "IMPLEMENTS" => format!("{src} ==>|implements| {tgt}"),
        "consumes" | "CONSUMES" => format!("{src} -.->|consumes| {tgt}"),
        "flowsTo" | "FLOWS_TO" => format!("{src} -.->|flowsTo| {tgt}"),
        "writes" | "WRITES" => format!("{src} -.->|writes| {tgt}"),
        "reads" | "READS" => format!("{src} -.->|reads| {tgt}"),
        "imports" | "IMPORTS" => format!("{src} -->|imports| {tgt}"),
        "dependsOn" | "DEPENDS_ON" => format!("{src} -->|dependsOn| {tgt}"),
        "declares" => format!("{src} -->|declares| {tgt}"),
        "outputs" => format!("{src} -->|outputs| {tgt}"),
        "contains" => format!("{src} -->|contains| {tgt}"),
        "typedBy" => format!("{src} -.->|typedBy| {tgt}"),
        other => format!("{src} -->|{other}| {tgt}"),
    }
}

struct MermaidNode<'a> {
    id: &'a str,
    label: &'a str,
    kind: &'a str,
    stratum: &'a str,
    url: Option<&'a str>,
    tooltip: &'a str,
    cluster: Option<&'a str>,
}

fn render_mermaid(spec: &JsonValue) -> Result<String, String> {
    let layout = spec.get_str("layout").unwrap_or("TD");
    let cluster_by = spec.get_str("clusterBy");
    let include_theme = spec.get_bool("includeTheme").unwrap_or(true);
    let title = spec.get_str("title");
    let wrap_code_block = spec.get_bool("wrapCodeBlock").unwrap_or(true);
    let raw = spec.get_bool("raw").unwrap_or(false);

    let mut nodes: Vec<MermaidNode<'_>> = Vec::new();
    let mut node_ids: HashSet<&str> = HashSet::new();

    if let Some(arr) = spec.get_array("nodes") {
        for n in arr {
            let id = n.get_str("id").unwrap_or("");
            let label = n.get_str("label").unwrap_or(id);
            let kind = n.get_str("kind").unwrap_or("default");
            let stratum = n.get_str("stratum").unwrap_or("other");
            let url = n.get_str("url");
            let tooltip = n.get_str("tooltip").unwrap_or(id);
            let cluster = n.get_str("cluster");
            node_ids.insert(id);
            nodes.push(MermaidNode {
                id,
                label,
                kind,
                stratum,
                url,
                tooltip,
                cluster,
            });
        }
    }

    let mut valid_edges: Vec<(&str, &str, &str)> = Vec::new();
    if let Some(arr) = spec.get_array("edges") {
        for e in arr {
            let src = e.get_str("source").unwrap_or("");
            let tgt = e.get_str("target").unwrap_or("");
            let rel = e.get_str("relation").unwrap_or("");
            if node_ids.contains(src) && node_ids.contains(tgt) {
                valid_edges.push((src, tgt, rel));
            }
        }
    }

    let render_edge_list = |edges: &[(&str, &str, &str)]| -> String {
        let mut seen = HashSet::with_capacity(edges.len());
        let mut out = Vec::with_capacity(edges.len());
        for (src, tgt, rel) in edges {
            let line = format_edge(src, tgt, rel);
            if seen.insert(line.clone()) {
                out.push(line);
            }
        }
        out.join("\n    ")
    };

    let chart_content = if nodes.is_empty() {
        format!("flowchart {layout}\n    empty[\"Empty Graph\"]")
    } else {
        let use_clusters = cluster_by.is_some() || nodes.iter().any(|n| n.cluster.is_some());
        let body = if use_clusters {
            let mut grouped: BTreeMap<&str, Vec<&MermaidNode<'_>>> = BTreeMap::new();
            for n in &nodes {
                let key = match cluster_by {
                    Some("stratum") => n.stratum,
                    Some("kind") => n.kind,
                    _ => n.cluster.unwrap_or("other"),
                };
                grouped.entry(key).or_default().push(n);
            }
            let mut subgraphs = Vec::with_capacity(grouped.len());
            for (c_key, c_nodes) in grouped {
                let c_safe = sanitize_id(&format!("cluster_{c_key}"));
                let node_lines: Vec<String> = c_nodes
                    .iter()
                    .map(|n| format_node(n.id, n.label, n.kind))
                    .collect();
                // Matches Nix indented multiline string spacing inside `flowchart.nix`
                subgraphs.push(format!(
                    "subgraph {c_safe} [\"{c_key}\"]\n  {}\nend",
                    node_lines.join("\n    ")
                ));
            }
            let mut s = subgraphs.join("\n\n  ");
            if !valid_edges.is_empty() {
                s.push_str("\n\n  ");
                s.push_str(&render_edge_list(&valid_edges));
            }
            s
        } else {
            let node_lines: Vec<String> = nodes
                .iter()
                .map(|n| format_node(n.id, n.label, n.kind))
                .collect();
            let mut s = node_lines.join("\n    ");
            s.push('\n');
            if !valid_edges.is_empty() {
                s.push_str("\n    ");
                s.push_str(&render_edge_list(&valid_edges));
            }
            s.push('\n');
            s
        };

        let mut click_vec = Vec::new();
        for n in &nodes {
            if let Some(url) = n.url {
                if !url.is_empty() {
                    click_vec.push(format!(
                        "    click {} href \"{}\" \"{}\"",
                        sanitize_id(n.id),
                        url,
                        escape_label(n.tooltip)
                    ));
                }
            }
        }
        let click_lines = if click_vec.is_empty() {
            String::new()
        } else {
            format!("\n\n{}", click_vec.join("\n"))
        };

        let theme_section = if include_theme {
            let indented_defs: Vec<&str> = MERMAID_CLASS_DEFS.split('\n').collect();
            format!(
                "\n\n  %% Semantic Visual Classes\n  {}",
                indented_defs.join("\n  ")
            )
        } else {
            String::new()
        };

        let title_section = match title {
            Some(t) => format!("--- title: {t} ---\n"),
            None => String::new(),
        };

        format!("{title_section}flowchart {layout}\n  {body}{click_lines}{theme_section}")
    };

    let trimmed_chart = chart_content.trim();
    let diagram = if wrap_code_block && !raw {
        format!("```mermaid\n{trimmed_chart}\n```")
    } else {
        trimmed_chart.to_string()
    };

    if let Some(collapse) = spec.get("collapse") {
        let always = collapse.get_bool("always").unwrap_or(false);
        let max_lines = collapse.get_i64("maxLines").unwrap_or(16) as usize;
        let summary = collapse
            .get_str("summary")
            .unwrap_or("Architecture Diagram (click to expand)");
        // Match Nix `flowchart.nix` trailing newline when counting lines in `neighborhoodDiagram`
        let line_count = diagram.split('\n').count() + if wrap_code_block && !raw { 1 } else { 0 };
        if always || line_count > max_lines {
            return Ok(format!(
                "<details>\n<summary>{summary}</summary>\n\n{}\n\n</details>",
                diagram.trim()
            ));
        }
    }

    Ok(diagram)
}

// ============================================================================
// Zero-dependency JSON Parser
// ============================================================================

#[derive(Debug)]
enum JsonValue {
    Null,
    Bool(bool),
    Int(i64),
    Str(String),
    Array(Vec<JsonValue>),
    Object(Vec<(String, JsonValue)>),
}

impl JsonValue {
    fn get(&self, key: &str) -> Option<&JsonValue> {
        match self {
            JsonValue::Object(entries) => {
                entries.iter().find(|(k, _)| k == key).map(|(_, v)| v)
            }
            _ => None,
        }
    }

    fn as_str(&self) -> Option<&str> {
        match self {
            JsonValue::Str(s) => Some(s.as_str()),
            _ => None,
        }
    }

    fn get_str(&self, key: &str) -> Option<&str> {
        self.get(key).and_then(JsonValue::as_str)
    }

    fn get_bool(&self, key: &str) -> Option<bool> {
        match self.get(key) {
            Some(JsonValue::Bool(b)) => Some(*b),
            _ => None,
        }
    }

    fn get_i64(&self, key: &str) -> Option<i64> {
        match self.get(key) {
            Some(JsonValue::Int(n)) => Some(*n),
            _ => None,
        }
    }

    fn get_array(&self, key: &str) -> Option<&[JsonValue]> {
        match self.get(key) {
            Some(JsonValue::Array(a)) => Some(a.as_slice()),
            _ => None,
        }
    }
}

struct JsonParser<'a> {
    bytes: &'a [u8],
    pos: usize,
}

impl<'a> JsonParser<'a> {
    fn new(bytes: &'a [u8]) -> Self {
        Self { bytes, pos: 0 }
    }

    fn skip_ws(&mut self) {
        while self.pos < self.bytes.len() {
            match self.bytes[self.pos] {
                b' ' | b'\t' | b'\r' | b'\n' => self.pos += 1,
                _ => break,
            }
        }
    }

    fn expect(&mut self, ch: u8) -> Result<(), String> {
        self.skip_ws();
        if self.pos < self.bytes.len() && self.bytes[self.pos] == ch {
            self.pos += 1;
            Ok(())
        } else {
            Err(format!("expected '{}' at byte {}", ch as char, self.pos))
        }
    }

    fn parse_string_map(&mut self) -> Result<Vec<(String, String)>, String> {
        self.expect(b'{')?;
        let mut out = Vec::new();
        self.skip_ws();
        if self.pos < self.bytes.len() && self.bytes[self.pos] == b'}' {
            self.pos += 1;
            return Ok(out);
        }
        loop {
            let key = self.parse_string()?;
            self.expect(b':')?;
            let val = self.parse_string()?;
            out.push((key, val));
            self.skip_ws();
            if self.pos >= self.bytes.len() {
                return Err("unexpected EOF in JSON object".into());
            }
            match self.bytes[self.pos] {
                b',' => self.pos += 1,
                b'}' => {
                    self.pos += 1;
                    break;
                }
                c => {
                    return Err(format!(
                        "unexpected byte '{}' at byte {}",
                        c as char, self.pos
                    ));
                }
            }
        }
        Ok(out)
    }

    fn parse_value(&mut self) -> Result<JsonValue, String> {
        self.skip_ws();
        if self.pos >= self.bytes.len() {
            return Err("unexpected EOF in JSON value".into());
        }
        match self.bytes[self.pos] {
            b'"' => Ok(JsonValue::Str(self.parse_string()?)),
            b'{' => self.parse_object(),
            b'[' => self.parse_array(),
            b't' => self.parse_literal(b"true", JsonValue::Bool(true)),
            b'f' => self.parse_literal(b"false", JsonValue::Bool(false)),
            b'n' => self.parse_literal(b"null", JsonValue::Null),
            b'-' | b'0'..=b'9' => self.parse_int(),
            c => Err(format!(
                "unexpected byte '{}' at byte {}",
                c as char, self.pos
            )),
        }
    }

    fn parse_literal(&mut self, lit: &[u8], val: JsonValue) -> Result<JsonValue, String> {
        if self.bytes[self.pos..].starts_with(lit) {
            self.pos += lit.len();
            Ok(val)
        } else {
            Err(format!("invalid literal at byte {}", self.pos))
        }
    }

    fn parse_int(&mut self) -> Result<JsonValue, String> {
        let start = self.pos;
        if self.bytes[self.pos] == b'-' {
            self.pos += 1;
        }
        while self.pos < self.bytes.len() && self.bytes[self.pos].is_ascii_digit() {
            self.pos += 1;
        }
        // Skip optional fractional/exponent part if present
        if self.pos < self.bytes.len() && (self.bytes[self.pos] == b'.' || self.bytes[self.pos] == b'e' || self.bytes[self.pos] == b'E') {
            while self.pos < self.bytes.len()
                && matches!(self.bytes[self.pos], b'0'..=b'9' | b'.' | b'e' | b'E' | b'+' | b'-')
            {
                self.pos += 1;
            }
            let s = std::str::from_utf8(&self.bytes[start..self.pos]).unwrap_or("0");
            let n = s.parse::<f64>().unwrap_or(0.0) as i64;
            return Ok(JsonValue::Int(n));
        }
        let s = std::str::from_utf8(&self.bytes[start..self.pos])
            .map_err(|_| "invalid number".to_string())?;
        let n = s.parse::<i64>().map_err(|_| format!("invalid int '{s}'"))?;
        Ok(JsonValue::Int(n))
    }

    fn parse_array(&mut self) -> Result<JsonValue, String> {
        self.expect(b'[')?;
        let mut out = Vec::new();
        self.skip_ws();
        if self.pos < self.bytes.len() && self.bytes[self.pos] == b']' {
            self.pos += 1;
            return Ok(JsonValue::Array(out));
        }
        loop {
            out.push(self.parse_value()?);
            self.skip_ws();
            if self.pos >= self.bytes.len() {
                return Err("unexpected EOF in JSON array".into());
            }
            match self.bytes[self.pos] {
                b',' => self.pos += 1,
                b']' => {
                    self.pos += 1;
                    break;
                }
                c => {
                    return Err(format!(
                        "unexpected byte '{}' in array at byte {}",
                        c as char, self.pos
                    ));
                }
            }
        }
        Ok(JsonValue::Array(out))
    }

    fn parse_object(&mut self) -> Result<JsonValue, String> {
        self.expect(b'{')?;
        let mut out = Vec::new();
        self.skip_ws();
        if self.pos < self.bytes.len() && self.bytes[self.pos] == b'}' {
            self.pos += 1;
            return Ok(JsonValue::Object(out));
        }
        loop {
            let key = self.parse_string()?;
            self.expect(b':')?;
            let val = self.parse_value()?;
            out.push((key, val));
            self.skip_ws();
            if self.pos >= self.bytes.len() {
                return Err("unexpected EOF in JSON object".into());
            }
            match self.bytes[self.pos] {
                b',' => self.pos += 1,
                b'}' => {
                    self.pos += 1;
                    break;
                }
                c => {
                    return Err(format!(
                        "unexpected byte '{}' in object at byte {}",
                        c as char, self.pos
                    ));
                }
            }
        }
        Ok(JsonValue::Object(out))
    }

    fn parse_string(&mut self) -> Result<String, String> {
        self.expect(b'"')?;
        let mut out = String::new();
        let mut chunk_start = self.pos;

        while self.pos < self.bytes.len() {
            match self.bytes[self.pos] {
                b'"' => {
                    if chunk_start < self.pos {
                        let s = std::str::from_utf8(&self.bytes[chunk_start..self.pos])
                            .map_err(|e| format!("invalid UTF-8: {e}"))?;
                        out.push_str(s);
                    }
                    self.pos += 1;
                    return Ok(out);
                }
                b'\\' => {
                    if chunk_start < self.pos {
                        let s = std::str::from_utf8(&self.bytes[chunk_start..self.pos])
                            .map_err(|e| format!("invalid UTF-8: {e}"))?;
                        out.push_str(s);
                    }
                    self.pos += 1;
                    if self.pos >= self.bytes.len() {
                        return Err("unterminated escape sequence".into());
                    }
                    let esc = self.bytes[self.pos];
                    self.pos += 1;
                    match esc {
                        b'"' => out.push('"'),
                        b'\\' => out.push('\\'),
                        b'/' => out.push('/'),
                        b'b' => out.push('\u{0008}'),
                        b'f' => out.push('\u{000C}'),
                        b'n' => out.push('\n'),
                        b'r' => out.push('\r'),
                        b't' => out.push('\t'),
                        b'u' => {
                            let code = self.parse_hex4()?;
                            let ch = if (0xD800..=0xDBFF).contains(&code) {
                                if self.pos + 2 > self.bytes.len()
                                    || self.bytes[self.pos] != b'\\'
                                    || self.bytes[self.pos + 1] != b'u'
                                {
                                    return Err("missing low surrogate in \\u escape".into());
                                }
                                self.pos += 2;
                                let low = self.parse_hex4()?;
                                if !(0xDC00..=0xDFFF).contains(&low) {
                                    return Err("invalid low surrogate in \\u escape".into());
                                }
                                let cp = 0x10000
                                    + (((code as u32 - 0xD800) << 10) | (low as u32 - 0xDC00));
                                char::from_u32(cp)
                                    .ok_or_else(|| "invalid unicode scalar value".to_string())?
                            } else {
                                char::from_u32(code as u32)
                                    .ok_or_else(|| "invalid unicode scalar value".to_string())?
                            };
                            out.push(ch);
                        }
                        other => return Err(format!("invalid escape '\\{}'", other as char)),
                    }
                    chunk_start = self.pos;
                }
                _ => self.pos += 1,
            }
        }
        Err("unterminated JSON string".into())
    }

    fn parse_hex4(&mut self) -> Result<u16, String> {
        if self.pos + 4 > self.bytes.len() {
            return Err("truncated \\u escape".into());
        }
        let hex = std::str::from_utf8(&self.bytes[self.pos..self.pos + 4])
            .map_err(|_| "invalid hex in \\u escape".to_string())?;
        self.pos += 4;
        u16::from_str_radix(hex, 16).map_err(|_| format!("invalid hex '{hex}'"))
    }
}
