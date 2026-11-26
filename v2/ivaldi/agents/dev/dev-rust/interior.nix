{pkgs, ...}: {
  devPackages = [pkgs.stdenv.cc pkgs.cargo pkgs.rustc pkgs.clippy pkgs.rustfmt pkgs.cargo-deny];
}
