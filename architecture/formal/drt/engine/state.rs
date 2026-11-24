// Mirrors Nixconf/Spec/StateSafety.lean (Open Composable AttrExpr State Traits + CALM Monotonicity)

use super::attr_expr::AttrExpr;

#[derive(Clone, Debug)]
pub struct StateVolume {
    pub id: String,
    pub owner: String,
    pub traits: Vec<String>,
}

#[derive(Clone, Debug)]
pub struct SubstrateCapabilities {
    pub provides_durable_storage: bool,
    pub backup_provider_count: u64,
}

fn pred_needs_local_persistence() -> AttrExpr {
    AttrExpr::Diff(
        Box::new(AttrExpr::Atom("survives-reboot".into())),
        Box::new(AttrExpr::Union(
            Box::new(AttrExpr::Atom("reconstructible".into())),
            Box::new(AttrExpr::Atom("external-owned".into())),
        )),
    )
}

fn pred_calm_safe() -> AttrExpr {
    AttrExpr::Union(
        Box::new(AttrExpr::Compl(Box::new(AttrExpr::Atom("multi-writer".into())))),
        Box::new(AttrExpr::Union(
            Box::new(AttrExpr::Atom("monotonic".into())),
            Box::new(AttrExpr::Atom("single-auth-writer".into())),
        )),
    )
}

fn pred_backup_required() -> AttrExpr {
    AttrExpr::Atom("backup-required".into())
}

pub fn all_volumes_valid(sub: &SubstrateCapabilities, vs: &[StateVolume]) -> bool {
    let p_persist = pred_needs_local_persistence();
    let p_calm = pred_calm_safe();
    let p_backup = pred_backup_required();
    vs.iter().all(|v| {
        let persist_ok = !p_persist.eval(&v.traits) || sub.provides_durable_storage;
        let calm_ok = p_calm.eval(&v.traits);
        let backup_ok = !p_backup.eval(&v.traits) || sub.backup_provider_count > 0;
        persist_ok && calm_ok && backup_ok
    })
}
