{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    wrapper-modules.url = "github:nix-community/nix-wrapper-modules";
    hjem.url = "github:feel-co/hjem";

    sops-nix.url = "github:Mic92/sops-nix";
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";

    nix-index-database.url = "github:nix-community/nix-index-database";
    helium.url = "github:oxcl/nix-flake-helium-browser";
  };

  nixConfig = {
    extra-substituters = "https://lw-54.cachix.org";
    extra-trusted-public-keys = "lw-54.cachix.org-1:1sScTQ6+QH/OBn5bCQEWz7LP090BE7njdpYTpxe5l0o=";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}

/* 

  configuration

  clean up




  mdbase-connect
  obsidian
  mdbase-lsp
  wifi-rez
  wifi
  cachix watcher
  rust-env


  creat contracts

  caddy ? should it be tool independent ?
  restic ? toold dependence and integration with persistance ?
  updates
  monitoring
  ressource allocation

*/