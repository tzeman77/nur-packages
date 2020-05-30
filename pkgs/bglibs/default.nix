{ fetchurl, lib, libtool, perl, stdenv, which }:

let
  homepage = http://untroubled.org/bglibs;

in stdenv.mkDerivation rec {

  pname = "bglibs";
  version = "2.04";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "${homepage}/archive/${name}.tar.gz";
    sha256 = "0x14qpapvj99wkahh1vzd9rps3j66b23l2qhbw6gywizqjj39bp4";
  };

  buildInputs = [libtool which perl];

  patches = [ ./bglibs2.patch ];

  configurePhase = ''
    echo $out/include > conf-include
    echo $out/lib > conf-lib
    echo $out/bin > conf-bin
    echo $out/man > conf-man
  '';

  meta = {
    description = "One stop library package";
    homepage = homepage;
    license = stdenv.lib.licenses.lgpl21Plus.fullName;
    platforms = stdenv.lib.platforms.gnu;
    maintainers = with stdenv.lib.maintainers; [ tzeman ];
  };

}

# vim: et ts=2 sw=2 
