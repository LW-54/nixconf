//! **Antikythera (`aky-core`)** — Pure, `std::fs`-free (Wasm-ready), 100% usage-agnostic
//! verification kernel.
//!
//! Mirrors the 4-layer Lean 4 specification (`v2/formal/lean/Aky/Spec/*`) module-for-module
//! with zero domain-specific assumptions and stays bit-for-bit locked to the proved
//! `aky-oracle` via AWS Cedar Verification-Guided Development (DRT).

pub mod agency;
pub mod attr_expr;
pub mod authority;
pub mod binding;
pub mod drt;
pub mod fleet;
pub mod invariants;
