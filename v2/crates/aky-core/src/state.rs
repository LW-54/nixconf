//! `S2+` Open Composable `AttrExpr` State-As-Promise & `CALM` Monotonicity
//! mirroring `Aky/Spec/StateSafety.lean`.

use serde::{Deserialize, Serialize};

use crate::attr_expr::AttrExpr;

/// A stateful volume declared by an Agent with open composable traits.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct StateVolume {
    /// Unique volume identifier (e.g., `"vaultwarden:data"`).
    pub id: String,
    /// Owning Agent identifier.
    pub owner: String,
    /// Open composable traits (e.g., `["survives-reboot", "backup-required", "single-auth-writer"]`).
    pub traits: Vec<String>,
}

/// Storage and backup capabilities emitted by a Host's substrate.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SubstrateCapabilities {
    /// Whether the substrate offers durable local persistence across reboots.
    pub provides_durable_storage: bool,
    /// Number of bound off-host backup providers available to this host.
    pub backup_provider_count: u64,
}

/// Structured state-safety violation diagnostic.
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub enum StateError {
    /// Volume requires local persistence on an ephemeral substrate (e.g., Live-ISO).
    DurableVolumeOnEphemeralSubstrate {
        /// Offending volume identifier.
        volume_id: String,
        /// Owning agent identifier.
        owner: String,
    },
    /// Multi-writer volume is neither logically monotonic (CALM) nor single-authoritative-writer.
    CalmSplitBrainViolation {
        /// Offending volume identifier.
        volume_id: String,
        /// Owning agent identifier.
        owner: String,
    },
    /// Volume requires off-host backup but zero backup providers are bound.
    MissingBackupProvider {
        /// Offending volume identifier.
        volume_id: String,
        /// Owning agent identifier.
        owner: String,
    },
}

fn pred_needs_local_persistence() -> AttrExpr {
    AttrExpr::diff(
        AttrExpr::atom("survives-reboot"),
        AttrExpr::union(
            AttrExpr::atom("reconstructible"),
            AttrExpr::atom("external-owned"),
        ),
    )
}

fn pred_calm_safe() -> AttrExpr {
    AttrExpr::union(
        AttrExpr::compl(AttrExpr::atom("multi-writer")),
        AttrExpr::union(
            AttrExpr::atom("monotonic"),
            AttrExpr::atom("single-auth-writer"),
        ),
    )
}

fn pred_backup_required() -> AttrExpr {
    AttrExpr::atom("backup-required")
}

/// Returns `true` iff a volume's traits require durable local persistence
/// (`survives-reboot \ (reconstructible ∪ external-owned)`).
#[must_use]
pub fn needs_local_persistence(traits: &[String]) -> bool {
    pred_needs_local_persistence().eval(traits)
}

/// Returns `true` iff a volume's traits satisfy Hellerstein's CALM monotonicity law.
#[must_use]
pub fn is_calm_safe(traits: &[String]) -> bool {
    pred_calm_safe().eval(traits)
}

/// Returns `true` iff a volume's traits require an off-host backup provider.
#[must_use]
pub fn is_backup_required(traits: &[String]) -> bool {
    pred_backup_required().eval(traits)
}

/// Validates all declared state volumes against a substrate, returning structured errors.
#[must_use]
pub fn validate_volumes(sub: &SubstrateCapabilities, vs: &[StateVolume]) -> Vec<StateError> {
    let p_persist = pred_needs_local_persistence();
    let p_calm = pred_calm_safe();
    let p_backup = pred_backup_required();
    let mut errors = Vec::new();
    for v in vs {
        if p_persist.eval(&v.traits) && !sub.provides_durable_storage {
            errors.push(StateError::DurableVolumeOnEphemeralSubstrate {
                volume_id: v.id.clone(),
                owner: v.owner.clone(),
            });
        }
        if !p_calm.eval(&v.traits) {
            errors.push(StateError::CalmSplitBrainViolation {
                volume_id: v.id.clone(),
                owner: v.owner.clone(),
            });
        }
        if p_backup.eval(&v.traits) && sub.backup_provider_count == 0 {
            errors.push(StateError::MissingBackupProvider {
                volume_id: v.id.clone(),
                owner: v.owner.clone(),
            });
        }
    }
    errors
}

/// Boolean volume-safety predicate matching `Aky.Spec.allVolumesValid`.
#[must_use]
pub fn all_volumes_valid(sub: &SubstrateCapabilities, vs: &[StateVolume]) -> bool {
    validate_volumes(sub, vs).is_empty()
}
