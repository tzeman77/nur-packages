{ stdenv, fetchurl, openssl
, mysqlSupport ? false, mysql ? null
}:

assert mysqlSupport -> mysql != null;
 
stdenv.mkDerivation rec {
  name = "pure-ftpd-1.0.49";

  src = fetchurl {
    url = "https://download.pureftpd.org/pub/pure-ftpd/releases/${name}.tar.gz";
    sha256 = "19cjr262n6h560fi9nm7l1srwf93k34bp8dp1c6gh90bqxcg8yvn";
  };

  buildInputs = [ openssl ]
    ++ stdenv.lib.optional mysqlSupport mysql;

  configureFlags = ''
    --with-ftpwho --with-quotas
    --with-ratios --with-puredb --with-altlog --with-throttling
    --with-privsep --with-tls
    ${if mysqlSupport then "--with-mysql=${mysql}" else ""}
  '';
 
  meta = with stdenv.lib; {
    description = "A free, secure, production-quality and standard-conformant FTP server";
    homepage = https://www.pureftpd.org;
    license = licenses.isc; # with some parts covered by BSD3(?)
    maintainers = [ maintainers.lethalman ];
    platforms = platforms.linux;
  };
}

# vim: et ts=2 sw=2 
