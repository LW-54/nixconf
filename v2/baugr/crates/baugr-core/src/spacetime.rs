//! Semantic Spacetime `γ(3,4)` Epistemic Spine & Weak-Transitivity Algebra (`F-3`)
//! mirroring `Baugr/Theory/Spacetime.lean` 1:1 (DRT-locked to Lean 4!).

use std::collections::{BTreeMap, BTreeSet};

use serde::{Deserialize, Serialize};

use crate::agency::{
    Agent, Cardinality, ExteriorSurface, Polarity, Promise, epistemic_zoom_ids,
    sibling_operational_view,
};
use crate::fleet::{FleetSpec, expand_children_public};

/// The four irreducible Semantic Spacetime link meta-types (`arXiv:2506.07756`).
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Debug, Hash, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum StType {
    /// Space-like / Superagent containment hierarchy `Σ`.
    Contains,
    /// Time-like / Operational causal dependency order.
    Follows,
    /// Scalar / Expressed attributes, offers, and assessments.
    Expresses,
    /// Non-causal contextual proximity / associative link.
    Near,
}

/// Directed Semantic Spacetime edge.
#[derive(Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
pub struct StEdge {
    /// Source node identifier.
    pub src: String,
    /// Destination node identifier.
    pub dst: String,
    /// Irreducible `γ(3,4)` meta-type.
    pub sttype: StType,
}

/// Projected 4-link Semantic Spacetime graph.
#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct SstGraph {
    /// Unique node identifiers.
    pub nodes: Vec<String>,
    /// Unique directed `γ(3,4)` edges.
    pub edges: Vec<StEdge>,
}

/// 4x4 Burgess & Couch Heterogeneous Weak-Transitivity Composition Table,
/// mirroring `Baugr.Theory.stCompose` 1:1.
#[must_use]
pub const fn st_compose(r: StType, s: StType) -> Option<StType> {
    match (r, s) {
        (StType::Contains, StType::Contains) => Some(StType::Contains),
        (StType::Contains, StType::Expresses) => Some(StType::Expresses),
        (StType::Follows, StType::Follows) => Some(StType::Follows),
        (StType::Near, StType::Near) => Some(StType::Near),
        _ => None,
    }
}

/// Direct operational causal dependencies strictly follow `FOLLOWS` edges.
#[must_use]
pub fn operational_deps(graph: &SstGraph, node: &str) -> Vec<String> {
    graph
        .edges
        .iter()
        .filter(|e| e.sttype == StType::Follows && e.src == node)
        .map(|e| e.dst.clone())
        .collect()
}

/// Direct operational reverse dependents (all nodes that `FOLLOW` `target`).
#[must_use]
pub fn operational_dependents(graph: &SstGraph, target: &str) -> Vec<String> {
    graph
        .edges
        .iter()
        .filter(|e| e.sttype == StType::Follows && e.dst == target)
        .map(|e| e.src.clone())
        .collect()
}

/// Bounded transitive forward causal impact cone along `FOLLOWS` edges,
/// mirroring `Baugr.Theory.impactCone` 1:1 (returned sorted).
#[must_use]
pub fn impact_cone(graph: &SstGraph, depth: usize, seed: &[String]) -> Vec<String> {
    let mut visited: BTreeSet<String> = seed.iter().cloned().collect();
    let mut frontier: Vec<String> = seed.to_vec();
    for _ in 0..depth {
        let mut next = Vec::new();
        for n in &frontier {
            for dep in operational_deps(graph, n) {
                if visited.insert(dep.clone()) {
                    next.push(dep);
                }
            }
        }
        if next.is_empty() {
            break;
        }
        frontier = next;
    }
    visited.into_iter().collect()
}

/// Transitive reverse blast cone of downstream nodes that operationally depend on `target`,
/// mirroring `Baugr.Theory.reverseImpactCone` 1:1 (returned sorted).
#[must_use]
pub fn reverse_impact_cone(graph: &SstGraph, depth: usize, target: &str) -> Vec<String> {
    let mut visited: BTreeSet<String> = BTreeSet::new();
    visited.insert(target.to_string());
    let mut frontier = vec![target.to_string()];
    for _ in 0..depth {
        let mut next = Vec::new();
        for n in &frontier {
            for dep in operational_dependents(graph, n) {
                if visited.insert(dep.clone()) {
                    next.push(dep);
                }
            }
        }
        if next.is_empty() {
            break;
        }
        frontier = next;
    }
    visited.into_iter().collect()
}

