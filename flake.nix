{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrappers.url = "github:Lassulus/wrappers";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    helium.url = "github:oxcl/nix-flake-helium-browser";
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
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
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
