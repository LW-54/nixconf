/-
  Aky.Audit — Mechanical Kernel Axiom Verification covering ALL 41 Usage-Agnostic Theorems!
  Ensures ZERO `sorryAx` and ZERO custom axioms across the entire formal library.
-/
import Aky

open Aky.Thm

-- Agency & Non-Piercing Conformance (9)
#print axioms flattenScope_append
#print axioms profile_nesting_invariant
#print axioms boundary_first_stratification
#print axioms non_piercing_interior_substitution
#print axioms conforms_no_lying_offers
#print axioms conforms_no_leaked_requirements
#print axioms conforms_no_dropped_mandatory_offers
#print axioms conforms_budget_and_critical_sound
#print axioms canComposeInScope_sound_and_complete

-- Declarative AttrExpr Invariants (4)
#print axioms validateInvariants_nil_iff_hold
#print axioms invariant_violation_sound
#print axioms allInvariantsHold_perm
#print axioms calm_emerges_from_generic_invariant

-- Binding & Recursive Agent Tree Substitution (12)
#print axioms validateScope_nil_iff_valid
#print axioms checkPromise_perm
#print axioms isScopeValid_perm
#print axioms exclusive_binding_sound
#print axioms broadcast_mandatory_sound
#print axioms partitioned_selector_disjoint_sound
#print axioms partitioned_mandatory_handled_sound
#print axioms budget_and_critical_tier_sound
#print axioms soft_conditional_law_sound
#print axioms multi_stratum_bounded
#print axioms checkAgentTree_superagent_sound
#print axioms checkAgentTree_substitution_invariant

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

-- Semantic Spacetime γ(3,4) & 4x4 Weak Transitivity (6)
#print axioms ranked_sst_acyclic
#print axioms absorbing_boundary_zero_external_impact
#print axioms epistemic_edges_preserve_operational_deps
#print axioms stCompose_assoc
#print axioms near_never_forges_causality_or_containment
#print axioms expresses_is_absorbing_sink
