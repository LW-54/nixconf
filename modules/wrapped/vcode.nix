{ self, inputs, ... }: {
  flake.nixosModules.vscode = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.vscode
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.mdbase-lsp-extension = pkgs.vscode-utils.extensionFromVsix {
      name = "mdbase-lsp";
      publisher = "callumalpass"; 
      version = "0.3.0-rc.2";
      
      src = pkgs.fetchurl {
        url = "https://github.com/callumalpass/mdbase-lsp/releases/download/v0.3.0-rc.2/mdbase-linux-x64-0.1.0.vsix";
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };

      # Automatically patch the pre-compiled Rust binary for NixOS compatibility
      nativeBuildInputs = [ pkgs.autoPatchelfHook ];
      
      # Provide standard C libraries required by native Rust binaries
      buildInputs = [ pkgs.stdenv.cc.cc.lib ]; 
    };

    packages.vscode = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.vscode-with-extensions.override {
        vscode = pkgs.vscode;
        vscodeExtensions = with pkgs.vscode-extensions; [
        ] ++ [ self.packages.${pkgs.stdenv.hostPlatform.system}.mdbase-lsp-extension ];
      };
    };
  };
}