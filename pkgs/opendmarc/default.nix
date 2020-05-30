{ stdenv, fetchurl, libbsd, libmilter, libspf2 }:

stdenv.mkDerivation rec {
  name = "opendmarc-${version}";
  version = "1.3.2";

  src = fetchurl {
    url = "mirror://sourceforge/opendmarc/files/${name}.tar.gz";
    sha256 = "1yrggj8yq0915y2i34gfz2xpl1w2lgb1vggp67rwspgzm40lng11";
  };

  configureFlags= [
    "--with-milter=${libmilter}"
    "--with-spf=${libspf2}"
  ];

  buildInputs = [ libbsd libmilter libspf2 ];

  meta = with stdenv.lib; {
    description = "Free open source software implementation of the DMARC specification";
    homepage = http://www.trusteddomain.org/opendmarc/;
    platforms = platforms.unix;
  };
}
