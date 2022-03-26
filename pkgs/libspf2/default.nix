{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "libspf2-${version}";
  version = "1.2.10";

  src = fetchurl {
    url = "https://www.libspf2.org/spf/${name}.tar.gz";
    sha256 = "1j91p0qiipzf89qxq4m1wqhdf01hpn1h5xj4djbs51z23bl3s7nr";
  };

  patches = [ ./fix-variadic-macros.patch ./compile.patch ];

  meta = with lib; {
    description = "Sender Policy Framework record checking library";
    homepage = http://www.libspf2.org/;
    license = licenses.bsd2;
    platforms = platforms.unix;
  };
}
