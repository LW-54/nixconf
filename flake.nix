{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrappers.url = "github:Lassulus/wrappers";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    helium.url = "github:oxcl/nix-flake-helium-browser";
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mdbase-obsidian = {
      url = "github:mdbase-dev/mdbase-obsidian";
      flake = false;
    };
    mdbase-connect = {
      url = "github:mdbase-dev/mdbase-connect/main";
      flake = false;
    };
    mdbase-lsp = {
      url = "github:callumalpass/mdbase-lsp";
      flake = false;
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://lw-54.cachix.org"
    ];
    extra-trusted-public-keys = [
      "lw-54.cachix.org-1:1sScTQ6+QH/OBn5bCQEWz7LP090BE7njdpYTpxe5l0o="
    ];
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}