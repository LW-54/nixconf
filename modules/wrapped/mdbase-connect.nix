{ self, inputs, ... }: {
  # Module for the standalone CLI
  flake.nixosModules.mdbase-cli = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.mdbase-cli
    ];
  };

  # Module for the Desktop application
  flake.nixosModules.mdbase-connect = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.mdbase-connect
    ];
  };

  perSystem = { pkgs, ... }: {
    
    # 1. Standalone native CLI and background service
    packages.mdbase-cli = pkgs.stdenv.mkDerivation rec {
      pname = "mdbase-cli";
      version = "0.1.0-beta.90"; 
      
      src = pkgs.fetchurl {
        url = "https://github.com/mdbase-dev/mdbase-connect/releases/download/v${version}/mdbase-cli-${version}-linux-x64.tar.gz";
        hash = "sha256-HMxeOCz2L84BGgz9UiUHV7khJ+FqOIpPxf86KShYEVA=";
      };

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp mdbase $out/bin/mdbase
        chmod +x $out/bin/mdbase
        runHook postInstall
      '';

      meta = {
        mainProgram = "mdbase";
      };
    };

    # 2. Desktop Electron application
    packages.mdbase-connect = pkgs.stdenv.mkDerivation rec {
      pname = "mdbase-connect";
      version = "0.1.0-beta.90"; 
      
      src = pkgs.fetchurl {
        url = "https://github.com/mdbase-dev/mdbase-connect/releases/download/v${version}/mdbase-connect-${version}-linux-x64.deb";
        hash = "sha256-Jmg4rStV6h2jpeINNqUB8eOfXmC7Pha/6NANTpDL738=";
      };

      nativeBuildInputs = [
        pkgs.dpkg
        pkgs.autoPatchelfHook
        pkgs.makeWrapper
      ];

      buildInputs = with pkgs; [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        dbus
        expat
        glib
        gtk3
        libdrm
        libGL         
        libglvnd      
        libxkbcommon
        mesa
        nspr
        nss
        pango
        systemd
        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxcb
      ];

      unpackPhase = ''
        mkdir -p extracted
        cd extracted
        dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner
        cd ..
      '';
      
      sourceRoot = "extracted";

      installPhase = ''
        runHook preInstall
        
        mkdir -p $out
        cp -r usr/* $out/
        
        mkdir -p $out/bin
        ln -sf $out/lib/mdbase-connect/mdbase-connect $out/bin/mdbase-connect
        
        runHook postInstall
      '';
      
      # Added xdg-utils to PATH and CA certs to the environment variables
      postFixup = ''
        wrapProgram $out/bin/mdbase-connect \
          --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}" \
          --prefix PATH : "${pkgs.xdg-utils}/bin" \
          --set NIX_SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
          --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      '';

      meta = {
        mainProgram = "mdbase-connect";
      };
    };
  };
}