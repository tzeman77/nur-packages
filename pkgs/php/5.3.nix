{ lib, stdenv, fetchurl, autoconf, automake, flex, bison
, apacheHttpd, mysql, libxml2, readline, zlib, curl, gd, postgresql, gettext
, openssl, pkgconfig, sqlite, config, libjpeg, libpng, freetype, libxslt
, libmcrypt, bzip2, icu, openldap, libssh2, makeWrapper, uwimap
, gdbm, gmp
, pam }:

with lib;

let
  generic =
  { version
  , sha256
  , apxs2Support ? config.php.apxs2 or false
  , bcmathSupport ? config.php.bcmath or true
  , bz2Support ? config.php.bz2 or true
  , calendarSuppport ? config.php.calendar or true
  , curlSupport ? config.php.curl or false
  , exifSupport ? config.php.exif or true
  , ftpSupport ? config.php.ftp or true
  , fpmSupport ? config.php.fpm or true
  , gdSupport ? config.php.gd or true
  , gdbmSupport ? config.php.gdbm or false
  , gettextSupport ? config.php.gettext or true
  , gmpSupport ? config.php.gmp or false
  , imapSupport ? config.php.imap or false
  , intlSupport ? config.php.intl or true
  , ldapSupport ? config.php.ldap or false
  , libxml2Support ? config.php.libxml2 or true
  , mbstringSupport ? config.php.mbstring or true
  , mcryptSupport ? config.php.mcrypt or true
  , mhashSupport ? config.php.mhash or false
  , mysqlndSupport ? config.php.mysqlnd or false
  , mysqlSupport ? config.php.mysql or true
  , mysqliSupport ? config.php.mysqli or false
  , opensslSupport ? config.php.openssl or true
  , pcntlSupport ? config.php.pcntl or true
  , pdo_mysqlSupport ? config.php.pdo_mysql or true
  , pdo_pgsqlSupport ? config.php.pdo_pgsql or true
  , posixSupport ? config.php.posix or true
  , postgresqlSupport ? config.php.postgresql or true
  , readlineSupport ? config.php.readline or true
  , shmopSupport ? config.php.shmop or true
  , sysvmsgSupport ? config.php.sysvmsg or true
  , sysvsemSupport ? config.php.sysvsem or true
  , sysvshmSupport ? config.php.sysvshm or true
  , soapSupport ? config.php.soap or true
  , socketsSupport ? config.php.sockets or true
  , sqliteSupport ? config.php.sqlite or true
  , xmlrpcSupport ? config.php.xmlrpc or true
  , xslSupport ? config.php.xsl or true
  , zipSupport ? config.php.zip or true
  , zlibSupport ? config.php.zlib or true
  , patches ? []

  }:

    let

      libmcrypt' = libmcrypt.override { disablePosixThreads = true; };

