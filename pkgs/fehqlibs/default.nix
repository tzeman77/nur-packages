{ fetchurl, lib, libtool, perl, stdenv, which }:

let
  pkg = "fehqlibs";
  homepage = "https://www.fehcom.de/ipnet/qlibs.html";
  version = "18";

in stdenv.mkDerivation rec {

  name = "${pkg}-${version}";

  src = fetchurl {
    url = "https://www.fehcom.de/ipnet/fehQlibs/fehQlibs-${version}.tgz";
    sha256 = "131fbik1rpnpnrz3b2biw5066zkclkhqydl6y24mkn47hb5llcnd";
  };

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
