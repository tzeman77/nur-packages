{ fetchurl, lib, libtool, perl, stdenv, which }:

let
  pkg = "fehqlibs";
  homepage = "https://www.fehcom.de/ipnet/qlibs.html";
  version = "26b";

in stdenv.mkDerivation rec {

  name = "${pkg}-${version}";

  src = fetchurl {
    url = "https://www.fehcom.de/ipnet/fehQlibs/fehQlibs-${version}.tgz";
    sha256 = "wM4cfyFP2K0t4qb6WYDBFsGUvF1F69eHgfjaT3H4/nU=";
  };

  sourceRoot = "fehQlibs-26/src";

  configurePhase = ''
    echo "LIBDIR=$out/lib" >> ../conf-build
    echo "HDRDIR=$out/include" >> ../conf-build
  '';

  buildPhase = ''
    make CFLAGS="-I../include" default shared
  '';

  postInstall = ''
    mkdir -p $out/man/man3
    cp ../man/* $out/man/man3/
    cp *.so $out/lib
  '';

  meta = {
    description = "State-of-the-art C routines provided as easy-to-use library for Internet services.";
    homepage = homepage;
    license = lib.licenses.publicDomain.fullName;
    platforms = lib.platforms.gnu;
    maintainers = with lib.maintainers; [ tzeman ];
  };

}

# vim: et ts=2 sw=2 
