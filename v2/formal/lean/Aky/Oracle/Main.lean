/-
  Aky.Oracle.Main — Layer 3 Thin Executable Entrypoint
  Streams NDJSON test vectors on stdin and emits deterministic verified verdicts on stdout.
-/

import Aky.Oracle.Protocol

open Lean (Json fromJson?)
open Aky.Oracle

def main : IO Unit := do
  let stdin ← IO.getStdin
  let raw ← stdin.readToEnd
  for line in raw.splitOn "\n" do
    let trimmed := line.trimAscii.toString
    if !trimmed.isEmpty then
      match Json.parse trimmed >>= fromJson? with
      | Except.ok (req : OracleRequest) =>
        IO.println (evalRequest req).compress
      | Except.error err =>
        IO.eprintln s!"oracle parse error: {err}"
        IO.Process.exit 1
