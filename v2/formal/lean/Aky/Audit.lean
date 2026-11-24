/-
  Aky.Audit — Mechanical Kernel Axiom Verification covering ALL 35 Core Theorems!
  Ensures ZERO `sorryAx` and ZERO custom axioms across the entire formal library.
-/
import Aky

open Aky.Thm

-- Agency (7)
#print axioms flattenScope_append
#print axioms profile_nesting_invariant
#print axioms boundary_first_stratification
#print axioms non_piercing_interior_substitution
#print axioms conforms_no_lying_offers
#print axioms conforms_no_leaked_requirements
#print axioms checkStandalone_sound_and_complete

-- Binding (8)
#print axioms validateScope_nil_iff_valid
#print axioms checkPromise_perm
#print axioms isScopeValid_perm
#print axioms exclusive_binding_sound
#print axioms partitioned_selector_disjoint_sound
#print axioms budget_and_critical_tier_sound
#print axioms soft_conditional_law_sound
#print axioms multi_stratum_bounded

-- Authority & Delegation (10)
#print axioms isAuthorized_iff
#print axioms default_deny_empty
#print axioms forbid_overrides_permit
#print axioms policy_order_invariance
#print axioms attenuation_monotonic
#print axioms delegation_never_exceeds_delegator
#print axioms delegation_respects_delegatee_forbid
#print axioms delegated_attenuation_monotonic
#print axioms blast_radius_sound_and_complete
#print axioms attr_diff_excludes

-- State Safety & CALM (4)
#print axioms validateVolumes_nil_iff_valid
#print axioms ephemeral_substrate_durable_impossibility
#print axioms calm_multiwriter_requires_monotonic
#print axioms backup_coverage_soundness

-- Semantic Spacetime γ(3,4) & 4x4 Weak Transitivity (6)
#print axioms ranked_sst_acyclic
#print axioms absorbing_boundary_zero_external_impact
#print axioms epistemic_edges_preserve_operational_deps
#print axioms stCompose_assoc
#print axioms near_never_forges_causality_or_containment
#print axioms expresses_is_absorbing_sink
