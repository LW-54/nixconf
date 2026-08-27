{ self, inputs, ... }: {
  flake.nixosModules.mdbase-connect = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.mdbase-connect
    ];
  };

  perSystem = { pkgs, lib, ... }:
    let
      cli = pkgs.rustPlatform.buildRustPackage {
        pname = "mdbase-cli";
        version = "unstable";
        src = inputs.mdbase-connect;

        cargoLock = {
          lockFile = "${inputs.mdbase-connect}/Cargo.lock";
          outputHashes = {
            "mdbase-interop-0.1.0-rc.2" = "sha256-gg3WoBLgaffUf4uYsl5if8+JpfMJR3/dolJj5ww2SXI=";
          };
        };

        postPatch = ''
          cp -R ${inputs.mdbase-rs} ../mdbase-rs
        '';

        cargoBuildFlags = [ "-p" "mdbase-cli" ];
        doCheck = false;

        installPhase = ''
          mdbase_bin=$(find target -type f -name mdbase -perm -0100 -print -quit)
          test -n "$mdbase_bin"
          install -Dm755 "$mdbase_bin" $out/bin/mdbase
        '';

        meta = {
          description = "Headless mdbase Connect CLI and daemon";
          mainProgram = "mdbase";
          platforms = lib.platforms.linux;
        };
      };
    in {
      packages.mdbase-cli = cli;

      packages.mdbase-connect = pkgs.stdenv.mkDerivation {
        pname = "mdbase-connect";
        version = "unstable";
        src = inputs.mdbase-connect;

        pnpmDeps = pkgs.fetchPnpmDeps {
          pname = "mdbase-connect";
          version = "unstable";
          src = inputs.mdbase-connect;
          pnpm = pkgs.pnpm_11;
          fetcherVersion = 4;
          hash = "sha256-asY62PBw+i4elWbE59oWfD1gP45g1e6lBsdIvzPM3eQ=";
        };

        postPatch = ''
          cp -R ${inputs.mdbase-rs} ../mdbase-rs
          substituteInPlace apps/desktop/forge.config.cjs \
            --replace-fail "packagerConfig: {" \
            "packagerConfig: { electronZipDir: path.resolve(__dirname, \"../../electron-dist\"),"
        '';

        nativeBuildInputs = [
          pkgs.nodejs_24
          pkgs.pnpm_11
          pkgs.pnpmConfigHook
          pkgs.electron
          pkgs.zip
          pkgs.copyDesktopItems
          pkgs.makeWrapper
        ];

        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "mdbase-connect";
            desktopName = "mdbase connect";
            exec = "mdbase-connect";
            terminal = false;
            categories = [ "Utility" ];
          })
        ];

        preBuild = ''
          mkdir -p target/release
          cp ${cli}/bin/mdbase target/release/mdbase
          mkdir -p electron-dist-src electron-dist
          cp -RL ${pkgs.electron}/libexec/. electron-dist-src/
          (cd electron-dist-src && zip -qr ../electron-dist/electron-v43.1.1-linux-x64.zip .)
        '';

        buildPhase = ''
          runHook preBuild
          pnpm --filter @mdbase/connect-desktop exec node node_modules/typescript/bin/tsc -p tsconfig.main.json
          pnpm --filter @mdbase/connect-desktop exec node scripts/build-main.mjs
          pnpm --filter @mdbase/connect-desktop exec node node_modules/vite/bin/vite.js build
          pnpm --filter @mdbase/connect-desktop exec node node_modules/@electron-forge/cli/dist/electron-forge.js package
          pnpm --filter @mdbase/connect-desktop exec node scripts/verify-package.mjs
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          app_dir=$(find apps/desktop/out -mindepth 1 -maxdepth 1 -type d -name 'mdbase connect-*' -print -quit)
          test -n "$app_dir"
          mkdir -p $out/lib/mdbase-connect $out/bin
          cp -R "$app_dir"/. $out/lib/mdbase-connect/
          makeWrapper "$out/lib/mdbase-connect/mdbase connect" $out/bin/mdbase-connect
          ln -s $out/lib/mdbase-connect/resources/mdbase $out/bin/mdbase
          copyDesktopItems
          runHook postInstall
        '';

        meta = {
          description = "mdbase Connect desktop application and CLI";
          mainProgram = "mdbase-connect";
          platforms = lib.platforms.linux;
        };
      };
    };
}