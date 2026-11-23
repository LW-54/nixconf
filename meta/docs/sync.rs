use std::collections::HashSet;
use std::env;
use std::fs;
use std::io;
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 4 {
        eprintln!("Usage: nixconf-docs-sync <materialize|write|check> <src> <dst>");
        process::exit(2);
    }

    let res = match args[1].as_str() {
        "materialize" => cmd_materialize(Path::new(&args[2]), Path::new(&args[3])),
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

/// Parses a flat JSON object mapping relative paths to UTF-8 file contents
/// (as produced by `builtins.toJSON`) and writes every file under `out_dir`.
fn cmd_materialize(manifest_path: &Path, out_dir: &Path) -> io::Result<()> {
    let bytes = fs::read(manifest_path)?;
    let mut parser = JsonParser::new(&bytes);
    let entries = parser
        .parse_string_map()
        .map_err(|msg| io::Error::new(io::ErrorKind::InvalidData, msg))?;

    fs::create_dir_all(out_dir)?;
    for (rel, content) in entries {
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
