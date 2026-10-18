{self, ...}: {
  flake.nixosModules.users = {
    config,
    lib,
    options,
    ...
  }: let
    file = lib.types.submodule ({config, ...}: {
      freeformType = lib.types.attrsOf lib.types.anything;
      options = {
        source = lib.mkOption {
          type = lib.types.nullOr lib.types.anything;
          default = null;
          description = "Source for a managed home file.";
        };

        text = lib.mkOption {
          type = lib.types.nullOr lib.types.lines;
          default = null;
          description = "Text content for a managed home file.";
        };

        executable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether a managed home file is executable.";
        };

        force = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether the backend may replace an unmanaged file.";
        };
      };
      config.assertions = [
        {
          assertion = config.source == null || config.text == null;
          message = "A home file must define either source or text, not both.";
        }
      ];
    });

    files = lib.types.attrsOf file;
    xdg = lib.types.submodule {
      options = {
        cache = lib.mkOption {
          type = files;
          default = {};
        };
        config = lib.mkOption {
          type = files;
          default = {};
        };
        data = lib.mkOption {
          type = files;
          default = {};
        };
        state = lib.mkOption {
          type = files;
          default = {};
        };
      };
    };
  in {
    options.users.defaultPasswordHash = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to provision the default user password hash from SOPS.";
    };

    options.users.account = lib.mkOption {
      type = options.users.users.type;
      default = {};
      apply = accounts:
        if accounts == {}
        then
          (self.lib.users.create {
            inherit lib;
            name = "lw";
            account =
              {
                isNormalUser = true;
                description = "lw's account";
                extraGroups = ["wheel" "networkmanager"];
              }
              // lib.optionalAttrs config.users.defaultPasswordHash {
                hashedPasswordFile = config.sops.secrets.default-user-password-hash.path;
              };
          }).users.account
        else accounts;
      description = "Native NixOS user account declarations.";
    };

    options.users.home = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf (lib.types.submodule {
        freeformType = lib.types.attrsOf lib.types.anything;
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether a home backend manages this user's home.";
          };

          packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "Packages declared for this user's home environment.";
          };

          files = lib.mkOption {
            type = files;
            default = {};
            description = "Files declared for this user's home environment.";
          };

          xdg = lib.mkOption {
            type = xdg;
            default = {};
            description = "Files declared in the user's XDG home directories.";
          };

          environment.sessionVariables = lib.mkOption {
            type = lib.types.attrsOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
            default = {};
            description = "Session variables declared for the user's home.";
          };

          systemd.services = lib.mkOption {
            type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
            default = {};
            description = "Per-user systemd services declared for the home.";
          };
        };
      }));
      default = null;
      apply = homes:
        if homes == null
        then
          if config.users.account ? lw
          then {lw = {};}
          else {}
        else homes;
      description = "Backend-neutral declarative home data keyed by username.";
    };

    config = {
      assertions = [
        {
          assertion =
            lib.all
            (userName: config.users.account ? ${userName})
            (builtins.attrNames config.users.home);
          message = "Every users.home declaration must have a matching users.account declaration.";
        }
      ];
      sops.secrets = lib.mkIf config.users.defaultPasswordHash {
        default-user-password-hash = {
          sopsFile = ../../secrets/users/default.yaml;
          key = "passwordHash";
          neededForUsers = true;
        };
      };
      users.users = config.users.account;
    };
  };

  flake.lib.users.create = {
    lib,
    name,
    account,
    home ? null,
    persistence ? null,
  }:
    {
      users =
        {
          account.${name} = account;
        }
        // lib.optionalAttrs (home != null) {
          home.${name} = home;
        };
    }
    // lib.optionalAttrs (persistence != null) {
      persistence.users.${name} = persistence;
    };

  flake.lib.users.mkFeatureOptions = {
    lib,
    name,
    description,
    defaultEnable ? true,
    featureOptions ? {},
    userOptions ? {},
  }:
    assert lib.assertMsg (!(featureOptions ? enable)) "users.mkFeatureOptions reserves the feature option `enable`.";
    assert lib.assertMsg (!(featureOptions ? users)) "users.mkFeatureOptions reserves the feature option `users`.";
    assert lib.assertMsg (!(userOptions ? enable)) "users.mkFeatureOptions reserves the per-user option `enable`."; {
      options.${name} =
        featureOptions
        // {
          enable = lib.mkEnableOption description // {default = defaultEnable;};
          users = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options =
                {
                  enable = lib.mkOption {
                    type = lib.types.nullOr lib.types.bool;
                    default = null;
                    description = "Whether this user receives ${description}, overriding ${name}.enable.";
                  };
                }
                // userOptions;
            });
            default = {};
            description = "Per-user ${description} configuration.";
          };
        };
    };

  flake.lib.users.mkHome = {
    lib,
    name,
    package ? (_: null),
    home ? ({...}: {}),
    globalEnable ? null,
    userEnabled ? ({
      cfg,
      user,
      ...
    }: let
      override = lib.attrByPath ["enable"] null user;
    in
      if override == null
      then
        if globalEnable == null
        then cfg.enable
        else globalEnable
      else override),
  }: {
    config,
    pkgs,
    ...
  }: let
    cfg = lib.getAttrFromPath [name] config;
    packageValue = package pkgs;
    userConfig = userName: lib.attrByPath [userName] {} cfg.users;
    userArgs = userName: {
      inherit cfg config lib name pkgs userName;
      user = userConfig userName;
    };
  in {
    config.users.home = lib.mapAttrs (
      userName: _: let
        args = userArgs userName;
      in
        {
          packages = lib.optional (!cfg.enable && packageValue != null) packageValue;
        }
        // home args
    ) (lib.filterAttrs (userName: _: userEnabled (userArgs userName)) config.users.account);
  };

  flake.lib.users.mkPersistence = {
    lib,
    config,
    users ? config.users.account,
    userEnabled ? null,
    global ? null,
    userOverrides ? {},
    data ? {},
    cache ? {},
  }: let
    enabled =
      if userEnabled != null
      then userEnabled
      else if global != null
      then
        self.lib.users.mkUserEnabled {
          inherit lib global;
          users = userOverrides;
        }
      else (_: true);
  in
    lib.mapAttrs (_: _: {inherit data cache;})
    (lib.filterAttrs (userName: user:
      (user.isNormalUser or false)
      && enabled userName)
    users);

  flake.lib.users.mkUserEnabled = {
    lib,
    global,
    users,
    path ? ["enable"],
  }: userName: let
    override = lib.attrByPath ([userName] ++ path) null users;
  in
    if override == null
    then global
    else override;

  flake.lib.users.mkFeature = {
    lib,
    name,
    description,
    package ? (_: null),
    defaultEnable ? true,
    featureOptions ? {},
    userOptions ? {},
    home ? ({...}: {}),
  }: {
    config,
    pkgs,
    ...
  }: let
    cfg = lib.getAttrFromPath [name] config;
    packageValue = package pkgs;
  in {
    imports = [
      (self.lib.users.mkFeatureOptions {
        inherit lib name description defaultEnable featureOptions userOptions;
      })
      (self.lib.users.mkHome {
        inherit lib name package home;
        globalEnable = cfg.enable;
      })
    ];
    config.environment.systemPackages =
      lib.mkIf (cfg.enable && packageValue != null) [packageValue];
  };
}
