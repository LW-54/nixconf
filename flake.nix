{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    wrapper-modules.url = "github:nix-community/nix-wrapper-modules";
    wrapper-modules.inputs.nixpkgs.follows = "nixpkgs";
    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    helium.url = "github:oxcl/nix-flake-helium-browser";
    helium.inputs.nixpkgs.follows = "nixpkgs";
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