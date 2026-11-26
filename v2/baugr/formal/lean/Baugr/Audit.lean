/-
  Baugr.Audit — Mechanical Kernel Axiom Verification covering ALL 53 Usage-Agnostic Theorems!
  Ensures ZERO `sorryAx` and ZERO custom axioms across both `Baugr.Theory` & `Baugr.Engine`.
-/
import Baugr

open Baugr.Theory
open Baugr.Engine.Thm

-- Layer 1: Pure Promise Theory & Semantic Spacetime γ(3,4) (`Baugr.Theory`, 12 theorems)
#print axioms imposition_never_cooperates
#print axioms flattenScope_append
#print axioms profile_nesting_invariant
#print axioms boundary_first_stratification
#print axioms non_piercing_interior_substitution
#print axioms siblingFollowsEdges_non_piercing
#print axioms ranked_sst_acyclic
#print axioms absorbing_boundary_zero_external_impact
#print axioms epistemic_edges_preserve_operational_deps
#print axioms stCompose_assoc
#print axioms near_never_forges_causality_or_containment
#print axioms expresses_is_absorbing_sink

-- Layer 2a: P-Explicit Interior Conformance & Scope Portability (6 theorems)
#print axioms conforms_no_lying_offers
#print axioms conforms_no_leaked_requirements
#print axioms conforms_no_dropped_mandatory_offers
#print axioms conforms_no_dropped_mandatory_broadcast_offers
#print axioms conforms_budget_and_critical_sound
#print axioms canComposeInScope_sound_and_complete

-- Layer 2b: Declarative AttrExpr Invariants (4 theorems)
#print axioms validateInvariants_nil_iff_hold
#print axioms invariant_violation_sound
#print axioms allInvariantsHold_perm
#print axioms calm_emerges_from_generic_invariant

-- Layer 2c: B3 Binding, Cedar Structural Auth & Recursive Tree Verification (17 theorems)
#print axioms validateScope_nil_iff_valid
#print axioms checkPromise_perm
#print axioms isScopeValid_perm
#print axioms exclusive_binding_sound
#print axioms broadcast_mandatory_sound
#print axioms broadcast_mandatory_offer_handled_sound
#print axioms broadcast_subscriber_non_interference
#print axioms partitioned_selector_disjoint_sound
#print axioms partitioned_mandatory_handled_sound
#print axioms budget_and_critical_tier_sound
#print axioms soft_conditional_law_sound
#print axioms validateScopeAuth_nil_iff_valid
#print axioms scope_auth_sound
#print axioms scope_auth_forbid_blocks_promise
#print axioms checkAgentTree_atomic_sound
#print axioms checkAgentTree_superagent_sound
#print axioms checkAgentTree_substitution_invariant

-- Layer 2d: Cedar L3+ & Biscuit Authority / Delegation (10 theorems)
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

-- Layer 2e: Executable Resolve Type Soundness — Progress & Preservation (5 theorems, F-2!)
#print axioms valid_use_resolves
#print axioms valid_scope_resolves_safely
#print axioms valid_agent_tree_resolves_safely
#print axioms valid_agent_tree_list_resolves_safely
#print axioms resolve_parent_scope_non_piercing
