//! **Baugr Doc (`baugr-doc`)** — Pure Unix filter transforming `baugr graph --json`
//! Semantic Spacetime `γ(3,4)` JSON on `stdin` into clean `mdBook`-compatible Markdown
//! + node-capped Mermaid diagrams (`SUMMARY.md`, `index.md`, `scopes/*.md`).
//!
//! Zero Nix, zero Linux, zero domain strings!

use std::collections::{BTreeMap, BTreeSet};
use std::fmt::Write as _;
use std::fs;
use std::io::{self, Read};
use std::path::PathBuf;
use std::process::ExitCode;

use baugr_core::spacetime::{SstGraph, StType, edge_counts};
use clap::Parser;
use serde::Deserialize;
use thiserror::Error;

/// Maximum Mermaid nodes per diagram (enforces visual clarity).
const MAX_DIAGRAM_NODES: usize = 20;

/// Pure Unix SST -> Markdown/Mermaid filter.
#[derive(Debug, Parser)]
#[command(
    name = "baugr-doc",
    version,
    about = "Read `baugr graph --json` on stdin and emit mdBook Markdown + Mermaid docs"
)]
struct Cli {
    /// Output directory for generated Markdown (`SUMMARY.md`, `index.md`, `scopes/`).
    #[arg(long)]
    out: PathBuf,

    /// Book title shown in `index.md`.
    #[arg(long, default_value = "Semantic Spacetime Architecture")]
    title: String,
}

#[derive(Debug, Deserialize)]
struct GraphEnvelope {
    graph: SstGraph,
}

#[derive(Debug, Error)]
enum DocError {
    #[error("failed reading stdin: {0}")]
    Stdin(#[from] io::Error),
    #[error("invalid JSON input on stdin (expected `baugr graph --json`): {0}")]
    Json(#[from] serde_json::Error),
}

fn mermaid_id(raw: &str) -> String {
    raw.chars()
        .map(|c| if c.is_ascii_alphanumeric() { c } else { '_' })
        .collect()
}

fn render_scope_page(scope_id: &str, children: &[String], graph: &SstGraph) -> String {
    let mut md = String::new();
    let _ = writeln!(md, "# Superagent `{scope_id}`\n");
    let _ = writeln!(md, "Direct children (`CONTAINS`): {}\n", children.len());

    let child_set: BTreeSet<&str> = children.iter().map(String::as_str).collect();
    let internal_follows: Vec<(&str, &str)> = graph
        .edges
        .iter()
        .filter(|e| {
            e.sttype == StType::Follows
                && child_set.contains(e.src.as_str())
                && child_set.contains(e.dst.as_str())
        })
        .map(|e| (e.src.as_str(), e.dst.as_str()))
        .collect();

    md.push_str("## Containment & Operational Flow\n\n```mermaid\nflowchart LR\n");
    for ch in children.iter().take(MAX_DIAGRAM_NODES) {
        let id = mermaid_id(ch);
        let _ = writeln!(md, "    {id}[\"{ch}\"]");
    }
    let shown: BTreeSet<&str> = children
        .iter()
        .take(MAX_DIAGRAM_NODES)
        .map(String::as_str)
        .collect();
    for (src, dst) in &internal_follows {
        if shown.contains(src) && shown.contains(dst) {
            let _ = writeln!(md, "    {} --> {}", mermaid_id(src), mermaid_id(dst));
        }
    }
    md.push_str("```\n");
    if children.len() > MAX_DIAGRAM_NODES {
        let _ = writeln!(
            md,
            "\n> Note: Diagram capped at {MAX_DIAGRAM_NODES} nodes ({} total children listed below).\n",
            children.len()
        );
    }

    md.push_str("\n## Direct Children\n\n");
    for ch in children {
        let _ = writeln!(md, "- `{ch}`");
    }

    let near_links: Vec<&str> = graph
        .edges
        .iter()
        .filter(|e| e.sttype == StType::Near && e.src == scope_id)
        .map(|e| e.dst.as_str())
        .collect();
    if !near_links.is_empty() {
        md.push_str("\n## Associative Links (`NEAR`)\n\n");
        for link in near_links {
            let _ = writeln!(md, "- `{link}`");
        }
    }
    md
}

fn run(cli: &Cli) -> Result<(), DocError> {
    let mut raw = String::new();
    io::stdin().read_to_string(&mut raw)?;
    let env: GraphEnvelope = serde_json::from_str(&raw)?;
    let graph = env.graph;

    let mut contains_map: BTreeMap<String, Vec<String>> = BTreeMap::new();
    for e in &graph.edges {
        if e.sttype == StType::Contains {
            contains_map
                .entry(e.src.clone())
                .or_default()
                .push(e.dst.clone());
        }
    }
    for kids in contains_map.values_mut() {
        kids.sort();
        kids.dedup();
    }

    let scopes_dir = cli.out.join("scopes");
    fs::create_dir_all(&scopes_dir)?;

    let counts = edge_counts(&graph);
    let mut index = String::new();
    let _ = writeln!(index, "# {}\n", cli.title);
    let _ = writeln!(
        index,
        "- **Nodes**: {}\n- **Edges**: {} (`CONTAINS`: {}, `FOLLOWS`: {}, `EXPRESSES`: {}, `NEAR`: {})\n",
        graph.nodes.len(),
        graph.edges.len(),
        counts.get(&StType::Contains).copied().unwrap_or(0),
        counts.get(&StType::Follows).copied().unwrap_or(0),
        counts.get(&StType::Expresses).copied().unwrap_or(0),
        counts.get(&StType::Near).copied().unwrap_or(0),
    );
    index.push_str("## Superagent Scopes\n\n");

    let mut summary = String::from("# Summary\n\n- [Overview](./index.md)\n");
    for (scope_id, children) in &contains_map {
        let slug = mermaid_id(scope_id);
        let rel = format!("scopes/{slug}.md");
        let _ = writeln!(
            index,
            "- [`{scope_id}`](./{rel}) ({} children)",
            children.len()
        );
        let _ = writeln!(summary, "  - [{scope_id}](./{rel})");
        let page = render_scope_page(scope_id, children, &graph);
        fs::write(scopes_dir.join(format!("{slug}.md")), page)?;
    }

    fs::write(cli.out.join("index.md"), index)?;
    fs::write(cli.out.join("SUMMARY.md"), summary)?;
    Ok(())
}

fn main() -> ExitCode {
    let cli = Cli::parse();
    match run(&cli) {
        Ok(()) => ExitCode::SUCCESS,
        Err(err) => {
            eprintln!("baugr-doc error: {err}");
            ExitCode::FAILURE
        }
    }
}
