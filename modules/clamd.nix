{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.clamd;
  stateDir = "/var/lib/clamav"; # synchronize w/ clamav.nix

in

{
  ###### interface
  options = {
    services.clamd = {
      enable = mkOption {
        default = false;
        description = "Whether to enable clamd(8) service.";
      };

      config = mkOption {
        default = "";
        description = "clamd(8) configuration which will be appended to clamd.conf(5).";
      };

    };
  };
  
  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.clamav ];

    services.clamd.config = ''
      DatabaseDirectory ${stateDir}
      Foreground yes
    '';

    environment.etc."clamd.conf".text = cfg.config;

    systemd.services.clamd = {
      description = "clamd(8) service";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.clamav}/sbin/clamd --config-file=/etc/clamd.conf
        '';
        Restart = "always";
        Type = "simple";
      };
    };
  };
}

# vim: et ts=2 sw=2