/// Summary edge counts by `StType`.
#[must_use]
pub fn edge_counts(graph: &SstGraph) -> BTreeMap<StType, usize> {
    let mut counts = BTreeMap::new();
    for e in &graph.edges {
        let entry = counts.entry(e.sttype).or_insert(0_usize);
        *entry = entry.saturating_add(1);
    }
    counts
}

fn offer_matches_use_for_sst(o: &Promise, u: &Promise) -> bool {
    if o.polarity != Polarity::Offer || u.polarity != Polarity::Use || o.ptype != u.ptype {
        return false;
    }
    match u.cardinality {
        Cardinality::Partitioned => {
            o.cardinality == Cardinality::Partitioned && u.selector.eval(&o.tags)
        }
        Cardinality::Broadcast => u.selector.eval(&o.tags),
        Cardinality::Exclusive | Cardinality::Budgeted => o.key == u.key,
    }
}

fn surface_expresses_edges(ext: &ExteriorSurface) -> Vec<StEdge> {
    let mut out = Vec::new();
    for a in &ext.attributes {
        out.push(StEdge {
            src: ext.agent_id.clone(),
            dst: format!("attr:{a}"),
            sttype: StType::Expresses,
        });
    }
    for p in &ext.promises {
        if p.polarity == Polarity::Offer {
            out.push(StEdge {
                src: ext.agent_id.clone(),
                dst: format!("promise:{}:{}", p.ptype, p.key),
                sttype: StType::Expresses,
            });
        }
    }
    out
}

fn sibling_follows_edges(siblings: &[Agent]) -> Vec<StEdge> {
    let views = sibling_operational_view(siblings);
    let mut out = Vec::new();
    for consumer in &views {
        let uses: Vec<&Promise> = consumer
            .promises
            .iter()
            .filter(|p| p.polarity == Polarity::Use)
            .collect();
        for provider in &views {
            if provider.agent_id == consumer.agent_id {
                continue;
            }
            let hit = uses.iter().any(|u| {
                provider
                    .promises
                    .iter()
                    .any(|o| offer_matches_use_for_sst(o, u))
            });
            if hit {
                out.push(StEdge {
                    src: consumer.agent_id.clone(),
                    dst: provider.agent_id.clone(),
                    sttype: StType::Follows,
                });
            }
        }
    }
    out
}

fn project_agent_edges(agent: &Agent, out: &mut Vec<StEdge>) {
    match agent {
        Agent::Atomic { ext, .. } => out.extend(surface_expresses_edges(ext)),
        Agent::Superagent { ext, children } => {
            out.extend(surface_expresses_edges(ext));
            for cv in sibling_operational_view(children) {
                out.push(StEdge {
                    src: ext.agent_id.clone(),
                    dst: cv.agent_id.clone(),
                    sttype: StType::Contains,
                });
            }
            out.extend(sibling_follows_edges(children));
            for ch in children {
                project_agent_edges(ch, out);
            }
        }
        Agent::Profile { members } => {
            for m in members {
                project_agent_edges(m, out);
            }
        }
    }
}

/// Projects any recursive [`Agent`] tree deterministically into its 4-link SST graph,
/// mirroring `Baugr.Theory.projectAgentSST` 1:1 (DRT-locked to Lean 4!).
#[must_use]
pub fn project_agent_sst(agent: &Agent) -> SstGraph {
    let mut raw_edges = Vec::new();
    project_agent_edges(agent, &mut raw_edges);
    let edges: BTreeSet<StEdge> = raw_edges.into_iter().collect();
    let mut nodes: BTreeSet<String> = epistemic_zoom_ids(agent).into_iter().collect();
    for e in &edges {
        nodes.insert(e.src.clone());
        nodes.insert(e.dst.clone());
    }
    SstGraph {
        nodes: nodes.into_iter().collect(),
        edges: edges.into_iter().collect(),
    }
}

fn offers_match_use(
    offer_ptype: &str,
    offer_key: &str,
    offer_card: Cardinality,
    offer_tags: &[String],
    use_spec: &crate::fleet::PromiseSpec,
) -> bool {
    if offer_ptype != use_spec.ptype {
        return false;
    }
    match use_spec.cardinality {
        Cardinality::Partitioned => {
            offer_card == Cardinality::Partitioned && use_spec.selector.eval(offer_tags)
        }
        Cardinality::Broadcast => use_spec.selector.eval(offer_tags),
        Cardinality::Exclusive | Cardinality::Budgeted => offer_key == use_spec.key,
    }
}

