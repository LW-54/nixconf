/-
  Baugr.Engine.Resolve — Executable Promise Evaluator / Binder (F-2!)
  Formalizes operational resolution (`resolveUse`, `resolveScope`, `resolveAgentTree`) so we can
  mechanically prove Type Soundness (Progress & Preservation: `checkAgentTree → resolveAgentTree`)
  and lock Rust's evaluator to Lean 4 via DRT!
-/

import Baugr.Data.AttrExpr
import Baugr.Theory.Promise
import Baugr.Engine.Conformance
import Baugr.Engine.Binding

namespace Baugr.Engine

open Baugr.Data
open Baugr.Theory

/-- A single resolved `-b` use bound to its matching `+b` offer list in scope. -/
structure ResolvedUse where
  useId    : String
  ptype    : String
  key      : String
  offerIds : List String
  deriving Repr, DecidableEq, BEq

/-- Resolved bindings for one Dressed Superagent scope. -/
structure ResolvedScope where
  agentId  : String
  bindings : List ResolvedUse
  deriving Repr, DecidableEq, BEq

/--
  Executable operational resolver for a single promise `p` inside scope `allPs`.
  Returns `none` on any runtime binding failure (missing/ambiguous mandatory exclusive provider,
  missing mandatory broadcast provider, or exceeded budget/critical tier), or `some` on success!
-/
def resolveUse (allPs : List Promise) (p : Promise) : Option (Option ResolvedUse) :=
  match p.polarity with
  | Polarity.offer => some none
  | Polarity.use =>
    match p.cardinality with
    | Cardinality.exclusive =>
      let matched := allPs.filter (fun o => o.polarity == Polarity.offer && o.ptype == p.ptype && o.key == p.key)
      match p.strength, p.mandatory with
      | Strength.hard, true =>
        if matched.length == 1 then
          some (some { useId := p.id, ptype := p.ptype, key := p.key, offerIds := matched.map (·.id) })
        else none
      | _, _ =>
        some (some { useId := p.id, ptype := p.ptype, key := p.key, offerIds := matched.map (·.id) })
    | Cardinality.broadcast =>
      let matched := allPs.filter (fun o => o.polarity == Polarity.offer && o.ptype == p.ptype && p.selector.eval o.tags)
      match p.strength, p.mandatory with
      | Strength.hard, true =>
        if matched.isEmpty then none
        else some (some { useId := p.id, ptype := p.ptype, key := p.key, offerIds := matched.map (·.id) })
      | _, _ =>
        some (some { useId := p.id, ptype := p.ptype, key := p.key, offerIds := matched.map (·.id) })
    | Cardinality.partitioned =>
      let matched := allPs.filter (fun o =>
        o.polarity == Polarity.offer &&
        o.cardinality == Cardinality.partitioned &&
        o.ptype == p.ptype &&
        p.selector.eval o.tags)
      some (some { useId := p.id, ptype := p.ptype, key := p.key, offerIds := matched.map (·.id) })
    | Cardinality.budgeted =>
      let dem := totalBudgetDemand allPs p.ptype
      let sup := totalBudgetSupply allPs p.ptype
      let crit := criticalBudgetDemand allPs p.ptype
      if dem > sup || crit > sup then none
      else
        let matched := allPs.filter (fun o =>
          o.polarity == Polarity.offer &&
          o.cardinality == Cardinality.budgeted &&
          o.ptype == p.ptype)
        some (some { useId := p.id, ptype := p.ptype, key := p.key, offerIds := matched.map (·.id) })

/-- Resolve every promise in `ps` sequentially; fails with `none` iff any use fails to bind. -/
def resolveScopeList (allPs : List Promise) : List Promise -> Option (List ResolvedUse)
  | [] => some []
  | p :: rest =>
    match resolveUse allPs p, resolveScopeList allPs rest with
    | some (some ru), some tail => some (ru :: tail)
    | some none,      some tail => some tail
    | _,              _         => none

def resolveScope (ps : List Promise) : Option (List ResolvedUse) :=
  resolveScopeList ps ps

/-
  Recursive Non-Piercing Evaluator (`resolveAgentTree`):
  Resolves every Superagent scope strictly using `siblingOperationalView children` (NEVER piercing!).
-/
mutual
  def resolveAgentTree : Agent -> Option (List ResolvedScope)
    | Agent.atomic _ _ => some []
    | Agent.superagent ext children =>
      let intPs := (siblingOperationalView children).flatMap (·.promises)
      let scopePs := inboundFromExterior ext ++ outboundFromExterior ext intPs ++ intPs
      match resolveScope scopePs, resolveAgentTreeList children with
      | some bs, some childScopes => some ({ agentId := ext.agentId, bindings := bs } :: childScopes)
      | _, _ => none
    | Agent.profile ms => resolveAgentTreeList ms

  def resolveAgentTreeList : List Agent -> Option (List ResolvedScope)
    | [] => some []
    | a :: rest =>
      match resolveAgentTree a, resolveAgentTreeList rest with
      | some xs, some ys => some (xs ++ ys)
      | _, _ => none
end

end Baugr.Engine
