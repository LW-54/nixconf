// Mirrors Nixconf/Spec/Agency.lean (Fractal Agency + P-Explicit Interior Conformance)

use super::attr_expr::AttrExpr;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Polarity { Offer, Use }

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Strength { Hard, Soft }

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum Cardinality { Exclusive, Broadcast, Partitioned, Budgeted }

#[derive(Clone, Debug)]
pub struct SoftContract {
    pub condition_ref: String,
    pub degraded_mode: String,
    pub probe_id: String,
}

impl SoftContract {
    pub fn is_complete(&self) -> bool {
        !self.condition_ref.is_empty() && !self.degraded_mode.is_empty() && !self.probe_id.is_empty()
    }
}

#[derive(Clone, Debug)]
pub struct Promise {
    pub id: String,
    pub ptype: String,
    pub key: String,
    pub polarity: Polarity,
    pub strength: Strength,
    pub cardinality: Cardinality,
    pub mandatory: bool,
    pub amount: u64,
    pub priority: u64,
    pub stratum: u64,
    pub tags: Vec<String>,
    pub selector: AttrExpr,
    pub soft_info: Option<SoftContract>,
}

#[derive(Clone, Debug)]
pub struct ExteriorSurface {
    pub agent_id: String,
    pub promises: Vec<Promise>,
    pub attributes: Vec<String>,
}

pub fn is_mandatory_hard_use(p: &Promise) -> bool {
    p.polarity == Polarity::Use && p.strength == Strength::Hard && p.mandatory
}

fn has_offer(ps: &[&Promise], ptype: &str, key: &str) -> bool {
    ps.iter().any(|p| p.polarity == Polarity::Offer && p.ptype == ptype && p.key == key)
}

fn has_use(ps: &[Promise], ptype: &str, key: &str) -> bool {
    ps.iter().any(|p| p.polarity == Polarity::Use && p.ptype == ptype && p.key == key)
}

/// P-Explicit Interior Conformance Check (Gap #1 CLOSED):
///   1. Every `+b` exported in `ext` must be backed by some interior child offer (no lying offers).
///   2. Every unmet mandatory hard `-b` inside `children` must be declared in `ext` (no leaked deps).
pub fn superagent_conforms(ext: &ExteriorSurface, children: &[ExteriorSurface]) -> bool {
    let int_ps: Vec<&Promise> = children.iter().flat_map(|c| c.promises.iter()).collect();
    for p in &ext.promises {
        if p.polarity == Polarity::Offer && !has_offer(&int_ps, &p.ptype, &p.key) {
            return false;
        }
    }
    for p in &int_ps {
        if is_mandatory_hard_use(p) && !has_offer(&int_ps, &p.ptype, &p.key) && !has_use(&ext.promises, &p.ptype, &p.key) {
            return false;
        }
    }
    true
}
