{ stdenv, fetchurl, pkgconfig, postgresql, curl, openssl, zlib, gettext
, net_snmp , libssh2, openldap
, pcre
, libevent
, sqlite
, enableJabber ? false, minmay ? null
, enableSnmp ? false
, enableSsh ? false
, enableLdap ? false
, mysqlPackage ? null
}:

assert enableJabber -> minmay != null;

let

  version = "3.4.9";
  branch = "3.4";

  src = fetchurl {
    url = "mirror://sourceforge/zabbix/zabbix-${version}.tar.gz";
    sha256 = "0r0zvag0gjm2rywyddmfl1mg826kbq689k1yzmzxdv174mqjqn1i";
  };

  preConfigure =
    ''
      substituteInPlace ./configure \
        --replace " -static" "" \
        ${stdenv.lib.optionalString (stdenv.cc.libc != null) ''
          --replace /usr/include/iconv.h ${stdenv.lib.getDev stdenv.cc.libc}/include/iconv.h
        ''}
    '';

  withDb = if mysqlPackage == null then "--with-pgsql" else "--with-mysql";

  inputDb = if mysqlPackage == null then postgresql else mysqlPackage;

in

{
  recurseForDerivations = true;

  server = stdenv.mkDerivation {
    name = "zabbix-server-${version}";

    inherit src preConfigure;

    configureFlags = [
      "--enable-server"
      "--with-libcurl"
      "--with-libevent=${libevent}"
      "--with-libpcre=${pcre.dev}"
      withDb
    ]
    ++ stdenv.lib.optional enableJabber "--with-jabber=${minmay}"
    ++ stdenv.lib.optional enableSnmp "--with-net-snmp"
    ++ stdenv.lib.optional enableSsh "--with-ssh2=${libssh2.dev}"
    ++ stdenv.lib.optional enableLdap "--with-ldap=${openldap.dev}";

    postPatch = ''
      sed -i -e 's/iksemel/minmay/g' configure src/libs/zbxmedia/jabber.c
      sed -i \
        -e '/^static ikstransport/,/}/d' \
        -e 's/iks_connect_with\(.*\), &zbx_iks_transport/mmay_connect_via\1/' \
        -e 's/iks/mmay/g' -e 's/IKS/MMAY/g' src/libs/zbxmedia/jabber.c
    '';

    buildInputs = [ pkgconfig curl openssl zlib inputDb libevent pcre.dev ]
      ++ stdenv.lib.optional enableSnmp net_snmp
      ++ stdenv.lib.optional enableSsh libssh2
      ++ stdenv.lib.optional enableLdap openldap;

    postInstall =
      ''
        mkdir -p $out/share/zabbix/db/postgresql
        cp -prvd database/postgresql $out/share/zabbix/db/postgresql
        mkdir -p $out/share/zabbix/db/mysql
        cp -prvd database/mysql $out/share/zabbix/db/mysql
      '';

    meta = {
      inherit branch;
      description = "An enterprise-class open source distributed monitoring solution";
      homepage = http://www.zabbix.com/;
      license = "GPL";
      maintainers = [ stdenv.lib.maintainers.eelco ];
      platforms = stdenv.lib.platforms.linux;
    };
  };

  agent = stdenv.mkDerivation {
    name = "zabbix-agent-${version}";

    inherit src preConfigure;

    configureFlags = [
      "--enable-agent"
      "--with-libpcre=${pcre.dev}"
    ];

    buildInputs = [ pcre.dev ];

    meta = with stdenv.lib; {
      inherit branch;
      description = "An enterprise-class open source distributed monitoring solution (client-side agent)";
      homepage = http://www.zabbix.com/;
      license = licenses.gpl2;
      maintainers = [ maintainers.eelco ];
      platforms = platforms.linux;
    };
  };

  proxy = stdenv.mkDerivation {
    name = "zabbix-proxy-${version}";

    inherit src preConfigure;

    configureFlags = [
      "--enable-proxy"
      "--with-sqlite3=${sqlite.dev}"
      "--with-libpcre=${pcre.dev}"
    ];

    buildInputs = [ pcre.dev sqlite.dev ];

    meta = with stdenv.lib; {
      inherit branch;
      description = "An enterprise-class open source distributed monitoring solution (proxy)";
      homepage = http://www.zabbix.com/;
      license = licenses.gpl2;
      maintainers = [ maintainers.eelco ];
      platforms = platforms.linux;
    };
  };

  frontend = stdenv.mkDerivation {
    name = "zabbix-frontend-${version}";

    inherit src;

    phases = "unpackPhase installPhase";

    installPhase = ''
      mkdir -p $out
      cp -prvd frontends/php $out
    '';

    meta = with stdenv.lib; {
      inherit branch;
      description = "An enterprise-class open source distributed monitoring solution (frontend)";
      homepage = http://www.zabbix.com/;
      license = licenses.gpl2;
      maintainers = [ maintainers.eelco ];
      platforms = platforms.linux;
    };
  };

}

