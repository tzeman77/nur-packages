{ fetchurl, lib, libtool, perl, stdenv, which }:

let
  pkg = "fehqlibs";
  homepage = "https://www.fehcom.de/ipnet/qlibs.html";
  version = "16";

in stdenv.mkDerivation rec {

  name = "${pkg}-${version}";

  src = fetchurl {
    url = "https://www.fehcom.de/ipnet/fehQlibs/fehQlibs-${version}.tgz";
    sha256 = "18dz0niz7flxgjyw4y14dzy1lz9xqh3id85drqwy2sgz5znqb80p";
  };

  #buildInputs = [libtool which perl];

  #patches = [ ./bglibs2.patch ];

  configurePhase = ''
    echo "LIBDIR=$out/lib" >> conf-build
    echo "HDRDIR=$out/include" >> conf-build
  '';

  postInstall = ''
    mkdir -p $out/man/man3
    cp man/* $out/man/man3/
  '';

  meta = {
    description = "State-of-the-art C routines provided as easy-to-use library for Internet services.";
    homepage = homepage;
    license = stdenv.lib.licenses.publicDomain.fullName;
    platforms = stdenv.lib.platforms.gnu;
    maintainers = with stdenv.lib.maintainers; [ tzeman ];
  };

}

# vim: et ts=2 sw=2 
