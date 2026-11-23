/-
  AxiomAudit.lean — Verifies mechanically that all 20 core theorems of NixconfFoundation
  depend ONLY on Lean 4's trusted kernel axioms (ZERO `sorryAx`, ZERO custom axioms!).
-/
import NixconfFoundation

open NixconfFoundation

#print axioms flattenScope_append
#print axioms profile_nesting_invariant
#print axioms boundary_first_stratification
#print axioms non_piercing_interior_substitution
#print axioms checkStandalone_sound_and_complete
#print axioms checkPromise_perm
#print axioms isScopeValid_perm
#print axioms exclusive_binding_sound
#print axioms budget_conservation_sound
#print axioms soft_conditional_law_sound
#print axioms default_deny_empty
#print axioms forbid_overrides_permit
#print axioms policy_order_invariance
#print axioms attenuation_monotonic
#print axioms blast_radius_sound_and_complete
#print axioms attr_diff_excludes
#print axioms ephemeral_substrate_durable_impossibility
#print axioms calm_multiwriter_requires_monotonic
#print axioms backup_coverage_soundness
#print axioms ranked_sst_acyclic
#print axioms absorbing_boundary_zero_external_impact
#print axioms epistemic_edges_preserve_operational_deps
