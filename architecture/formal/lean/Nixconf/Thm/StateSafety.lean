/-
  Nixconf.Thm.StateSafety — Layer 2 Machine-Checked Proofs (1:1 mirror of Nixconf.Spec.StateSafety)
  Zero `sorry`. Proves Open Composable Trait (`AttrExpr`) Ephemeral-Substrate Impossibility,
  Hellerstein CALM Logical Monotonicity, Backup Coverage, and Diagnostic Completeness (Gap #3 CLOSED!).
-/

import Nixconf.Data.ListLemmas
import Nixconf.Spec.StateSafety

namespace Nixconf.Thm

open Nixconf.Data
open Nixconf.Spec

/-- Structured Diagnostics Equivalence: zero state errors iff `allVolumesValid = true`. -/
theorem validateVolumes_nil_iff_valid (sub : SubstrateCapabilities) (vs : List StateVolume) :
    validateVolumes sub vs = [] ↔ allVolumesValid sub vs = true := by
  unfold validateVolumes allVolumesValid
  simp only [List.flatMap_eq_nil_iff, List.all_eq_true, List.isEmpty_iff]

/--
  GAP #3 CLOSED — Open-Trait Ephemeral-Substrate Durable Impossibility (Live-ISO Safety):
  On any ephemeral-only substrate (`providesDurableStorage = false`), ANY volume expressing
  `predNeedsLocalPersistence` (`survives-reboot \ (reconstructible ∪ external-owned)`) is rejected!
-/
theorem ephemeral_substrate_durable_impossibility
    (sub : SubstrateCapabilities) (hEph : sub.providesDurableStorage = false)
    (vs : List StateVolume) (v : StateVolume) (hv : v ∈ vs)
    (hPersist : predNeedsLocalPersistence.eval v.traits = true) :
    allVolumesValid sub vs = false := by
  unfold allVolumesValid
  cases h : vs.all (fun x => (checkVolume sub x).isEmpty) with
  | false => rfl
  | true =>
    rw [List.all_eq_true] at h
    have hv' := h v hv
    unfold checkVolume at hv'
    rw [hPersist, hEph] at hv'
    simp at hv'

/--
  GAP #3 CLOSED — Open-Trait CALM Logical Monotonicity Theorem (Hellerstein & Alvaro):
  If a volume is accepted (`allVolumesValid = true`) AND carries tag `"multi-writer"` WITHOUT
  `"single-auth-writer"`, it MUST carry tag `"monotonic"`!
-/
theorem calm_multiwriter_requires_monotonic
    (sub : SubstrateCapabilities) (vs : List StateVolume)
    (hValid : allVolumesValid sub vs = true)
    (v : StateVolume) (hv : v ∈ vs)
    (hMulti : v.traits.contains "multi-writer" = true)
    (hNoSingle : v.traits.contains "single-auth-writer" = false) :
    v.traits.contains "monotonic" = true := by
  unfold allVolumesValid at hValid
  rw [List.all_eq_true] at hValid
  have hv' := hValid v hv
  unfold checkVolume at hv'
  rw [append_isEmpty_iff, List.append_eq_nil_iff] at hv'
  have hCalm := hv'.1.2
  cases hPred : predCalmSafe.eval v.traits with
  | false => rw [hPred] at hCalm; simp at hCalm
  | true =>
    unfold predCalmSafe at hPred
    simp only [AttrExpr.eval, hMulti, hNoSingle, Bool.not_true, Bool.false_or, Bool.or_false] at hPred
    exact hPred

/-- Open-Trait Backup Coverage Soundness. -/
theorem backup_coverage_soundness
    (sub : SubstrateCapabilities) (vs : List StateVolume)
    (hValid : allVolumesValid sub vs = true)
    (v : StateVolume) (hv : v ∈ vs)
    (hBak : v.traits.contains "backup-required" = true) :
    sub.backupProviderCount > 0 := by
  unfold allVolumesValid at hValid
  rw [List.all_eq_true] at hValid
  have hv' := hValid v hv
  unfold checkVolume at hv'
  rw [append_isEmpty_iff] at hv'
  have hB := hv'.2
  unfold predBackupRequired at hB
  simp only [AttrExpr.eval, hBak, Bool.true_and] at hB
  by_cases hZero : sub.backupProviderCount == 0
  · rw [hZero] at hB; simp at hB
  · simp only [beq_iff_eq] at hZero; omega

end Nixconf.Thm
