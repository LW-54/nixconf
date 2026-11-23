/-
  NixconfFoundation.StateSafety
  Formalization of ADR-0004 (S2+ Mandatory Agent-Declared State-As-Promise with Open Composable Traits)
  and RES-0013 (Hellerstein & Alvaro's CALM Theorem Logical Monotonicity Law).

  Pure Lean 4 core (zero Mathlib). Every theorem is machine-checked without `sorry`.
-/

namespace NixconfFoundation

/--
  Open Composable State Traits (S2+):
  Avoids a rigid closed enum so nuanced workloads (e.g. persistent yet loss-tolerable TSDB,
  monotonic reconstructible binary cache, externally-owned WSL mounts) express cleanly.
-/
structure StateTraits where
  reconstructible   : Bool -- Zero loss cost if wiped (e.g., /nix/store, Attic cache)
  survivesReboot    : Bool -- Requires persistence across reboots/impermanence
  monotonic         : Bool -- CALM join-semilattice / content-addressed / conflict-preserving
  multiWriter       : Bool -- Mutated concurrently across multiple agents/hosts
  singleAuthWriter  : Bool -- Serialized through one authoritative writer owner
  backupRequired    : Bool -- Requires off-host backup replication
  externalOwned     : Bool -- Owned outside host substrate (e.g., WSL /mnt/c, SaaS)
  deriving Repr, DecidableEq, BEq

structure StateVolume where
  id     : String
  owner  : String
  traits : StateTraits
  deriving Repr, DecidableEq, BEq

structure SubstrateCapabilities where
  providesDurableStorage : Bool -- false on Live-ISO / ephemeral squashfs
  backupProviderCount    : Nat  -- Broadcast 1:N backup observers bound to host
  deriving Repr, DecidableEq, BEq

def needsLocalPersistence (v : StateVolume) : Bool :=
  v.traits.survivesReboot && !v.traits.reconstructible && !v.traits.externalOwned

def calmValid (v : StateVolume) : Bool :=
  !v.traits.multiWriter || v.traits.monotonic || v.traits.singleAuthWriter

def volumeValidOnSubstrate (sub : SubstrateCapabilities) (v : StateVolume) : Bool :=
  (!needsLocalPersistence v || sub.providesDurableStorage) &&
  calmValid v &&
  (!v.traits.backupRequired || sub.backupProviderCount > 0)

def allVolumesValid (sub : SubstrateCapabilities) (vs : List StateVolume) : Bool :=
  vs.all (volumeValidOnSubstrate sub)

-- === MACHINE-CHECKED STATE SAFETY THEOREMS ===

/--
  THEOREM 15 (Ephemeral-Substrate Durable Impossibility — Live-ISO Safety):
  On any ephemeral-only substrate (`providesDurableStorage = false`, e.g. Live-ISO),
  ANY agent declaring a non-reconstructible, non-external persistent volume (`survivesReboot = true`)
  is GUARANTEED to be rejected (`allVolumesValid = false`)!
-/
theorem ephemeral_substrate_durable_impossibility
    (sub : SubstrateCapabilities) (hEph : sub.providesDurableStorage = false)
    (vs : List StateVolume) (v : StateVolume) (hv : v ∈ vs)
    (hPersist : needsLocalPersistence v = true) :
    allVolumesValid sub vs = false := by
  unfold allVolumesValid
  cases h : vs.all (volumeValidOnSubstrate sub) with
  | false => rfl
  | true =>
    rw [List.all_eq_true] at h
    have hv' := h v hv
    unfold volumeValidOnSubstrate at hv'
    rw [hPersist, hEph] at hv'
    simp at hv'

/--
  THEOREM 16 (CALM Coordination Soundness — Hellerstein & Alvaro):
  If a state volume is accepted (`allVolumesValid = true`) AND allows concurrent `multiWriter = true`
  WITHOUT a single authoritative writer (`singleAuthWriter = false`), it MUST be logically `monotonic = true`!
-/
theorem calm_multiwriter_requires_monotonic
    (sub : SubstrateCapabilities) (vs : List StateVolume)
    (hValid : allVolumesValid sub vs = true)
    (v : StateVolume) (hv : v ∈ vs)
    (hMulti : v.traits.multiWriter = true)
    (hNoSingle : v.traits.singleAuthWriter = false) :
    v.traits.monotonic = true := by
  unfold allVolumesValid at hValid
  rw [List.all_eq_true] at hValid
  have hv' := hValid v hv
  unfold volumeValidOnSubstrate calmValid at hv'
  rw [hMulti, hNoSingle] at hv'
  simp at hv'
  exact hv'.1.2

/--
  THEOREM 17 (Backup Coverage Soundness):
  If `allVolumesValid = true`, every volume with `backupRequired = true` has at least one
  active backup observer (`backupProviderCount > 0`).
-/
theorem backup_coverage_soundness
    (sub : SubstrateCapabilities) (vs : List StateVolume)
    (hValid : allVolumesValid sub vs = true)
    (v : StateVolume) (hv : v ∈ vs)
    (hBak : v.traits.backupRequired = true) :
    sub.backupProviderCount > 0 := by
  unfold allVolumesValid at hValid
  rw [List.all_eq_true] at hValid
  have hv' := hValid v hv
  unfold volumeValidOnSubstrate at hv'
  rw [hBak] at hv'
  simp at hv'
  exact hv'.2

end NixconfFoundation
