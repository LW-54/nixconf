{ lib,config, ... }:
{

flake.lib.mkOptionWithUserOverride = {
    lib,
    type,
    default,
    userType ? lib.types.nullOr type,
    userDefault ? null,
    merge ? (global: user: if user == null then global else user),
    description ? "value",
}:
    {
    global = lib.mkOption { inherit type default description; };
    user = lib.mkOption {
        type = userType;
        default = userDefault;
        description = "Per-user override for ${description}.";
    };
    resolve = globalValue: userValue: merge globalValue userValue;
    };

flake.lib.resolveUserOption = {
    lib,
    global,
    users,
    userName,
    path ? [ "enable" ],
}:
    let override = lib.attrByPath ([ userName ] ++ path) null users;
    in if override == null then global else override;

flake.lib.assertUsersExist = { lib, config, feature, users }:
    lib.mapAttrsToList (userName: _: {
    assertion = config.users.users ? ${userName};
    message = "${feature}.users.${userName} refers to an unknown user.";
    }) users;

flake.lib.mkUserPersistence = {
    lib,
    users,
    userEnabled ? (_: true),
    data ? { },
    cache ? { },
}:
    lib.mapAttrs (_: _: { inherit data cache; })
    (lib.filterAttrs (userName: _: userEnabled userName) users);

flake.lib.mkHjemUserProjection = {
    lib,
    name,
    description,
    userOptions ? { },
    userEnabled ? (_: true),
    userModule ? ({ ... }: { }),
}:
    { config, pkgs, ... }:
    let
        cfg = lib.getAttrFromPath [ name ] config;
        userCfg = userName: lib.attrByPath [ userName ] { } cfg.users;
    in
    {
        options.${name}.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule { options = userOptions; });
        default = { };
        description = "Per-user ${description} configuration.";
        };
        config = {
        assertions = lib.mapAttrsToList (userName: _: {
            assertion = config.users.users ? ${userName};
            message = "${name}.users.${userName} refers to an unknown user.";
        }) cfg.users;
        hjem.extraModules = [
            ({ name, ... }:
            let args = { inherit name cfg config lib pkgs; user = userCfg name; };
            in lib.mkIf (userEnabled args) (userModule args))
        ];
        };
    };

flake.lib.mkUserFeature = {
    lib,
    name,
    description,
    package ? (_: null),
    defaultEnable ? true,
    featureOptions ? { },
    userOptions ? { },
    userModule ? ({ ... }: { }),
}:
    { config, pkgs, ... }:
    let
        cfg = lib.getAttrFromPath [ name ] config;
        packageValue = package pkgs;
        userEnable = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Whether this user receives ${description}, overriding ${name}.enable.";
        };
    in
    {
        imports = [
        ({ config, pkgs, ... }:
            let
            userCfg = userName: lib.attrByPath [ userName ] { } cfg.users;
            userEnabled = userName:
                let override = lib.attrByPath [ userName "enable" ] null cfg.users;
                in if override == null then cfg.enable else override;
            in
            {
            options.${name}.users = lib.mkOption {
                type = lib.types.attrsOf (lib.types.submodule {
                options = { enable = userEnable; } // userOptions;
                });
                default = { };
                description = "Per-user ${description} configuration.";
            };

            config = {
                assertions = lib.mapAttrsToList (userName: _: {
                assertion = config.users.users ? ${userName};
                message = "${name}.users.${userName} refers to an unknown user.";
                }) cfg.users;
                hjem.extraModules = [
                ({ name, ... }:
                    lib.mkIf (userEnabled name) (lib.mkMerge [
                    {
                        packages = lib.optional
                        (!cfg.enable && packageValue != null)
                        packageValue;
                    }
                    (userModule {
                        inherit name cfg config lib pkgs;
                        user = userCfg name;
                    })
                    ]))
                ];
            };
            })
        ];
        options.${name} = featureOptions // {
        enable = lib.mkEnableOption description // { default = defaultEnable; };
        };
        config.environment.systemPackages = lib.mkIf
        (cfg.enable && packageValue != null) [ packageValue ];
    };
}
