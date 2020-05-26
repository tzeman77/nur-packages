{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.runit;
  rcfg = config.runit;

  pkg = cfg.package;

  sDerivations = rcfg.serviceDerivations // (mapAttrs mkService rcfg.services);

  runitServices = pkgs.stdenv.mkDerivation {
    name = "runit-services";
    preferLocalBuild = true;
    buildCommand = ''
      mkdir -p $out
      ${concatStringsSep "\n" (mapAttrsToList (n: v: "ln -sf ${v} $out/${n}")
        sDerivations)}
    '';
  };

  mkService = n: s: pkgs.stdenv.mkDerivation {
    name = n;
    preferLocalBuild = true;
    buildCommand =
    ''
      mkdir -p $out
      echo "#!${pkgs.bash}/bin/sh" > $out/run
      ${optionalString (s.preRun != null) ''
        echo '${s.preRun}' > $out/pre-run
        chmod 755 $out/pre-run
        echo ./pre-run >> $out/run
      ''}
      ${optionalString (s.cmd == null && s.run != null) ''
      echo '${s.run}' > $out/run-this
      chmod 755 $out/run-this
      ''}
      cat <<EOF >> $out/run
      ${optionalString (s.stdErrToOut) ''
        exec 2>&1
      ''}
      exec ${pkg}/bin/chpst ${optionalString ([] != attrNames s.env) "-e env "
      }${optionalString (s.user != null) "-u ${s.user} "
      }${optionalString (s.cmd != null) "${s.cmd}"
      }${optionalString (s.run != null) "./run-this"
      }
      EOF
      chmod 755 $out/run
      ${if (s.finish != null) then ''
        echo '${s.finish}' > $out/finish
        chmod 755 $out/finish
      '' else ""}
      ln -sf /run/sv.${n} $out/supervise
      ${optionalString ([] != attrNames s.env) "mkdir -p $out/env"}
      ${concatStringsSep "\n" (mapAttrsToList (n: v:
        "echo -n '${toString v}' > $out/env/${n}"
      ) s.env)}
      ${optionalString ([] != attrNames (s.log.dirs)) (mkLog n "$out" s.log)}
    '';
  };

  ts2opt = n:
    if n == "tai64n" then "-t"
    else if n == "human_" then "-tt"
    else if n == "iso" then "-ttt"
    else "";

  mkLog = n: out: l:
  ''
    mkdir -p ${out}/log
    mkdir -p ${toString (map (n: "${out}/log${n} ") (attrNames l.dirs))}
    ${concatStringsSep "\n" (mapAttrsToList (n: v:
      if (v.config != null) then "echo -n '${v.config}' > ${out}/log${n}/config"
      else ''
        echo "s${toString v.size}" > ${out}/log${n}/config
        echo "n${toString v.num}" >> ${out}/log${n}/config
        ${optionalString (v.extraConfig != null)
          "echo -n '${v.extraConfig}' >> ${out}/log${n}/config"}
      ''
    ) l.dirs)}
    cat <<EOF > ${out}/log/run
    #!${pkgs.bash}/bin/sh 
    ${concatStrings (mapAttrsToList (n: v: ''
      mkdir -p ${n}
      chown -R ${if l.user == null then "root" else l.user} ${n}
      cmp -s ${n}/config ${out}/log${n}/config
      if [ \$? -ne 0 ]; then
        cp ${out}/log${n}/config ${n}/config.new
        mv ${n}/config.new ${n}/config
      fi
    ''
    ) l.dirs)}
    exec ${optionalString (l.user != null)
      "${pkg}/bin/chpst -u ${l.user} "
    }${pkg}/bin/svlogd ${(ts2opt l.timestamp) + " "
    }${optionalString (l.extraOptions != null) "${l.extraOptions} "
    }${concatStringsSep " " (map (n: "${n}") (attrNames l.dirs))}
    EOF
    chmod 755 ${out}/log/run
    ln -sf /run/sv.${n}-log ${out}/log/supervise
  '';

in

{

  ###### interface

  options = {

    runit = {

      serviceDerivations = mkOption {
        default = {};
        description = "Runit supervised services";
      };

      services = mkOption {
        type = types.attrsOf (types.submodule {

          options = {

            preRun = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Pre-run script which prepares environment for service.";
            };

            run = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Run script";
            };

            cmd = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Command to be run as inline run script";
            };

            finish = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Finish script";
            };

            env = mkOption {
              type = types.attrsOf types.unspecified;
              default = {};
              description = "Environment available to run script under env dir.";
              example = {
                ENV_FOO_VAR = "abc";
              };
            };

            user = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "service user";
            };

            stdErrToOut = mkOption {
              type = types.bool;
              default = false;
              description = "If stderr should be redirected to stdout";
            };

            log = mkOption {
              default = {};
              description = "svlogd configuration";
              type = types.submodule {
                options = {
                  dirs = mkOption {
                    default = {};
                    description = "svlogd logdirs";
                    type = types.attrsOf (types.submodule {
                      options = {

                        config = mkOption {
                          type = types.nullOr types.str;
                          default = null;
                          description = "svlogd logdir config";
                        };

                        extraConfig = mkOption {
                          type = types.nullOr types.str;
                          default = null;
                          description = "svlogd logdir extra config";
                        };

                        size = mkOption {
                          type = types.int;
                          default = 1000000;
                          description = "current log file size in bytes";
                        };

                        num = mkOption {
                          type = types.int;
                          default = 10;
                          description = "number of log files kept";
                        };

                      };
                    });
                  };

                  user = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "svlogd user";
                  };

                  timestamp = mkOption {
                    type = types.nullOr (types.enum [ "tai64n" "human_" "iso"]);
                    default = "tai64n";
                    description = "svlogd timetamp option";
                  };

                  extraOptions = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "extra options to be passed to svlogd";
                  };
                };
              };
            };

          };
        });

        default = {};
        description = "Runit supervised services";
      };

    };

    services = {
      runit = {
        enable = mkOption {
          default = false;
          description = "Whether to enable runit service.";
        };

        package = mkOption {
          type = types.package;
          default = pkgs.runit;
          description = "Runit package to use";
        };

      };
    };
  };


  ###### implementation

  config = mkIf config.services.runit.enable {

    environment.systemPackages = [ pkg ];

    system.activationScripts.runit = ''
      dir=/etc/runit/runsvdir
      mkdir -p $dir
      [ -e $dir/current ] || ln -sf /var/empty $dir/current
      ${pkg}/bin/runsvchdir ${runitServices}
    '';

    systemd.services.runit =
      { description = "Runit service";

        path = [
          "/run/current-system/sw"
        ];

        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        preStart =
          ''
            dir=/etc/runit/runsvdir
            mkdir -p $dir
            if ! test -e $dir/current; then
              ln -sf /var/empty $dir/current
            fi
            if ! test -e /service; then
              ln -sf $dir/current /service
            fi
          '';

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkg}/bin/runsvdir -P /etc/runit/runsvdir/current log:........................................................................................";
          StandardOutput = "null";
          StandardError = "inherit";
        };
      };

  };

}

# vim: et ts=2 sw=2

