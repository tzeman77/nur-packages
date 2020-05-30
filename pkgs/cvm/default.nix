{ stdenv, fetchurl, libtool, bglibs }:

let
  pkg = "cvm";
  ver = "0.97";
  homepage = http://untroubled.org/cvm;
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "${homepage}/archive/${name}.tar.gz";
    sha256 = "0iqc1akzzidazps9a1jg5l41vssvi0k572z2awafjancccfpbrw2";
  };

  buildInputs = [libtool bglibs];

  inherit bglibs;

  patches = [
    # fix missing main() - can't find in .a lib.
    ./link-main.patch
  ];

  configurePhase = ''
    echo $out/bin > conf-bin
    echo "gcc -W -Wall -Wshadow -O -g -I$bglibs/include" > conf-cc
    echo $out/include > conf-include
    echo "gcc -g -L$bglibs/lib" > conf-ld
    echo $out/lib > conf-lib
    #echo $bglibs/lib/libvmailmgr.la > vmailmgr.lib
  '';

  meta = {
    description = "Credential Validation Modules";
    homepage = homepage;
    license = stdenv.lib.licenses.gpl2Plus.fullName;
    platforms = stdenv.lib.platforms.gnu;
    maintainers = with stdenv.lib.maintainers; [ tzeman ];
  };

}

# vim: et ts=2 sw=2 

