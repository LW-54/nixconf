{
  outputs = { self, ... }@args:
    let
      inputs = (import ./.tack) {
        overrides = args.tackOverrides or { };
      } // {
        self = self // { inherit inputs; };
      };
    in
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

  disko module 
  nix


  creat contracts

  caddy ? should it be tool independent ?
  restic ? toold dependence and integration with persistance ?
  updates
  monitoring
  ressource allocation

*/