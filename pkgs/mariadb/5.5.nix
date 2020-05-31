{ stdenv, fetchpatch, fetchurl, cmake, bison, ncurses, openssl
, readline, zlib }:

# Note: zlib is not required; MariaDB can use an internal zlib.

let
self = stdenv.mkDerivation rec {
  name = "mariadb-${version}";
  version = "5.5.62";

  src = fetchurl {
    urls = [
      "https://downloads.mariadb.org/f/mariadb-${version}/source/mariadb-${version}.tar.gz"
      "https://downloads.mariadb.com/MariaDB/mariadb-${version}/source/mariadb-${version}.tar.gz"
    ];
    sha256 = "1nqichli3gi9ldn9h1vmxsl1s0cmxhnix070zs5yradqf6pnb8sn";

  };

  patches = [
    ./sysctl.h.patch
    # Minor type error that is a build failure as of clang 6.
    (stdenv.lib.optional stdenv.cc.isClang (fetchpatch {
      url = "https://svn.freebsd.org/ports/head/databases/mysql55-server/files/patch-sql_sql_partition.cc?rev=469888";
      extraPrefix = "";
      sha256 = "09sya27z3ir3xy5mrv3x68hm274594y381n0i6r5s627x71jyszf";
    }))
  ];

  preConfigure = stdenv.lib.optional stdenv.isDarwin ''
    ln -s /bin/ps $TMPDIR/ps
    export PATH=$PATH:$TMPDIR
  '';

  buildInputs = [ cmake bison ncurses openssl readline zlib ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DWITH_SSL=yes"
    "-DWITH_READLINE=yes"
    "-DWITH_EMBEDDED_SERVER=yes"
    "-DWITH_ZLIB=yes"
    "-DHAVE_IPV6=yes"
    "-DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock"
    "-DMYSQL_DATADIR=/var/lib/mysql"
    "-DINSTALL_SYSCONFDIR=etc/mysql"
    "-DINSTALL_INFODIR=share/mysql/docs"
    "-DINSTALL_MANDIR=share/man"
    "-DINSTALL_PLUGINDIR=lib/mysql/plugin"
    "-DINSTALL_SCRIPTDIR=bin"
    "-DINSTALL_INCLUDEDIR=include/mysql"
    "-DINSTALL_DOCREADMEDIR=share/mysql"
    "-DINSTALL_SUPPORTFILESDIR=share/mysql"
    "-DINSTALL_MYSQLSHAREDIR=share/mysql"
    "-DINSTALL_DOCDIR=share/mysql/docs"
    "-DINSTALL_SHAREDIR=share/mysql"
    "-DINSTALL_MYSQLTESTDIR="
    "-DINSTALL_SQLBENCHDIR="
  ];

  NIX_CFLAGS_COMPILE =
    stdenv.lib.optionals stdenv.cc.isGNU [ "-fpermissive" "-Wno-error=shadow" ] # since gcc-7
    ++ stdenv.lib.optionals stdenv.cc.isClang [ "-Wno-c++11-narrowing" ]; # since clang 6

  NIX_LDFLAGS = stdenv.lib.optionalString stdenv.isLinux "-lgcc_s";

  prePatch = ''
    sed -i -e "s|/usr/bin/libtool|libtool|" cmake/libutils.cmake
  '';
  postInstall = ''
    sed -i -e "s|basedir=\"\"|basedir=\"$out\"|" $out/bin/mysql_install_db
    rm -r $out/data "$out"/lib/*.a
  '';

  passthru = {
    client = self;
    connector-c = self;
    server = self;
    mysqlVersion = "5.5";
  };

  meta = with stdenv.lib; {
    homepage = https://www.mysql.com/;
    description = "The world's most popular open source database";
    platforms = platforms.unix;
    # See https://downloads.mysql.com/docs/licenses/mysqld-5.5-gpl-en.pdf
    license = with licenses; [
      artistic1 bsd0 bsd2 bsd3 bsdOriginal
      gpl2 lgpl2 lgpl21 mit publicDomain  licenses.zlib
    ];
    broken = stdenv.isAarch64;
  };
}; in self
