{pkgs, ...}: {
  devPackages = [pkgs.stdenv.cc pkgs.lean4 pkgs.quint];
}
