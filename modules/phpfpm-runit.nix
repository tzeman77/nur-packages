{ config, lib, pkgs, ... }:

with lib;

let
  oneOf = ts:
    let
      head' = if ts == [] then throw "types.oneOf needs to get at least one type in its argument" else head ts;
      tail' = tail ts;
    in foldl' types.either head' tail';

  cfg = config.runit.phpfpm;

  stateDir = key: "/run/phpfpm-${key}";

  pidFile = key: "${stateDir key}/phpfpm.pid";

  toStr = value:
    if true == value then "yes"
    else if false == value then "no"
    else toString value;

  mkPool = n: p: ''
    [${n}]
    listen = ${p.listen}
    user = ${p.user}
    group = ${p.group}
    ${concatStringsSep "\n" (mapAttrsToList (n: v: "${n} = ${toStr v}") p.settings)}
    ${concatStringsSep "\n" (mapAttrsToList (n: v: "env[${n}] = ${toStr v}") p.phpEnv)}
    ${optionalString (p.extraConfig != null) p.extraConfig}
  '';

  cfgFile = key: c: pkgs.writeText "phpfpm.conf" ''
    [global]
    pid = ${pidFile key}
    error_log = /dev/stderr
    ${concatStringsSep "\n" (mapAttrsToList (n: v: "${n} = ${toStr v}") c.settings)}
    ${optionalString (c.extraConfig != null) c.extraConfig}

    ${concatStringsSep "\n" (mapAttrsToList mkPool c.pools)}

  '';
    #${concatStringsSep "\n" (mapAttrsToList (n: v: "[${n}]\n${v}") c.poolConfigs)}

  fpmCfgFile = pool: poolOpts: pkgs.writeText "phpfpm-${pool}.conf" ''
    [global]
    ${concatStringsSep "\n" (mapAttrsToList (n: v: "${n} = ${toStr v}") cfg.settings)}
    ${optionalString (cfg.extraConfig != null) cfg.extraConfig}

    [${pool}]
    ${concatStringsSep "\n" (mapAttrsToList (n: v: "${n} = ${toStr v}") poolOpts.settings)}
    ${concatStringsSep "\n" (mapAttrsToList (n: v: "env[${n}] = ${toStr v}") poolOpts.phpEnv)}
    ${optionalString (poolOpts.extraConfig != null) poolOpts.extraConfig}
  '';

# phpIni = c: pkgs.writeText "php.ini" ''
#   ${readFile "${c.phpPackage}/etc/php.ini"}

#   ${c.phpOptions}
# '';

  phpIni = poolOpts: pkgs.runCommand "php.ini" {
    inherit (poolOpts) phpPackage phpOptions;
    preferLocalBuild = true;
    nixDefaults = ''
      sendmail_path = "/run/wrappers/bin/sendmail -t -i"
    '';
    passAsFile = [ "nixDefaults" "phpOptions" ];
  } ''
    cat $phpPackage/etc/php.ini $nixDefaultsPath $phpOptionsPath > $out
  '';

  poolOpts = { name, ... }:
    let
      poolOpts = cfg.pools.${name};
    in
    {
      options = {
        listen = mkOption {
          type = types.str;
          default = "";
          example = "/path/to/unix/socket";
          description = ''
            The address on which to accept FastCGI requests.
          '';
        };

        phpEnv = lib.mkOption {
          type = with types; attrsOf str;
          default = {};
          description = ''
            Environment variables used for this PHP-FPM pool.
          '';
          example = literalExample ''
            {
              HOSTNAME = "$HOSTNAME";
              TMP = "/tmp";
              TMPDIR = "/tmp";
              TEMP = "/tmp";
            }
          '';
        };

        user = mkOption {
          type = types.str;
          description = "User account under which this pool runs.";
        };

        group = mkOption {
          type = types.str;
          description = "Group account under which this pool runs.";
        };

        settings = mkOption {
          type = with types; attrsOf (oneOf [ str int bool ]);
          default = {};
          description = ''
            PHP-FPM pool directives. Refer to the "List of pool directives" section of
            <link xlink:href="https://www.php.net/manual/en/install.fpm.configuration.php"/>
            for details. Note that settings names must be enclosed in quotes (e.g.
            <literal>"pm.max_children"</literal> instead of <literal>pm.max_children</literal>).
          '';
          example = literalExample ''
            {
              "pm" = "dynamic";
              "pm.max_children" = 75;
              "pm.start_servers" = 10;
              "pm.min_spare_servers" = 5;
              "pm.max_spare_servers" = 20;
              "pm.max_requests" = 500;
            }
          '';
        };

        extraConfig = mkOption {
          type = with types; nullOr lines;
          default = null;
          description = ''
            Extra lines that go into the pool configuration.
            See the documentation on <literal>php-fpm.conf</literal> for
            details on configuration directives.
          '';
        };
      };

#     config = {
#       socket = if poolOpts.listen == "" then "${runtimeDir}/${name}.sock" else poolOpts.listen;
#       group = mkDefault poolOpts.user;

#       settings = mapAttrs (name: mkDefault){
#         #listen = poolOpts.socket;
#         user = poolOpts.user;
#         group = poolOpts.group;
#       };
#     };
    };

