{ lib, stdenv, fetchurl }:

let
  pkg = "ipsvd";
  ver = "1.1.1";
  web = "http://smarden.org/ipsvd";
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "${web}/${pkg}-${ver}.tar.gz";
    sha256 = "sha256-kgTkrBQboQ4cf/rFhrT95EoLhk1GgA8bJjYCF346RHs=";
  };

  sourceRoot = "net/${pkg}-${ver}";

  NIX_CFLAGS_COMPILE = [
    "-Wno-error=implicit-function-declaration"
    "-Wno-error=incompatible-pointer-types"
  ];

  buildPhase = "./package/compile";

  installPhase = ''
    # binaries
    mkdir -p $out/bin
    for i in command/*; do cp $i $out/bin; done

    # man pages / doc
    mkdir -p $out/share/{doc,man}
    mkdir -p $out/share/man/man{5,7,8}
    for i in doc/*; do cp $i $out/share/doc; done
    for i in 5 7 8; do cp man/*.$i $out/share/man/man$i; done
  '';

  meta = {
    description = "internet protocol service daemons";
    homepage = web;
    license = lib.licenses.publicDomain.shortName;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ tzeman ];
  };
}

# vim: et ts=2 sw=2 
