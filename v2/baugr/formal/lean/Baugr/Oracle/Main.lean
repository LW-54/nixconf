/-
  Baugr.Oracle.Main — Thin NDJSON Executable Oracle Entrypoint
  Streams NDJSON test vectors on stdin and emits deterministic verified verdicts on stdout.
-/

import Baugr.Oracle.Protocol

open Lean (Json fromJson?)
open Baugr.Oracle

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
        IO.eprintln s!"baugr-oracle parse error: {err}"
        IO.Process.exit 1
