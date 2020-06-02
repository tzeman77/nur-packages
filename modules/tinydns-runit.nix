{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.runit.tinydns;
  pkg = pkgs.djbdns;

in

{

  ###### interface

  options = {

    runit.tinydns = {

      enable = mkOption {
        default = false;
        description = "Whether to enable tinydns (authoritative) service.";
      };

      dataLimit = mkOption {
        default = 1048576;
        description = "Data segment limit";
      };

      listenIp = mkOption {
        default = "127.0.0.1";
        description = "Listening IP address. Should be the external IP.";
      };

      root = mkOption {
        default = "/var/db/tinydns/root";
        description = "tinydns root dir";
      };

      log = mkOption {
        default = {
          user = "dnslog";
          dirs = { "/var/log/dns/server" = {}; };
        };
        description = "Logging configuration (as per runit log service)";
      };

    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkg ];

    users.extraUsers.tinydns = {
      uid = config.ids.uids.tinydns;
      group = "tinydns";
      description = "tinydns service user";
    };

    users.extraGroups.tinydns.gid = config.ids.gids.tinydns;

    runit.services.tinydns = {
      env = {
        IP = cfg.listenIp;
        ROOT = cfg.root;
      };

      stdErrToOut = true;

      cmd = "${pkgs.runit}/bin/chpst -U tinydns -d ${toString cfg.dataLimit} ${pkg}/bin/tinydns";

      log = cfg.log;
    };

  };

}

# vim: et ts=2 sw=2
