{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.runit.qmail;
  pkg = cfg.package;
  uids = config.ids.uids;
  gids = config.ids.gids;

  virtualDomainsF = concatStringsSep "\n" (mapAttrsToList (d: u:
    "${d}:${u}") cfg.virtualdomains);

  qmailDerivation = pkgs.stdenv.mkDerivation {
    name = "qmail";
    preferLocalBuild = true;
    buildCommand = ''
      mkdir -p $out/{alias,control}
      echo "${cfg.me}" > $out/control/me
      echo "${concatStringsSep "\n" cfg.locals}" > $out/control/locals
      echo "${cfg.plusdomain}" > $out/control/plusdomain
      echo "${concatStringsSep "\n" cfg.rcpthosts}" > $out/control/rcpthosts
      echo "${virtualDomainsF}" > $out/control/virtualdomains
      ${concatStringsSep "\n" (mapAttrsToList (n: v:
        "echo -n '${v}' > $out/alias/.qmail-${n}"
      ) cfg.aliases)}
      ${concatStringsSep "\n" (mapAttrsToList (n: v:
        "echo -n '${v}' | sed -e 's/^  \+//' > $out/control/${n}"
      ) cfg.control)}
      mkdir -p $out/control/notlshosts
      ${concatStringsSep "\n" (map (v:
	"touch $out/control/notlshosts/${v}"
      ) cfg.notlshosts)}
    '';
  };

in

{

  ###### interface

  options = {

    runit.qmail = {

      enable = mkOption {
        default = false;
        description = "Whether to enable qmail service.";
      };

      defaultdelivery = mkOption {
        default = "./Maildir/";
        description = "Default delivery (mbox or maildir). See qmail-start(8).";
      };

      me = mkOption {
        default = "";
        description = "Fully qualified name of this host.";
      };

      defaultdomain = mkOption {
        default = "";
        description = "Default domain name. See qmail-inject(8).";
      };

      locals = mkOption {
        default = [];
        description = ''
          List of domain names that the current host receives mail for. See
          qmail-send(8).
        '';
      };

      plusdomain = mkOption {
        default = "";
        description = ''
          Plus domain name. qmail-inject adds this name to any host name that
          ends with a plus sign. See qmail-inject(8).
        '';
      };

      rcpthosts = mkOption {
        default = [];
        description = ''
          List of domain names that the current host receives mail for. See
          qmail-send(8).
        '';
      };

      virtualdomains = mkOption {
        default = {};
        type = types.attrsOf types.str;
        description = "List of virtual users or domains. See qmail-send(8).";
        example = {
          "example.org" = "jsmith";
        };
      };

      aliases = mkOption {
        default = {};
        type = types.attrsOf types.str;
        example = {
          root = "jsmith";
          postmaster = "another user";
        };
        description = ''
          Global qmail aliases configuration. Addresses that don't start with a
          username are controlled by a special user, alias. Delivery
          instructions for foo go into ~alias/.qmail-foo; delivery instructions
          for user-foo go into ~user/.qmail-foo. See dot-qmail(5) for the full
          story or doc/INSTALL.alias in qmail installaction directory.
        '';
      };

      notlshosts = mkOption {
        default = [];
        description = ''
	  List of fully-qualified domain name of the servers for which
	  qmail-remote will not try TLS. See qmail-remote(8).
        '';
      };

      control = mkOption {
        default = {};
        type = types.attrsOf types.str;
        description = "Additional qmail control files. See qmail-control(8).";
        example = {
          "concurrencylocal" = "25";
          "badmailfrom" = ''
            .*spam.*
            # force users to fully qualify themselves (ie deny "user", accept "user@domain")
            !@
            xxx
          '';
        };
      };

      log = mkOption {
        default = {};
        description = "Qmail log configuration. See runit logging.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.qmail;
        description = "Qmail package to use";
      };

    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkg ];

    security.wrappers = {
      "qmail-queue" = {
        setuid = true;
        source = "${pkg}/bin/qmail-queue";
        owner = "qmailq";
        group = "qmail";
      };
    };

    # groups
    users.extraGroups = {
      qmail.gid = gids.qmail;
      nofiles.gid = gids.nofiles;
    };

    users.extraUsers = {
      alias = {
        uid = uids.alias;
        group = "nofiles";
        home = "/var/qmail/alias";
        createHome = false;
        isSystemUser = true;
      };
      qmaild = { uid = uids.qmaild; group = "nofiles"; isSystemUser = true; };
      qmaill = { uid = uids.qmaill; group = "nofiles"; isSystemUser = true; };
      qmailp = { uid = uids.qmailp; group = "nofiles"; isSystemUser = true; };
      qmailq = { uid = uids.qmailq; group = "qmail"; isSystemUser = true; };
      qmailr = { uid = uids.qmailr; group = "qmail"; isSystemUser = true; };
      qmails = { uid = uids.qmails; group = "qmail"; isSystemUser = true; };
    };

    runit.services.qmail = {

      preRun = ''
        #!${pkgs.bash}/bin/sh
        qdir=/var/qmail/queue
        cdir=/var/qmail/control
        adir=/var/qmail/alias
        bdir=/var/qmail/bin
        [ -d $qdir ] || ${pkg}/bin/queue-fix $qdir
        [ -d $cdir -a ! -L $cdir ] && mv $cdir $cdir.bak
        ln -sfn ${qmailDerivation}/control $cdir
        [ -d $adir -a ! -L $adir ] && mv $adir $adir.bak
        ln -sfn ${qmailDerivation}/alias $adir
        [ -d $bdir ] || mkdir -p $bdir
        for i in ${pkg}/bin/*; do
          if [ `basename $i` = "qmail-queue" ]; then
            ln -sfn /run/wrappers/bin/qmail-queue $bdir
          else
            ln -sfn $i $bdir
          fi
        done
      '';

      cmd = "${pkg}/bin/qmail-start ${cfg.defaultdelivery}";

      log = cfg.log;

    };

  };

}

