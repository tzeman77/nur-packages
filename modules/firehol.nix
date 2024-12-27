{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.networking.firehol;
  pkg = pkgs.firehol;

in

{

  ###### interface

  options = {

    networking.firehol.enable = mkOption {
      default = false;
      description = "Whether to enable firehol firewall.";
    };

    networking.firehol.configuration = mkOption {
      default = ''
        version 5

        interface any world
          client all accept
      '';
      description = "Firehol configuration, see firehol.conf(5).";
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall.enable = false; # mutually exclusive with nixos default firewall.

    boot.kernelModules = [ "configs" ];

    environment.etc."firehol/firehol.conf".text = cfg.configuration;

    environment.systemPackages = [ pkg pkgs.iptables ];

    systemd.services.firehol = {
      description = "Firehol firewall";
      wantedBy = [ "network.target" ];
      #after = [ "network-interfaces.target" ];
      path = with pkgs; [ gnugrep findutils gawk gnused procps gzip iproute2 iprange
        which iptables kmod  ];

      preStart = "mkdir -p /var/spool";

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = ''
          ${pkg}/sbin/firehol stop
        '';
      };

      script = ''
        ${pkg}/sbin/firehol start
      '';
    };

  };

}

# vim: et ts=2 sw=2 
