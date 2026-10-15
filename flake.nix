{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    wrapper-modules = { url = "github:nix-community/nix-wrapper-modules"; inputs.nixpkgs.follows = "nixpkgs"; };
    hjem = { url = "github:feel-co/hjem"; inputs.nixpkgs.follows = "nixpkgs"; };

    sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    impermanence = { url = "github:nix-community/impermanence"; inputs.nixpkgs.follows = "nixpkgs"; };
    disko = { url = "github:nix-community/disko"; inputs.nixpkgs.follows = "nixpkgs"; };

    nix-index-database = { url = "github:nix-community/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; };
    helium = { url = "github:oxcl/nix-flake-helium-browser"; inputs.nixpkgs.follows = "nixpkgs"; };
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