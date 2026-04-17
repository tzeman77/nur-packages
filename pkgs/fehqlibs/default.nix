{ fetchurl, lib, libtool, perl, stdenv, which }:

let
  pkg = "fehqlibs";
  homepage = "https://www.fehcom.de/ipnet/qlibs.html";
  version = "31";

in stdenv.mkDerivation rec {

  name = "${pkg}-${version}";

  src = fetchurl {
    url = "https://www.fehcom.de/ipnet/fehQlibs/fehQlibs-${version}.tgz";
    sha256 = "sha256-5g2j6mHUxbCHebgJmrcew1W5JaRNjrwEUuAuL2DMVwE=";
  };

  sourceRoot = "fehQlibs-${version}/src";

  NIX_CFLAGS_COMPILE = [
    "-Wno-error=incompatible-pointer-types"
    "-I../include" 
  ];

  configurePhase = ''
    echo "LIBDIR=$out/lib" >> ../conf-build
    echo "HDRDIR=$out/include" >> ../conf-build
  '';

  buildPhase = ''
    make default shared
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
