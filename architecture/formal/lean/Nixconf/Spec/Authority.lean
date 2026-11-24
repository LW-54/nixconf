/-
  Nixconf.Spec.Authority — Layer 1 Executable Specification (NO PROOFS)
  L3+ Boolean Set-Algebra Authorization Lattice (using shared `Nixconf.Data.AttrExpr`),
  AWS Cedar Default-Deny + forbid-overrides-permit + Diagnostic AuthResponse,
  Biscuit Offline Monotonic Attenuation, Combined Cross-Boundary Delegation (Gap #4 CLOSED!),
  and Mechanical Blast-Radius Revocation (ADR-0006 C1).
-/

import Nixconf.Data.AttrExpr

namespace Nixconf.Spec

open Nixconf.Data

inductive Effect where
  | permit
  | forbid
  deriving Repr, DecidableEq, BEq

inductive Decision where
  | allow
  | deny
  deriving Repr, DecidableEq, BEq

structure AuthPolicy where
  id            : String
  effect        : Effect
  action        : String
  principalPred : AttrExpr
  resourcePred  : AttrExpr
  deriving Repr, DecidableEq, BEq

structure Entity where
  id   : String
  tags : List String
  deriving Repr, DecidableEq, BEq

/-- Structured AWS Cedar-style response carrying both verdict AND human/AI explainability IDs. -/
structure AuthResponse where
  decision            : Decision
  determiningPolicies : List String
  deriving Repr, DecidableEq, BEq

def AuthPolicy.matches (pol : AuthPolicy) (principal : Entity) (action : String) (resource : Entity) : Bool :=
  pol.action == action &&
  pol.principalPred.eval principal.tags &&
  pol.resourcePred.eval resource.tags

/-- Core Cedar authorizer with structured diagnostic explanation. -/
def authorize (policies : List AuthPolicy) (principal : Entity) (action : String) (resource : Entity) : AuthResponse :=
  let permits := policies.filter (fun p => p.effect == Effect.permit && p.matches principal action resource)
  let forbids := policies.filter (fun p => p.effect == Effect.forbid && p.matches principal action resource)
  if !forbids.isEmpty then
    { decision := Decision.deny, determiningPolicies := forbids.map (·.id) }
  else if !permits.isEmpty then
    { decision := Decision.allow, determiningPolicies := permits.map (·.id) }
  else
    { decision := Decision.deny, determiningPolicies := [] }

def isAuthorized (policies : List AuthPolicy) (principal : Entity) (action : String) (resource : Entity) : Bool :=
  (authorize policies principal action resource).decision == Decision.allow

/-- Biscuit-style offline-verifiable attenuated capability (append-only narrowing caveats). -/
structure Capability where
  rootPolicyId  : String
  allowedAction : String
  caveats       : List AttrExpr
  deriving Repr, DecidableEq, BEq

def Capability.attenuate (cap : Capability) (extra : AttrExpr) : Capability :=
  { cap with caveats := cap.caveats ++ [extra] }

def Capability.allows (cap : Capability) (action : String) (resource : Entity) : Bool :=
  cap.allowedAction == action && cap.caveats.all (fun c => c.eval resource.tags)

/--
  Combined Cross-Boundary Delegation Evaluator (Gap #4 CLOSED!):
  When `delegator` delegates attenuated capability `cap` to `delegatee` (e.g. `agy` or CI),
  the request is allowed IFF:
    1. `delegator` itself is authorized by `policies` (no privilege creation from thin air),
    2. `cap` allows `(action, resource)` under all appended caveats, AND
    3. NO `forbid` policy in `policies` explicitly blocks `delegatee` on `(action, resource)`!
-/
def hasForbid (policies : List AuthPolicy) (principal : Entity) (action : String) (resource : Entity) : Bool :=
  policies.any (fun p => p.effect == Effect.forbid && p.matches principal action resource)

def isDelegatedAuthorized
    (policies : List AuthPolicy) (delegator delegatee : Entity)
    (cap : Capability) (action : String) (resource : Entity) : Bool :=
  isAuthorized policies delegator action resource &&
  cap.allows action resource &&
  !hasForbid policies delegatee action resource

/-- Mechanical Blast-Radius Revocation (ADR-0006 C1). -/
def blastRadius (policies : List AuthPolicy) (principal : Entity) (action : String) (allResources : List Entity) : List Entity :=
  allResources.filter (fun r => isAuthorized policies principal action r)

end Nixconf.Spec
