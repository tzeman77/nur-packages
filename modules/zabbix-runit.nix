{ config, lib, pkgs, ... }:

with lib;

let

  stateDir = "/var/lib/zabbix";

  a_cfg = config.runit.zabbixAgent;
  a_file = pkgs.writeText "zabbix_agentd.conf"
    ''
      LogType = console
      Server = ${a_cfg.server}
      StartAgents = 1

      ${a_cfg.extraConfig}
    '';

  p_cfg = config.runit.zabbixProxy;
  p_file = pkgs.writeText "zabbix_proxy.conf"
    ''
      LogType = console
      Server = ${p_cfg.server}
      Hostname = ${p_cfg.hostname}
      DBName = ${p_cfg.stateDir}/proxy.sqlite

      ${p_cfg.extraConfig}
    '';

  s_cfg = config.runit.zabbixServer;
  s_file = pkgs.writeText "zabbix_server.conf"
    ''
      LogType = console

      ${optionalString (s_cfg.dbServer != "localhost") ''
        DBHost = ${s_cfg.dbServer}
      ''}

      DBName = ${s_cfg.dbName}

      DBUser = ${s_cfg.dbUser}

      ${optionalString (s_cfg.dbPassword != "") ''
        DBPassword = ${s_cfg.dbPassword}
      ''}

      ${s_cfg.extraConfig}
    '';


in

{

  ###### interface

  options = {

    runit.zabbixAgent = {

      enable = mkOption {
        default = false;
        description = ''
          Whether to run the Zabbix monitoring agent on this machine.
          It will send monitoring data to a Zabbix server.
        '';
      };

      server = mkOption {
        default = "127.0.0.1";
        description = ''
          The IP address or hostname of the Zabbix server to connect to.
        '';
      };

      extraConfig = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Configuration that is injected verbatim into the configuration file.
        '';
      };

      package = mkOption {
        default = pkgs.zabbix.agent;
        type = types.package;
        description = "Zabbix agent package.";
      };

      user = mkOption {
        default = "zabbix";
        type = types.str;
        description = "Run zabbix agent as user.";
      };

      log = mkOption {
        default = {
          user = "zabbix";
          dirs = { "/var/log/zabbix/agent" = {}; };
        };
        description = "Zabbix agent log configuration. See runit logging.";
      };

    };

    runit.zabbixProxy = {

      enable = mkOption {
        default = false;
        description = ''
          Whether to run the Zabbix monitoring proxy on this machine.
          It will send monitoring data to a Zabbix server.
        '';
      };

      hostname = mkOption {
        type = types.str;
        description = ''
          The Proxy hostname. Mandatory.
        '';
      };

      server = mkOption {
        default = "127.0.0.1";
        description = ''
          The IP address or hostname of the Zabbix server to connect to.
        '';
      };

      extraConfig = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Configuration that is injected verbatim into the configuration file.
        '';
      };

      package = mkOption {
        default = pkgs.zabbix.proxy-sqlite;
        type = types.package;
        description = "Zabbix proxy package.";
      };

      user = mkOption {
        default = "zabbix";
        type = types.str;
        description = "Run zabbix proxy as user.";
      };

      stateDir = mkOption {
        default = stateDir;
        type = types.str;
        description = "Zabbix proxy state dir (where sqlite db is stored).";
      };

      log = mkOption {
        default = {
          user = "zabbix";
          dirs = { "/var/log/zabbix/proxy" = {}; };
        };
        description = "Zabbix proxy log configuration. See runit logging.";
      };

    };

    runit.zabbixServer = {

      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Whether to run the Zabbix server on this machine.
        '';
      };

      dbServer = mkOption {
        default = "localhost";
        type = types.str;
        description = ''
          Hostname or IP address of the database server.
          Use an empty string ("") to use peer authentication.
        '';
      };

      dbName = mkOption {
        default = "zabbix";
        type = types.str;
        description = ''
          Database name.
        '';
      };

      dbUser = mkOption {
        default = "zabbix";
        type = types.str;
        description = ''
          Database user.
        '';
      };

      dbPassword = mkOption {
        default = "";
        type = types.str;
        description = "Password used to connect to the database server.";
      };

      extraConfig = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Configuration that is injected verbatim into the configuration file.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.zabbix.server-mysql;
        description = "Zabbix package to use";
      };

      user = mkOption {
        default = "zabbix";
        type = types.str;
        description = "Run zabbix server as user.";
      };

      log = mkOption {
        default = {
          user = "zabbix";
          dirs = { "/var/log/zabbix/server" = {}; };
        };
        description = "Zabbix server log configuration. See runit logging.";
      };

    };

  };


  ###### implementation

  config = mkMerge [
  
    (mkIf (a_cfg.enable || p_cfg.enable || s_cfg.enable) {
      users.extraUsers.zabbix = {
        uid = config.ids.uids.zabbix;
        group = "zabbix";
        description = "Zabbix daemon user";
      };
      users.extraGroups.zabbix.gid = config.ids.gids.zabbix;
    })

    (mkIf a_cfg.enable {
      runit.services."zabbix-agent" = {
        user = a_cfg.user;
        cmd = "${a_cfg.package}/bin/zabbix_agentd -f -c ${a_file}";
        log = a_cfg.log;
      };
    })
    
    (mkIf p_cfg.enable {
      runit.services."zabbix-proxy" = {
        preRun = ''
          #!${pkgs.bash}/bin/sh
          mkdir -p ${p_cfg.stateDir}
          chown -R ${p_cfg.user} ${p_cfg.stateDir}
        '';
        user = p_cfg.user;
        cmd = "${p_cfg.package}/bin/zabbix_proxy -f -c ${p_file}";
        log = p_cfg.log;
      };
    })

    (mkIf s_cfg.enable {
      runit.services."zabbix-server" = {
        user = s_cfg.user;
        cmd = "${s_cfg.package}/bin/zabbix_server -f -c ${s_file}";
        log = s_cfg.log;
      };
    })

  ];

}
