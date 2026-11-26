/-
  Baugr.Engine.Authority — Cedar L3+ Authorization, Biscuit Attenuation & Delegation
  100% Usage-Agnostic: default-deny, `forbid`-overrides-`permit`, diagnostic `AuthResponse`,
  offline monotonic attenuation, combined cross-boundary delegation, and blast-radius revocation.
-/

import Baugr.Data.AttrExpr

namespace Baugr.Engine

open Baugr.Data

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

structure AuthResponse where
  decision            : Decision
  determiningPolicies : List String
  deriving Repr, DecidableEq, BEq

def AuthPolicy.matches (pol : AuthPolicy) (principal : Entity) (action : String) (resource : Entity) : Bool :=
  pol.action == action &&
  pol.principalPred.eval principal.tags &&
  pol.resourcePred.eval resource.tags

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

structure Capability where
  rootPolicyId  : String
  allowedAction : String
  caveats       : List AttrExpr
  deriving Repr, DecidableEq, BEq

def Capability.attenuate (cap : Capability) (extra : AttrExpr) : Capability :=
  { cap with caveats := cap.caveats ++ [extra] }

def Capability.allows (cap : Capability) (action : String) (resource : Entity) : Bool :=
  cap.allowedAction == action && cap.caveats.all (fun c => c.eval resource.tags)

def hasForbid (policies : List AuthPolicy) (principal : Entity) (action : String) (resource : Entity) : Bool :=
  policies.any (fun p => p.effect == Effect.forbid && p.matches principal action resource)

def isDelegatedAuthorized
    (policies : List AuthPolicy) (delegator delegatee : Entity)
    (cap : Capability) (action : String) (resource : Entity) : Bool :=
  isAuthorized policies delegator action resource &&
  cap.allows action resource &&
  !hasForbid policies delegatee action resource

def blastRadius (policies : List AuthPolicy) (principal : Entity) (action : String) (allResources : List Entity) : List Entity :=
  allResources.filter (fun r => isAuthorized policies principal action r)

end Baugr.Engine
