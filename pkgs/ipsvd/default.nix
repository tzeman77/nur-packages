{ stdenv, fetchurl }:

let
  pkg = "ipsvd";
  ver = "1.0.0";
  web = "http://smarden.org/ipsvd";
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "${web}/${pkg}-${ver}.tar.gz";
    sha256 = "1b8zs0vvvim6bn5wizx4lm6kw2s7pf2q6rapmc4mvjssr1dp4ypg";
  };

  sourceRoot = "net/${pkg}-${ver}";

  patches = [
    # Avoid need to have secondary groups for compilation
    ./hasshsgr.h.patch
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
    license = stdenv.lib.licenses.publicDomain.shortName;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ tzeman ];
  };
}

# vim: et ts=2 sw=2 