in stdenv.mkDerivation {

  inherit version;
  inherit patches;

  name = "php-${version}";

  enableParallelBuilding = true;

  buildInputs
    = [ flex bison pkgconfig ]
    ++ optional apxs2Support apacheHttpd
    ++ optionals curlSupport [curl openssl]
    ++ optionals ldapSupport [ openldap openssl ]
    ++ optional zlibSupport zlib
    ++ optional libxml2Support libxml2
    ++ optional readlineSupport readline
    ++ optional sqliteSupport sqlite
    ++ optional postgresqlSupport postgresql
    ++ optional pdo_pgsqlSupport postgresql
    ++ optional mysqlSupport mysql
    ++ optional mysqliSupport mysql
    ++ optional pdo_mysqlSupport mysql
    ++ optionals gdSupport [libpng libjpeg freetype]
    ++ optionals opensslSupport [openssl openssl.dev]
    ++ optional gettextSupport gettext
    ++ optionals imapSupport [uwimap openssl]
    ++ optional intlSupport icu
    ++ optional xslSupport libxslt
    ++ optional mcryptSupport libmcrypt'
    ++ optional bz2Support bzip2;

  # need to include the C++ standard library when compiling on darwin
  NIX_LDFLAGS = "-lstdc++";

  # need to specify where the dylib for icu is stored
  DYLD_LIBRARY_PATH = stdenv.lib.optionalString stdenv.isDarwin "${icu}/lib";

  configureFlags = [
    "--with-config-file-scan-dir=/etc"
  ]
  ++ optional apxs2Support "--with-apxs2=${apacheHttpd}/bin/apxs"
  ++ optional calendarSuppport "--enable-calendar" #=shared"
  ++ optionals curlSupport ["--with-curl=shared,${curl.dev}" "--with-curlwrappers"]
  ++ optional pcntlSupport "--enable-pcntl"
  ++ optional zlibSupport "--with-zlib=${zlib.dev}"
  ++ optional libxml2Support "--with-libxml-dir=${libxml2.dev}"
  ++ optional readlineSupport "--with-readline=${readline.dev}"
  ++ optionals sqliteSupport [
    #"--with-sqlite=shared,${sqlite.dev}"
    "--with-pdo-sqlite=shared,${sqlite.dev}"
  ]
  ++ optional posixSupport "--enable-posix" #=shared"
  ++ optional postgresqlSupport "--with-pgsql=shared,${postgresql}"
  ++ optional pdo_pgsqlSupport "--with-pgsql=shared,${postgresql}"
  ++ optional mysqlSupport "--with-mysql=${mysql.connector-c}"
  ++ optionals mysqliSupport [
    "--with-mysqli=${if mysqlndSupport then "mysqlnd" else "${mysql.connector-c}/bin/mysql_config"}"
  ]
  ++ optional pdo_mysqlSupport "--with-pdo-mysql=${if mysqlndSupport then "mysqlnd" else mysql.connector-c}"
  ++ optional bcmathSupport "--enable-bcmath"
  ++ optionals gdSupport [
    "--with-gd"
    "--with-freetype-dir=${freetype.dev}"
    "--with-png-dir=${libpng.dev}"
    "--with-jpeg-dir=${libjpeg.dev}"
  ]
  ++ optional soapSupport "--enable-soap" #=shared"
  ++ optional socketsSupport "--enable-sockets"
  ++ optional opensslSupport "--with-openssl"
  ++ optional mbstringSupport "--enable-mbstring"
  ++ optional gettextSupport "--with-gettext=${gettext}"
  ++ optionals imapSupport [
    "--with-imap=shared,${uwimap}"
    "--with-imap-ssl=shared"
  ]
  ++ optionals ldapSupport [
    "--with-ldap=/invalid/path"
    "LDAP_DIR=${openldap.dev}"
    "LDAP_INCDIR=${openldap.dev}/include"
    "LDAP_LIBDIR=${openldap.out}/lib"
  ]
  ++ optional intlSupport "--enable-intl"
  ++ optional exifSupport "--enable-exif"
  ++ optional xslSupport "--with-xsl=${libxslt.dev}"
  ++ optional mcryptSupport "--with-mcrypt=${libmcrypt'}"
  ++ optional bz2Support "--with-bz2=${bzip2.dev}"
  ++ optional zipSupport "--enable-zip"
  ++ optional ftpSupport "--enable-ftp" #=shared"
  ++ optional gdbmSupport "--with-gdbm=shared,${gdbm}"
  ++ optional gmpSupport "--with-gmp=shared,${gmp.dev}"
  ++ optional mhashSupport "--with-mhash" #=shared"
  ++ optional shmopSupport "--enable-shmop" #==shared"
  ++ optional sysvmsgSupport "--enable-sysvmsg"
  ++ optional sysvsemSupport "--enable-sysvsem" #=shared"
  ++ optional sysvshmSupport "--enable-sysvshm" #=shared"
  ++ optional xmlrpcSupport "--with-xmlrpc=shared"
  ++ optional fpmSupport "--enable-fpm";

#  flags = {
#
#    # much left to do here...
#
#    # SAPI modules:
#
#      apxs2 = {
#        configureFlags = ["--with-apxs2=${apacheHttpd}/bin/apxs"];
#        buildInputs = [apacheHttpd];
#      };
#
#      # Extensions
#
#      calendar = {
#        configureFlags = ["--enable-calendar=shared"];
#      };
#
#      curl = {
#        configureFlags = ["--with-curl=shared,${curl.dev}" "--with-curlwrappers"];
#        buildInputs = [curl openssl];
#      };
#
#      pcntl = {
#        configureFlags = [ "--enable-pcntl" ];
#      };
#
#      zlib = {
#        configureFlags = ["--with-zlib=${zlib.dev}"];
#        buildInputs = [zlib];
#      };
#
#      libxml2 = {
#        configureFlags
#          = [ "--with-libxml-dir=${libxml2.dev}" ];
#        buildInputs = [ libxml2 ];
#      };
#
#      readline = {
#        configureFlags = ["--with-readline=${readline.dev}"];
#        buildInputs = [ readline ];
#      };
#
#      sqlite = {
#        configureFlags = [
##         "--with-sqlite=shared,${sqlite}"
#          "--with-pdo-sqlite=shared,${sqlite.dev}"
#        ];
#        buildInputs = [ sqlite ];
#      };
#
#      posix = {
#        configureFlags = ["--enable-posix=shared"];
#      };
#
#      postgresql = {
#        configureFlags = ["--with-pgsql=shared,${postgresql}"];
#        buildInputs = [ postgresql ];
#      };
#
#      pdo_pgsql = {
#        configureFlags = ["--with-pdo-pgsql=shared,${postgresql}"];
#        buildInputs = [ postgresql ];
#      };
#
#      mysql = {
#        configureFlags = [
#          "--with-mysql=shared,${mysql55}"
#          #"--with-mysql-sock=/tmp/mysql.sock"
#        ];
#        buildInputs = [ mysql55 ];
#      };
#
#      mysqli = {
#        configureFlags = ["--with-mysqli=${mysql55}/bin/mysql_config"];
#        buildInputs = [ mysql55 ];
#      };
#
#      mysqli_embedded = {
#        configureFlags = ["--enable-embedded-mysqli"];
#        depends = "mysqli";
#        #assertion = fixed.mysqliSupport;
#      };
#
#      pdo_mysql = {
#        configureFlags = ["--with-pdo-mysql=shared,${mysql55}"];
#        buildInputs = [ mysql55 ];
#      };
#
#      bcmath = {
#        configureFlags = ["--enable-bcmath=shared"];
#      };
#
#      gd = {
#        configureFlags = [
#          "--with-gd" #=shared,${gd.dev}"
#          "--with-freetype-dir=${freetype.dev}"
#          "--with-png-dir=${libpng.dev}"
#          "--with-jpeg-dir=${libjpeg.dev}"
#        ];
#        buildInputs = [libpng libjpeg freetype];
#      };
#
#      soap = {
#        configureFlags = ["--enable-soap=shared"];
#      };
#
#      sockets = {
#        configureFlags = ["--enable-sockets"];
#      };
#
#      openssl = {
#        configureFlags = ["--with-openssl"];
#        buildInputs = [openssl openssl.dev];
#      };
#
#      mbstring = {
#        configureFlags = ["--enable-mbstring"];
#      };
#
#      gettext = {
#        configureFlags = ["--with-gettext=${gettext}"];
#        buildInputs = [gettext];
#      };
#
#      imap = {
#        configureFlags = [ "--with-imap=shared,${uwimap}" "--with-imap-ssl=shared" ]
#          # uwimap builds with kerberos on darwin
#          ++ stdenv.lib.optional (stdenv.isDarwin) "--with-kerberos";
#        buildInputs = [ uwimap openssl ]
#          ++ stdenv.lib.optional (!stdenv.isDarwin) pam;
#      };
#
#      intl = {
#        configureFlags = ["--enable-intl"];
#        buildInputs = [icu];
#      };
#
#      exif = {
#        configureFlags = ["--enable-exif"];
#      };
#
#      xsl = {
#        configureFlags = ["--with-xsl=shared,${libxslt.dev}"];
#        buildInputs = [libxslt];
#      };
#
#      mcrypt = {
#        configureFlags = ["--with-mcrypt=shared,${libmcrypt}"];
#        buildInputs = [libmcryptOverride];
#      };
#
#      bz2 = {
#        configureFlags = ["--with-bz2=shared,${bzip2.dev}"];
#        buildInputs = [bzip2];
#      };
#
#      zip = {
#        configureFlags = ["--enable-zip"];
#      };
#
#      ftp = {
#        configureFlags = ["--enable-ftp=shared"];
#      };
#
#      gdbm = {
#        configureFlags = ["--with-gdbm=shared,${gdbm}"];
#      };
#
#      gmp = {
#        configureFlags = ["--with-gmp=shared,${gmp.dev}"];
#      };
#
#      mhash = {
#        configureFlags = ["--with-mhash=shared"];
#      };
#
##     pspell = {
##       configureFlags = ["--with-pspell=shared"];
##     };
#
#      shmop = {
#        configureFlags = ["--enable-shmop=shared"];
#      };
#
#      sysvmsg = {
#        configureFlags = ["--enable-sysvmsg"];
#      };
#
#      sysvsem = {
#        configureFlags = ["--enable-sysvsem=shared"];
#      };
#
#      sysvshm = {
#        configureFlags = ["--enable-sysvsem=shared"];
#      };
#
##     tidy = {
##       configureFlags = ["--with-tidy=shared"];
##     };
#
#      mlrpc = {
#        configureFlags = ["--with-xmlrpc=shared"];
#      };
#
#      fpm = {
#        configureFlags = ["--enable-fpm"];
#      };
#    };

  configurePhase = ''
    iniFile=$out/etc/php.ini
    [[ -z "$libxml2" ]] || export PATH=$PATH:$libxml2/bin
    ./configure --with-config-file-path=$out/etc \
        --prefix=$out $configureFlags \
        --enable-shared --enable-magic-quotes --enable-safe-mode
    echo configurePhase end
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    # don't build php.dSYM as the php binary
    sed -i 's/EXEEXT = \.dSYM/EXEEXT =/' Makefile
  '';

  installPhase = ''
    unset installPhase; installPhase;
    cp php.ini-production $iniFile
  '' + ( stdenv.lib.optionalString stdenv.isDarwin ''
    for prog in $out/bin/*; do
      wrapProgram "$prog" --prefix DYLD_LIBRARY_PATH : "$DYLD_LIBRARY_PATH"
    done
  '' );

  src = fetchurl {
    url = "http://cz1.php.net/get/php-${version}.tar.bz2/from/this/mirror";
    inherit sha256;
    name = "php-${version}.tar.bz2";
  };

  meta = {
    description = "An HTML-embedded scripting language";
    homepage    = http://www.php.net/;
    license     = "PHP-3";
    maintainers = with stdenv.lib.maintainers; [ lovek323 ];
    platforms   = stdenv.lib.platforms.unix;
  };


};

in {
  php53 = generic {
    version = "5.3.29";
    sha256 = "1480pfp4391byqzmvdmbxkdkqwdzhdylj63sfzrcgadjf9lwzqf4";
    patches = [ ./fix.patch ./5.3-freetype-dirs.patch ];
  };
  php54 = generic {
    version = "5.4.45";
    sha256 = "10k59j7zjx2mrldmgfvjrrcg2cslr2m68azslspcz5acanqjh3af";
    patches = [ ./fix54.patch ];
    bcmathSupport = true;
    bz2Support = true;
    calendarSuppport = true;
    ftpSupport = true;
    ldapSupport = true;
    mcryptSupport = true;
    mhashSupport = true;
    mysqlndSupport = true;
    mysqlSupport = true;
    mysqliSupport = true;
    pdo_mysqlSupport = true;
    pdo_pgsqlSupport = false;
    posixSupport = true;
    postgresqlSupport = false;
    shmopSupport = true;
    soapSupport = true;
    sysvsemSupport = true;
    sysvshmSupport = true;
    xslSupport = true;
  };
}
