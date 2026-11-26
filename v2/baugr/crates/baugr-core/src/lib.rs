//! **Baugr (`baugr-core`)** — Pure, `std::fs`-free (Wasm-ready), 100% usage-agnostic
//! Promise Theory & Semantic Spacetime verification kernel.
//!
//! Mirrors the Lean 4 specification (`baugr/formal/lean/Baugr/{Theory,Engine}/*`) module-for-module
//! with zero Nix, Linux, or domain assumptions and stays bit-for-bit locked to `baugr-oracle`
//! via AWS Cedar Verification-Guided Development (DRT).

pub mod agency;
pub mod attr_expr;
pub mod authority;
pub mod binding;
pub mod drt;
pub mod fleet;
pub mod invariants;
pub mod resolve;
pub mod spacetime;

#[cfg(test)]
mod purity_tests {
    #[test]
    fn core_kernel_contains_zero_domain_strings() {
        let sources = [
            ("agency.rs", include_str!("agency.rs")),
            ("attr_expr.rs", include_str!("attr_expr.rs")),
            ("authority.rs", include_str!("authority.rs")),
            ("binding.rs", include_str!("binding.rs")),
            ("drt.rs", include_str!("drt.rs")),
            ("fleet.rs", include_str!("fleet.rs")),
            ("invariants.rs", include_str!("invariants.rs")),
            ("resolve.rs", include_str!("resolve.rs")),
            ("spacetime.rs", include_str!("spacetime.rs")),
        ];
        let forbidden = [
            "vaultwarden",
            "caddy",
            "tailscale",
            "restic",
            "perses",
            "victoria",
            "btrfs",
            "systemd",
            "astrolabe",
            "skidbladnir",
            "ivaldi",
            "verft",
            "nixos",
            "state:persist",
            "http:route",
            "sops",
            "niks3",
            "nats",
            "mdbook",
        ];
        for (name, src) in sources {
            let lower = src.to_lowercase();
            for word in forbidden {
                assert!(
                    !lower.contains(word),
                    "domain leak in usage-agnostic Baugr core kernel: `{word}` found in {name}"
                );
            }
        }
    }
}
