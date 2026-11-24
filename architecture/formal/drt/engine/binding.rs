// Mirrors Nixconf/Spec/Binding.lean (B3 Cardinality + AttrExpr Partitioning + Priority Budgets + Multi-Stratum)

use super::agency::{Cardinality, Polarity, Promise, Strength};

#[derive(Clone, Debug)]
pub struct HandlerRule {
    pub id: String,
    pub in_stratum: u64,
    pub out_stratum: u64,
    pub emitted: Vec<Promise>,
}

fn count_matching_offers(ps: &[Promise], ptype: &str, key: &str) -> usize {
    ps.iter()
        .filter(|p| p.polarity == Polarity::Offer && p.ptype == ptype && p.key == key)
        .count()
}

fn count_matching_partition_handlers(ps: &[Promise], ptype: &str, offer_tags: &[String]) -> usize {
    ps.iter()
        .filter(|h| {
            h.polarity == Polarity::Use
                && h.cardinality == Cardinality::Partitioned
                && h.ptype == ptype
                && h.selector.eval(offer_tags)
        })
        .count()
}

fn total_budget_supply(ps: &[Promise], ptype: &str) -> u64 {
    ps.iter()
        .filter(|p| p.polarity == Polarity::Offer && p.cardinality == Cardinality::Budgeted && p.ptype == ptype)
        .map(|p| p.amount)
        .sum()
}

fn total_budget_demand(ps: &[Promise], ptype: &str) -> u64 {
    ps.iter()
        .filter(|p| p.polarity == Polarity::Use && p.cardinality == Cardinality::Budgeted && p.ptype == ptype)
        .map(|p| p.amount)
        .sum()
}

fn critical_budget_demand(ps: &[Promise], ptype: &str) -> u64 {
    ps.iter()
        .filter(|p| {
            p.polarity == Polarity::Use
                && p.cardinality == Cardinality::Budgeted
                && p.ptype == ptype
                && p.priority == 0
        })
        .map(|p| p.amount)
        .sum()
}

pub fn is_scope_valid(ps: &[Promise]) -> bool {
    for p in ps {
        if p.strength == Strength::Soft {
            match &p.soft_info {
                Some(sc) if sc.is_complete() => {}
                _ => return false,
            }
        }
        match (p.cardinality, p.polarity, p.strength, p.mandatory) {
            (Cardinality::Exclusive, Polarity::Use, Strength::Hard, true) => {
                if count_matching_offers(ps, &p.ptype, &p.key) != 1 {
                    return false;
                }
            }
            (Cardinality::Exclusive, Polarity::Offer, _, _) => {
                if count_matching_offers(ps, &p.ptype, &p.key) > 1 {
                    return false;
                }
            }
            (Cardinality::Partitioned, Polarity::Offer, _, _) => {
                if count_matching_offers(ps, &p.ptype, &p.key) > 1 {
                    return false;
                }
                if count_matching_partition_handlers(ps, &p.ptype, &p.tags) > 1 {
                    return false;
                }
            }
            (Cardinality::Budgeted, Polarity::Use, _, _) => {
                let sup = total_budget_supply(ps, &p.ptype);
                if total_budget_demand(ps, &p.ptype) > sup || critical_budget_demand(ps, &p.ptype) > sup {
                    return false;
                }
            }
            _ => {}
        }
    }
    true
}

pub fn validate_stratum_rules(rules: &[HandlerRule]) -> bool {
    rules.iter().all(|r| {
        r.in_stratum < r.out_stratum && r.emitted.iter().all(|p| p.stratum == r.out_stratum)
    })
}
