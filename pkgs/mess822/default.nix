{ lib, stdenv, fetchurl, groff }:

let
  pkg = "mess822";
  ver = "0.58";
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "http://cr.yp.to/software/${pkg}-${ver}.tar.gz";
    sha256 = "1q0kqjhnvd1crkc0xnyml1qfa9zaxafk18d0ppcmrbbl6iw7mlr3";
  };

  buildInputs = [groff];

  patches = [
    ./errno.patch
    ./hier.patch
  ];

  configurePhase = ''
    echo $out > conf-home
    substituteInPlace hier.c --replace /etc $out/etc
    substituteInPlace leapsecs_read.c --replace /etc/leapsecs $out/etc/leapsecs
  '';

  preInstall = ''
    mkdir -p $out/etc
  '';

  installTargets = "setup";

  postInstall = ''
    rm -fr $out/man/cat*
  '';

  meta = {
    description = "Library for parsing internet mail messages";
    homepage = http://cr.yp.to/mess822.html;
    license = lib.licenses.publicDomain.shortName;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ tzeman ];
  };
}

# vim: et ts=2 sw=2 
