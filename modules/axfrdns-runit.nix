{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.runit.axfrdns;
  tcfg = config.runit.tinydns;
  pkg = pkgs.djbdns;
  ucspi = pkgs.ucspi-tcp;

in

{

  ###### interface

  options = {

    runit.axfrdns = {

      enable = mkOption {
        default = false;
        description = "Whether to enable axfrdns service.";
      };

      dataLimit = mkOption {
        default = 1048576;
        description = "Data segment limit";
      };

      listenIp = mkOption {
        default = "127.0.0.1";
        description = "Listening IP address. Should be the external IP.";
      };

      log = mkOption {
        default = {
          user = "dnslog";
          dirs = { "/var/log/dns/axfr" = {}; };
        };
        description = "Logging configuration (as per runit log service)";
      };

    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkg ];

    users.extraUsers.axfrdns = {
      uid = config.ids.uids.axfrdns;
      group = "axfrdns";
      description = "axfrdns service user";
    };

    users.extraGroups.axfrdns.gid = config.ids.gids.axfrdns;

    runit.services.axfrdns = {
      env = {
        IP = cfg.listenIp;
        ROOT = tcfg.root; # shared w/ tinydns service
        AXFR = "none"; # disable zone transfers
      };

      stdErrToOut = true;

      cmd = "${pkgs.runit}/bin/chpst -U axfrdns -d ${toString cfg.dataLimit} ${ucspi}/bin/tcpserver -vDRHl0 -- ${cfg.listenIp} 53 ${pkg}/bin/axfrdns";

      log = cfg.log;
    };

  };

}

# vim: et ts=2 sw=2

