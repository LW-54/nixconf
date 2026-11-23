# Agent & Developer Fast-Iteration Guide

To avoid wasting minutes waiting on full Nix evaluations and builds during iterative development, **always pick the narrowest check matching what you edited**.

## Fast Feedback Loop (Use During Iteration)

| What you edited | Fast command | Typical time |
| :--- | :--- | ---: |
| Formatting `.nix` files | `alejandra <file...>` (direct binary, never `nix fmt .`) | ~0.1s |
| Primitive / schema / option declarations | `nix build --no-link .#checks.x86_64-linux.schemas` | ~2–3s |
| Single host or feature used by one host | `just check-host astrolabe` or `just check-host x240` | ~6–7s |
| Shared contract / implementation / both hosts | `just check-fast` | ~12–14s |
| Specific `/etc` or systemd unit check | `just test-inspect <host> <namespace>` (e.g. `just test-inspect astrolabe rclone`) | ~10–15s |
| Specific runtime service in QEMU | `just test-vm <host> <namespace>` (e.g. `just test-vm astrolabe grafana`) | ~30–60s |
| Specific package or devShell | `nix build --no-link .#<pkg>` | ~2–10s |
| CI workflow definitions (`meta/ci/*`) | `nix run .#ci -- --write` | ~6–7s |
| Documentation generator (`meta/docs/*`) | `nix run .#docs -- --write` | ~12s |

## Rules for Coding Agents

1. **Do NOT run `nix flake check` or full `just test-vm` after every small edit.** Use `just check-host <host>`, `just check-fast`, or `just test-vm <host> <namespace>` while iterating.
2. **Avoid `nix run .#test -- ...` when you already know the target** — prefer `just test-eval`, `just test-inspect`, `just test-vm`, or direct `nix build` to avoid evaluating the flake twice.
3. **Never interpolate `${self}` or `self + "/..."` into derivations or host configs** — use relative Nix paths (`../../secrets + "/..."`) or `lib.fileset.toSource` so edits to unrelated files do not bust Nix/Cachix/Attic caches.
4. **Run full verification once at the end**: The pre-commit hook (`.githooks/pre-commit`) runs staged `alejandra` + a single-eval pass for `docs`, `ci`, `schemas`, and all host `eval` checks (~15–20s). Run `just check` only before merging major cross-cutting changes.
5. **Profile regressions with `nixprof`**:
   - `nixprof trace -- <any command>` — SVG flamegraph, Speedscope timeline, Nix stats, and nested `nix` call tracing
   - `nixprof cache-diff --working-tree --flake-all --mutate README.md` — verify cache isolation
   - `nixprof ci` — inspect live GitHub Actions timings
   - `nixprof compare before.json after.json` — diff two saved reports
