{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.runit.dnscache;
  pkg = pkgs.djbdns;

  useGlobalRootServers = if cfg.nameservers == [] then "1" else "0";

  mkDomain = out: n: v:
  ''
    echo "${concatStringsSep "\n" v}" > ${out}/servers/${n}
  '';

  rootDir = pkg.stdenv.mkDerivation {
    name = "dnscache";
    preferLocalBuild = true;
    buildCommand = ''
      mkdir -p $out/{ip,servers}
      for i in ${toString cfg.allowFrom}; do touch $out/ip/$i; done
      if [ "${useGlobalRootServers}" = "1" ]; then
        cp ${pkg}/etc/dnsroots.global $out/servers/@
      else
        echo "${concatStringsSep "\n" cfg.nameservers}" > $out/servers/@
      fi
      ${concatStringsSep "\n" (mapAttrsToList (n: v: mkDomain "$out" n v) cfg.domains)}
      dd if=/dev/urandom of=$out/seed bs=512 count=1
      cat <<EOF > $out/run
      #!${pkgs.bash}/bin/sh
      exec < $out/seed
      exec ${pkgs.runit}/bin/chpst -U dnscache -o 250 -d ${toString cfg.dataLimit} ${pkg}/bin/dnscache
      EOF
      chmod 755 $out/run
    '';
  };

in

{

  ###### interface

  options = {

    runit.dnscache = {

      enable = mkOption {
        default = false;
        description = "Whether to enable dnscache service.";
      };

      cacheSize = mkOption {
        default = 10000000;
        description = "Cache size";
      };

      dataLimit = mkOption {
        default = 10485760;
        description = "Data segment limit";
      };

      listenIp = mkOption {
        default = "127.0.0.1";
        description = "Listening IP address";
      };

      sendIp = mkOption {
        default = "0.0.0.0";
        description = "Source IP";
      };

#     root = mkOption {
#       default = "/var/db/dnscache/root";
#       description = "dnscache root dir";
#     };

      allowFrom = mkOption {
        default = [ "127.0.0.1" ];
        description = "List of IP addresses/prefixes to allow query";
      };

      forwardOnly = mkOption {
        default = false;
        description = "If the cache forwards queries to recursive nameservers";
      };

      nameservers = mkOption {
        default = [];
        description = "List of root servers IP addresses. Uses dnsroots.global if empty";
      };

      domains = mkOption {
        default = {};
        description = ''
          IP addresses for domains (will send queries for those domains directly
          to configured IP addresses.
          '';
        type = types.attrsOf (types.listOf types.str);
        example = {
          "example.org" = ["1.2.3.4" "1.2.3.5"];
        };
      };

      log = mkOption {
        default = {
          user = "dnslog";
          dirs = { "/var/log/dns/cache" = {}; };
        };
        description = "Logging configuration (as per runit log service)";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkg pkgs.diffutils ];

#   environment.etc."dnscache-root-servers" =
#     if cfg.nameservers == [] then
#       { source = "${pkgs.djbdns}/etc/dnsroots.global"; }
#     else
#       { text = concatStringsSep "\n" cfg.nameservers; };

    users.extraUsers.dnscache = {
      uid = config.ids.uids.dnscache;
      group = "dnscache";
      description = "dnscache service user";
    };

    users.extraGroups.dnscache.gid = config.ids.gids.dnscache;

    users.extraUsers.dnslog = {
      uid = config.ids.uids.dnslog;
      group = "dnslog";
      description = "dnslog service user";
    };

    users.extraGroups.dnslog.gid = config.ids.gids.dnslog;

    runit.services.dnscache = {
      env = {
        CACHESIZE = toString cfg.cacheSize;
        DATALIMIT = toString cfg.dataLimit;
        IP = cfg.listenIp;
        IPSEND = cfg.sendIp;
        ROOT = rootDir;
      } // optionalAttrs (cfg.forwardOnly) {
        FORWARDONLY = "1";
      };

      stdErrToOut = true;

      cmd = "${rootDir}/run";

      log = cfg.log;
    };
  };

}

# vim: et ts=2 sw=2