/// Projects any [`FleetSpec`] deterministically into its 4-link Semantic Spacetime `γ(3,4)` graph
/// (`CONTAINS`, `FOLLOWS`, `EXPRESSES`, and associative `NEAR` links).
#[must_use]
pub fn project_fleet_sst(fleet: &FleetSpec) -> SstGraph {
    let mut nodes = BTreeSet::new();
    let mut edges = BTreeSet::new();

    for (aid, agent) in &fleet.agents {
        nodes.insert(aid.clone());
        for attr in &agent.attributes {
            let attr_node = format!("attr:{attr}");
            nodes.insert(attr_node.clone());
            edges.insert(StEdge {
                src: aid.clone(),
                dst: attr_node,
                sttype: StType::Expresses,
            });
        }
        for p in &agent.promises {
            if p.polarity == Polarity::Offer {
                let p_node = format!("promise:{}:{}", p.ptype, p.key);
                nodes.insert(p_node.clone());
                edges.insert(StEdge {
                    src: aid.clone(),
                    dst: p_node,
                    sttype: StType::Expresses,
                });
                for (field, val) in &p.payload {
                    if let Some(arr) = val.as_array() {
                        for item in arr {
                            if let Some(target_ref) = item.as_str() {
                                let near_node = format!("ref:{field}:{target_ref}");
                                nodes.insert(near_node.clone());
                                edges.insert(StEdge {
                                    src: aid.clone(),
                                    dst: near_node,
                                    sttype: StType::Near,
                                });
                            }
                        }
                    }
                }
            }
        }

        if agent.is_superagent() {
            let children = expand_children_public(fleet, agent);
            for ch in &children {
                nodes.insert(ch.agent.clone());
                edges.insert(StEdge {
                    src: aid.clone(),
                    dst: ch.agent.clone(),
                    sttype: StType::Contains,
                });
            }
            for consumer in &children {
                let Some(c_manifest) = fleet.agents.get(&consumer.agent) else {
                    continue;
                };
                for use_spec in c_manifest
                    .promises
                    .iter()
                    .filter(|p| p.polarity == Polarity::Use)
                {
                    for provider in &children {
                        if provider.agent == consumer.agent {
                            continue;
                        }
                        let Some(p_manifest) = fleet.agents.get(&provider.agent) else {
                            continue;
                        };
                        let matches = p_manifest
                            .promises
                            .iter()
                            .filter(|o| o.polarity == Polarity::Offer)
                            .any(|o| {
                                offers_match_use(&o.ptype, &o.key, o.cardinality, &o.tags, use_spec)
                            });
                        if matches {
                            edges.insert(StEdge {
                                src: consumer.agent.clone(),
                                dst: provider.agent.clone(),
                                sttype: StType::Follows,
                            });
                        }
                    }
                }
            }
        }
    }

    SstGraph {
        nodes: nodes.into_iter().collect(),
        edges: edges.into_iter().collect(),
    }
}

#[cfg(test)]
mod tests {
    use super::{SstGraph, StEdge, StType, impact_cone, reverse_impact_cone, st_compose};

    #[test]
    fn st_compose_enforces_weak_transitivity_laws() {
        assert_eq!(
            st_compose(StType::Contains, StType::Contains),
            Some(StType::Contains)
        );
        assert_eq!(
            st_compose(StType::Contains, StType::Expresses),
            Some(StType::Expresses)
        );
        assert_eq!(
            st_compose(StType::Follows, StType::Follows),
            Some(StType::Follows)
        );
        assert_eq!(st_compose(StType::Near, StType::Near), Some(StType::Near));
        assert_eq!(st_compose(StType::Near, StType::Follows), None);
        assert_eq!(st_compose(StType::Expresses, StType::Contains), None);
    }

    #[test]
    fn impact_cones_follow_only_causal_edges() {
        let g = SstGraph {
            nodes: vec!["a".into(), "b".into(), "c".into(), "d".into()],
            edges: vec![
                StEdge {
                    src: "a".into(),
                    dst: "b".into(),
                    sttype: StType::Follows,
                },
                StEdge {
                    src: "b".into(),
                    dst: "c".into(),
                    sttype: StType::Follows,
                },
                StEdge {
                    src: "b".into(),
                    dst: "d".into(),
                    sttype: StType::Near,
                },
            ],
        };
        assert_eq!(impact_cone(&g, 4, &["a".to_string()]), vec!["a", "b", "c"]);
        assert_eq!(reverse_impact_cone(&g, 4, "c"), vec!["a", "b", "c"]);
    }
}
