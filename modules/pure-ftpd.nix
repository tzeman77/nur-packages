{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.pure-ftpd;
  pkg = pkgs.pure-ftpd;

  boolOpt = p : name : if p then " --${name}" else "";

  valOpt = p : name : if ! isNull p then " --${name} ${toString p}" else "";

in

{
  ###### interface
  options = {

    services.pure-ftpd = {

      enable = mkOption {
        default = false;
        description = "Whether to enable pure-ftpd service.";
      };

      # -0      --notruncate    
      notruncate = mkOption {
        default = true;
        description = ''
          When a file is uploaded and there is already a previous version of
          the file with the same name, the old file will neither get removed
          nor truncated.  Upload will take place in a temporary file and once
          the upload is complete, the switch to the new version will be atomic.
          For instance, when a large PHP script is being uploaded, the web
          server will still serve the old version and immediatly switch to the
          new one as soon as the full file will have been
          transfered.
        '';
      };

      # -1      --logpid        
      logpid = mkOption {
        default = false;
        description = "Log the PID of each session in syslog output.";
      };

      # -4      --ipv4only      
      ipv4only = mkOption {
        default = false;
        description = "Only listen to IPv4 connections.";
      };

      # -6      --ipv6only      
      ipv6only = mkOption {
        default = false;
        description = "Don't listen to IPv4, only listen to IPv6.";
      };

      # -A      --chrooteveryone        
      chrooteveryone = mkOption {
        default = false;
        description = ''
          chroot(2) everyone, but root. There's no such thing as a trusted
          group. '-A' and '-a gid' are mutually exclusive.
        '';
      };

      # -a      --trustedgid    <opt>
      trustedgid = mkOption {
        default = null;
        type = types.nullOr types.int;
        example = 100;
        description = ''
          Authenticated users will be granted access to their home directory
          and nothing else (chroot) . This is especially useful for users
          without shell access, for instance, WWW-hosting services shared by
          several customers. Only member of group number <code>gid</code> will
          have unrestricted access to the whole filesystem. So add a "staff",
          "admin" or "ftpadmin" group and put your trusted users in.
          <code>gid</code> is a NUMERIC group number, not a group name.  This
          feature is mainly designed for system users, not for virtual ones.

          Note: 'root' (uid 0) always has full filesystem access.

          If you want to chroot(2) everyone, but root, use
          <code>chrooteveryone</code>.
        '';
      };

      # -b      --brokenclientscompatibility    
      brokenclientscompatibility = mkOption {
        default = false;
        description = ''
          Ignore parts of RFC standards in order to deal with some totally
          broken FTP clients, or broken firewalls/NAT boxes. Also, non-dangling
          symbolic links are shown as real files/directories.
        '';
      };

      # -C      --maxclientsperip       <opt>
      maxclientsperip = mkOption {
        default = 5;
        description = ''
          Limit the number of simultanous connections coming from the same IP
          address. This is yet another very effective way to prevent stupid
          denial of services and bandwidth starvation by a single user.  It
          works only when the server is launched in standalone mode (if you use
          a super-server, it is supposed to do that) . If the server is
          launched with '-C 2', it doesn't mean that the total number of
          connections is limited to 2.  But the same client, coming from the
          same machine (or at least the same IP), can't have more than two
          simultaneous connections. This feature needs some memory to track IP
          addresses, but it's recommended to use it.
        '';
      };

      # -c      --maxclientsnumber      <opt>
      maxclientsnumber = mkOption {
        default = 50;
        description = ''
          Allow a maximum of clients to be connected. For instance '-c 42' will
          limit access to simultaneous 42 clients. There is a 50 client limit
          by default.
        '';
      };

      # -d      --verboselog    
      verboselog = mkOption {
        default = false;
        description = ''
          Send various debugging messages to the syslog. Don't use this unless
          you really want to debug Pure-FTPd. Passwords aren't logged.
          Duplicate '-d' to log responses, too.
        '';
      };

      # -D      --displaydotfiles       
      displaydotfiles = mkOption {
        default = false;
        description = ''
          List files beginning with a dot ('.') even when the client doesn't
          append the '-a' option to the list command. A workaround for badly
          configured FTP clients. If you are a purist, don't enable this. If
          you provide hosting services and if you have lousy customers, enable
          this.
        '';
      };

      # -e      --anonymousonly 
      anonymousonly = mkOption {
        default = false;
        description = ''
          Only allow anonymous users. Use this on a public FTP site with no
          remote FTP access to real accounts.
        '';
      };

      # -E      --noanonymous   
      noanonymous = mkOption {
        default = false;
        description = ''
          Only allow authenticated users. Anonymous logins are prohibited.
        '';
      };

      # -f      --syslogfacility        <opt>
      syslogfacility = mkOption {
        default = "ftp";
        description = ''
          Use that facility for syslog logging. Logging can be disabled with
          <code>none</code>.
        '';
      };

      # -G      --norename      
      norename = mkOption {
        default = false;
        description = "Disallow renaming.";
      };

      # -H      --dontresolve   
      dontresolve = mkOption {
        default = false;
        description = ''
          By default, fully-qualified host names are logged. To achieve this,
          DNS lookups are mandatory. The '-H' flag avoids host names
          resolution.  ("213.41.14.252" will be logged instead of
          "www.toolinux.com") . It can significantly speed up connections and
          reduce bandwidth usage on busy servers. Use it especially on public
          FTP sites. Also, please note that without -H, host names are
          informative but shouldn't be trusted: no reverse mapping check is
          done to save DNS queries.
        '';
      };

      # -I      --maxidletime   <opt>
      maxidletime = mkOption {
        default = 15;
        description = ''
          Change the maximum idle time. The timeout is in minutes and defaults
          to 15 minutes. Modern FTP clients are trying to fool timeouts by
          sending fake commands at regular interval. We disconnect these
          clients when they are idle for twice (because they are active anyway)
          the normal timeout.
        '';
      };

      # -i      --anonymouscantupload   
      anonymouscantupload = mkOption {
        default = true;
        description = ''
          Disallow upload for anonymous users, whatever directory permissions
          are. This option is especially useful for virtual hosting, to avoid
          your users creating warez sites in their account.
        '';
      };

      # -j      --createhomedir 
      createhomedir = mkOption {
        default = false;
        description = ''
          If the home directory of a user doesn't exist, automatically create
          it. The newly created home directory belongs to the user and
          permissions are set according to the current directory mask. Only the
          home directory can be created (so /home/john/./public_html won't
          work, but /home/john will) . To avoid local attacks, the parent
          directory should never belong to an untrusted user. Also note that
          you must trust whoever manages the users databases, because with that
          feature, he'll be able to create/chown directories anywhere on the
          server's filesystem.
        '';
      };

      # -K      --keepallfiles  
      keepallfiles = mkOption {
        default = false;
        description = ''
          Allow users to resume and upload files, but *NOT* to delete or rename
          them. Directories can be removed, but only if they are empty.
          However, overwriting existing files is still allowed (to support
          upload resume) . If you want to disable this too, add -r
          (--autorename) .
        '';
      };

      # -k      --maxdiskusagepct       <opt>
      maxdiskusagepct = mkOption {
        default = 95;
        description = ''
          Don't allow uploads if the partition is more than
          <code>percentage</code>% full.  For instance, "-k 95" will ensure
          your disks will never get filled more than 95% by FTP. No need for
          the "percent" sign after the number.
        '';
      };

      # -l      --login <opt>
      authentication = mkOption {
        default = "unix";
        description = ''
          Adds a new rule to the authentication chain. Syntax:
          <code>authentication</code> or <code>authentication:config file</code>.
        '';
      };

      # -L      --limitrecursion        <opt>
      lsMaxFiles = mkOption {
        default = 10000;
        description = ''
          To avoid stupid denial-of-service attacks (or just CPU hogs),
          Pure-FTPd never displays more than 10000 files in response to an 'ls'
          command.
        '';
      };

      # -L      --limitrecursion        <opt>
      lsMaxDepth = mkOption {
        default = 5;
        description = ''
          A recursive 'ls' (-R) never goes further than 5 subdirectories.
        '';
      };

      # -M      --anonymouscancreatedirs        
      anonymouscancreatedirs = mkOption {
        default = false;
        description = "Allow anonymous users to create directories.";
      };

      # -m      --maxload       <opt>
      maxload = mkOption {
        default = 8;
        description = ''
          Don't allow anonymous download if the load is above
          <code>cpu load</code>. A very efficient way to prevent overloading
          your server. Upload is still allowed, though.
        '';
      };

      # -N      --natmode       
      natmode = mkOption {
        default = false;
        description = ''
          NAT mode. Force ACTIVE mode. If your FTP server is behind a NAT box
          that doesn't support applicative FTP proxying, or if you use port
          redirection without a transparent FTP proxy, use this. Well... the
          previous sentence isn't very clear. Okay: if your network looks like
          this: (FTP server)-------(NAT/masquerading gateway/router)------(Internet)
          and if you want people coming from the internet to have access to
          your FTP server, please try without this option first. If Netscape
          clients can connect without any problem, your NAT gateway rulez. If
          Netscape doesn't display directory listings, your NAT gateway sucks.
          Use natmode as a workaround.
        '';
      };

      # -n      --quota <opt>
      quotaMaxFiles = mkOption {
        default = 10000;
        description = ''
          Max files quota. Enforce quota settings for all users (except members
          of the 'trusted' group).
        '';
      };

      # -n      --quota <opt>
      quotaMaxSize = mkOption {
        default = 1024;
        description = ''
          Max size (MB) quota. Enforce quota settings for all users (except
          members of the 'trusted' group).
        '';
      };

      # -O      --altlog        <opt>
      altlog = mkOption {
        default = null;
        type = types.nullOr types.str;
        example = "clf:/var/log/pureftpd.log";
        description = ''
          <code>format:log file</code>: Record all file transfers into a
          specific log file, in an alternative format. Currently, four formats
          are supported: CLF (Apache-like), Stats, W3C and xferlog.

          If you add '-O clf:/var/log/pureftpd.log' to your starting options,
          Pure-FTPd will log transfers in /var/log/pureftpd.log in a format
          similar to the Apache web server in default configuration. 

          If you use '-O stats:/var/log/pureftpd.log' to your starting options,
          Pure-FTPd will create log files in a special format, designed for
          statistical reports. The Stats format is compact, more efficient and
          more accurate that CLF and the old broken "xferlog" format.

          The Stats format is:
          <code>date session id user ip 'U or D' size duration file</code>

          <code>date</code> is a GMT timestamp (time()) and <code>session
          id</code> identifies the current session. <code>file</code> is
          unquoted, but it's always the last element of a log line.  "U" means
          "Upload" and "D" means "Download".

          Warning: the session id is only designed for statistics purposes.
          While it's always an unique string in the real world, it's
          theoretically possible to have it non unique in very rare conditions.
          So don't rely on it for critical missions.

          A command called "pure-statsdecode" can be used to convert timestamps
          into human-readable dates.

          The W3C format is enabled with '-O w3c:/var/log/pureftpd.log' .

          For security purposes, the path must be absolute (eg.
          /var/log/pureftpd.log , not ../log/pureftpd.log). If this log file is
          stored on a NFS volume, don't forget to start the lock manager (often
          called "lockd" or "rpc.lockd").
        '';
      };

      # -p      --passiveportrange      <opt>
      passiveportrange = mkOption {
        default = null;
        type = types.nullOr types.str;
        example = "40000:50000";
        description = ''
          <code>first port:last port</code>: Use only ports in the range
          <code>first port</code> to <code>last port</code> inclusive for
          passive-mode downloads. This is especially useful if the server is
          behind a firewall without FTP connection tracking.  Use high ports
          (40000-50000 for instance), where no regular server should be
          listening.
        '';
      };

      # -P      --forcepassiveip        <opt>
      forcepassiveip = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          <code>ip address or host name</code>: Force the specified IP address
          in reply to a PASV/EPSV/SPSV command. If the server is behind a
          masquerading (NAT) box that doesn't properly handle stateful FTP
          masquerading, put the ip address of that box here. If you have a
          dynamic IP address, you can put the public host name of your gateway,
          that will be resolved every time a new client will connect.
        '';
      };

      # -q      --anonymousratio        <opt>
      anonymousratio = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          <code>upload ratio:download ratio</code>: Enable ratios for anonymous
          users.
        '';
      };

      # -Q      --userratio     <opt>
      userratio = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          <code>upload ratio:download ratio</code>': Enable ratios for
          everybody (anonymous and non-anonymous). Members of the root (0,
          something called 'wheel') have no ratio.
        '';
      };

      # -r      --autorename    
      autorename = mkOption {
        default = false;
        description = ''
          Never overwrite existing files. Uploading a file whose name already
          exists cause an automatic rename. Files are called xyz, xyz.1, xyz.2,
          xyz.3, etc.
        '';
      };

      # -R      --nochmod       
      nochmod = mkOption {
        default = false;
        description = ''
          Disallow users (even non-anonymous ones) usage of the CHMOD command.
          On hosting services, it may prevent newbies from making mistakes,
          like setting bad permissions on their home directory. Only root can
          use CHMOD when -R is enabled.
        '';
      };

      # -s      --antiwarez     
      antiwarez = mkOption {
        default = false;
        description = ''
          The "waReZ protection". Don't allow anonymous users to download files
          owned by "ftp" (generally, files uploaded by other anonymous users).
          So that uploads have to be validated by a system administrator (chown
          to another user) before being available for download.
        '';
      };

      # -S      --bind  <opt>
      bind = mkOption {
        default = "21";
        description = ''
          <code>[ip address,|hostname,] [port|service name]</code>. This option
          is only effective when the server is launched as a standalone server.
          Connections are accepted on the specified IP and port. IPv4 and IPv6
          are supported. Numeric and fully-qualified host names are accepted. A
          service name (see /etc/services) can be used instead of a numeric
          port number.
        '';
      };

      # -t      --anonymousbandwidth    <opt>
      anonymousbandwidth = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          Enable bandwidth limitation. <code>bandwidth</code> is specified in
          kilobytes/seconds. To set up separate upload/download bandwidth, the
          <code>[upload]:[download]</code> syntax is supported.
        '';
      };

      # -T      --userbandwidth <opt>
      userbandwidth = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          Enable bandwidth limitation. <code>bandwidth</code> is specified in
          kilobytes/seconds. To set up separate upload/download bandwidth, the
          <code>[upload]:[download]</code> syntax is supported.
        '';
      };

      # -U      --umask <opt>
      umask = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          <code>umask for files:umask for dirs</code>: Change the file creation
          mask.  The default is 133:022. If you want a new file uploaded by a
          user to only be readable by that user, use '-U 177:077'. If you want
          uploaded files to be executable, use 022:022 (files will be readable
          -but not writable- by other users) or 077:077 (files will only be
          executable and readable by their owner). Please note that Pure-FTPd
          support the SITE CHMOD extension, so a user can change the
          permissions of his own files.
        '';
      };

      # -u      --minuid        <opt>
      minuid = mkOption {
        default = 100;
        description = ''
          Don't allow uids below <code>uid</code> to log in. '-u 1' denies
          access to root (safe), '-u 100' denies access to virtual accounts on
          most Linux distros.
        '';
      };

      # -V      --trustedip     <opt>
      trustedip = mkOption {
        default = null;
        type = types.nullOr types.str;
        description = ''
          <code>ip address</code>: Allow non-anonymous FTP access only on this
          specific local IP address. All other IP addresses are only anonymous.
          With that option, you can have routed IPs for public access and a
          local IP (like 10.x.x.x) for administration. You can also have a
          routable trusted IP protected by firewall rules and only that IP can
          be used to login as a non-anonymous user.
        '';
      };

      # -w      --allowuserfxp  
      allowuserfxp = mkOption {
        default = false;
        description = ''
          Support the FXP protocol only for authenticated users. FXP works with
          IPv4 and IPv6 addresses. Enable only if you know what you're doing!
        '';
      };

      # -W      --allowanonymousfxp     
      allowanonymousfxp = mkOption {
        default = false;
        description = ''
          Support the FXP protocol. FXP allows transfers between two remote
          servers without any file data going to the client asking for the
          transfer. Enable only if you know what you're doing!
        '';
      };

      # -x      --prohibitdotfileswrite 
      prohibitdotfileswrite = mkOption {
        default = false;
        description = ''
          In normal operation mode, authenticated users can read/write files
          beginning with a dot ('.'). Anonymous users can't, for security
          reasons (like changing banners or a forgotten .rhosts). When
          <code>prohibitdotfileswrite</code> is used, authenticated users can
          download dot-files, but not overwrite/create them, even if they own
          them. That way, you can prevent hosted users from messing .qmail
          files. If you want to give user access to a special dot-file, create
          a symbolic link to the dot-file with a file name that has no dot in
          it and the client will be able to retrieve the file through that
          link.
        '';
      };

      # -X      --prohibitdotfilesread  
      prohibitdotfilesread = mkOption {
        default = false;
        description = ''
          This flag is identical to the <code>prohibitdotfileswrite</code>
          (writing dot-files is prohibited), but in addition, users can't even
          *read* files and directories beginning with a dot (like "cd .ssh") .
        '';
      };

      # -Y      --tls   <opt>
      tls = mkOption {
        default = 0;
        description = ''
          '0': Disable the SSL/TLS encryption layer (default).
          '1': Accept both standard and encrypted sessions.
          '2': Refuse connections that aren't using SSL/TLS security mechanisms,
               including anonymous sessions. The server must have been compiled
               with --with-tls and a valid certificate must be in place to get
               this feature.  See the README.TLS file for more info about
               SSL/TLS.
          '3': Cleartext sessions are refused and only SSL/TLS compatible
               clients are accepted. Clear data connections are also refused,
               so private data connections are enforced.
        '';
      };

      # -J      --tlsciphersuite        <opt>
      tlsciphersuite = mkOption {
        default = null;
        type = types.nullOr types.str;
        example = "HIGH:MEDIUM:+TLSv1:!SSLv2:+SSLv3";
        description = ''
          <code>ciphers</code>: Sets the list of ciphers that will be accepted
          for SSL/TLS connections. Prefixing the list with -S: totally disables
          SSLv3.
        '';
      };

      # -z      --allowdotfiles 
      allowdotfiles = mkOption {
        default = false;
        description = ''
          Allow anonymous users to read files and directories starting with a
          dot ('.').
        '';
      };

      # -Z      --customerproof 
      customerproof = mkOption {
        default = false;
        description = ''
          Try to protect customers against common mistakes to avoid your
          technical support being busy with stupid issues. Right now,
          <code>customerproof</code> switch prevents your users against making
          bad 'chmod' commands, that would deny access to files/directories to
          themselves. The switch may turn on other features in the future. If
          you are a hosting provider, turn this on.
        '';
      };
    };
  };
  
  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkg ];

    systemd.services.pure-ftpd = {
      description = "Pure-FTPd service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkg}/sbin/pure-ftpd" +
          boolOpt cfg.notruncate "notruncate" +
          boolOpt cfg.logpid "logpid" +
          boolOpt cfg.ipv4only "ipv4only" +
          boolOpt cfg.ipv6only "ipv6only" +
          boolOpt cfg.chrooteveryone "chrooteveryone" +
          valOpt cfg.trustedgid "trustedgid" +
          boolOpt cfg.brokenclientscompatibility "brokenclientscompatibility" +
          " --maxclientsperip ${toString cfg.maxclientsperip}" +
          " --maxclientsnumber ${toString cfg.maxclientsnumber}" +
          boolOpt cfg.verboselog "verboselog" +
          boolOpt cfg.displaydotfiles "displaydotfiles" +
          boolOpt cfg.anonymousonly "anonymousonly" +
          boolOpt cfg.noanonymous "noanonymous" +
          " --syslogfacility ${cfg.syslogfacility}" +
          boolOpt cfg.norename "norename" +
          boolOpt cfg.dontresolve "dontresolve" +
          " --maxidletime ${toString cfg.maxidletime}" +
          boolOpt cfg.anonymouscantupload "anonymouscantupload" +
          boolOpt cfg.createhomedir "createhomedir" +
          boolOpt cfg.keepallfiles "keepallfiles" +
          " --maxdiskusagepct ${toString cfg.maxdiskusagepct}" +
          " --login ${cfg.authentication}" +
          " --limitrecursion ${toString cfg.lsMaxFiles}:${toString cfg.lsMaxDepth}" +
          boolOpt cfg.anonymouscancreatedirs "anonymouscancreatedirs" +
          " --maxload ${toString cfg.maxload}" +
          boolOpt cfg.natmode "natmode" +
          " --quota ${toString cfg.quotaMaxFiles}:${toString cfg.quotaMaxSize}" +
          valOpt cfg.altlog "altlog" +
          valOpt cfg.passiveportrange "passiveportrange" +
          valOpt cfg.forcepassiveip "forcepassiveip" +
          valOpt cfg.anonymousratio "anonymousratio" +
          valOpt cfg.userratio "userratio" +
          boolOpt cfg.autorename "autorename" +
          boolOpt cfg.nochmod "nochmod" +
          boolOpt cfg.antiwarez "antiwarez" +
          " --bind ${cfg.bind}" +
          valOpt cfg.anonymousbandwidth "anonymousbandwidth" +
          valOpt cfg.userbandwidth "userbandwidth" +
          valOpt cfg.umask "umask" +
          " --minuid ${toString cfg.minuid}" +
          valOpt cfg.trustedip "trustedip" +
          boolOpt cfg.allowuserfxp "allowuserfxp" +
          boolOpt cfg.allowanonymousfxp "allowanonymousfxp" +
          boolOpt cfg.prohibitdotfileswrite "prohibitdotfileswrite" +
          boolOpt cfg.prohibitdotfilesread "prohibitdotfilesread" +
          " --tls ${toString cfg.tls}" +
          valOpt cfg.tlsciphersuite "tlsciphersuite" +
          boolOpt cfg.allowdotfiles "allowdotfiles" +
          boolOpt cfg.customerproof "customerproof";
        Restart = "always";
        Type = "simple";
      };
    };

  };
}

# vim: et ts=2 sw=2