in {

  options = {
    runit.phpfpm = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          settings = mkOption {
            type = with types; attrsOf (oneOf [ str int bool ]);
            default = {};
            description = ''
              PHP-FPM global directives. Refer to the "List of global php-fpm.conf directives" section of
              <link xlink:href="https://www.php.net/manual/en/install.fpm.configuration.php"/>
              for details. Note that settings names must be enclosed in quotes (e.g.
              <literal>"pm.max_children"</literal> instead of <literal>pm.max_children</literal>).
              You need not specify the options <literal>error_log</literal> or
              <literal>daemonize</literal> here, since they are generated by NixOS.
            '';
          };

          extraConfig = mkOption {
            type = types.nullOr types.lines;
            default = null;
            description = ''
              Extra configuration that should be put in the global section of
              the PHP FPM configuration file. Do not specify the options
              <literal>pid</literal>, <literal>error_log</literal> or
              <literal>daemonize</literal> here, since they are generated by
              NixOS.
            '';
          };

          phpPackage = mkOption {
            type = types.package;
            default = pkgs.php;
            defaultText = "pkgs.php";
            description = ''
              The PHP package to use for running the FPM service.
            '';
          };

          phpOptions = mkOption {
            type = types.lines;
            default = "";
            example =
              ''
                date.timezone = "CET"
              '';
            description =
              "Options appended to the PHP configuration file <filename>php.ini</filename>.";
          };

          pools = mkOption {
            type = types.attrsOf (types.submodule poolOpts);
            default = {};
            example = literalExample ''
             {
               mypool = {
                 user = "php";
                 group = "php";
                 phpPackage = pkgs.php;
                 settings = '''
                   "pm" = "dynamic";
                   "pm.max_children" = 75;
                   "pm.start_servers" = 10;
                   "pm.min_spare_servers" = 5;
                   "pm.max_spare_servers" = 20;
                   "pm.max_requests" = 500;
                 ''';
               }
            '';
            description = ''
              A mapping between PHP FPM pool names and their configurations.
              See the documentation on <literal>php-fpm.conf</literal> for
              details on configuration directives. If no pools are defined,
              the phpfpm service is disabled.
            '';
          };

          log = mkOption {
            default = {};
            description = "Logging configuration (as per runit log service)";
          };

        };
      });

      default = {};
      description = "FPM managers";

    };
  };

  config = mkIf (cfg != {}) {
    runit.services = mapAttrs' (key: c: nameValuePair ("phpfpm-${key}") ({
      stdErrToOut = true;

      preRun = ''
        mkdir -p "${stateDir key}"
      '';

      cmd = "${c.phpPackage}/bin/php-fpm -F -y ${cfgFile key c} -c ${phpIni c}";

      log = c.log;

    })) (filterAttrs (key: c: c.pools != {}) cfg);

  };
}

# vim: et ts=2 sw=2
