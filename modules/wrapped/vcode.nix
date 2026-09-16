{ self, inputs, ... }: {
  flake.nixosModules.vscode = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.vscode
    ];
  };

  perSystem = { pkgs, ... }: {
    
    packages.mdbase-lsp-extension = pkgs.stdenv.mkDerivation rec {
      pname = "mdbase-lsp";
      version = "0.3.0-rc.2";
      
      src = pkgs.fetchurl {
        name = "mdbase-linux-x64-0.1.0.vsix";
        url = "https://github.com/callumalpass/mdbase-lsp/releases/download/v${version}/mdbase-linux-x64-0.1.0.vsix";
        # Validated hash from the Nix build output
        hash = "sha256-edhpm7MB80dTeRMqON/0wNPKG9Vtuxsa8NeOdNA2YhY=";
      };

      # Required identifiers for VS Code to recognize the package
      vscodeExtPublisher = "callumalpass";
      vscodeExtName = "mdbase-lsp";
      vscodeExtUniqueId = "callumalpass.mdbase-lsp";

      nativeBuildInputs = [ 
        pkgs.unzip 
        pkgs.autoPatchelfHook 
      ];
      
      # Provides standard C libraries for the native Rust LSP binary
      buildInputs = [ 
        pkgs.stdenv.cc.cc.lib 
      ];

      dontBuild = true;

      unpackPhase = ''
        unzip $src
      '';

      installPhase = ''
        runHook preInstall
        
        # VS Code expects extensions at $out/share/vscode/extensions/<publisher>.<name>
        mkdir -p $out/share/vscode/extensions/${vscodeExtUniqueId}
        cp -r extension/* $out/share/vscode/extensions/${vscodeExtUniqueId}/
        
        runHook postInstall
      '';
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