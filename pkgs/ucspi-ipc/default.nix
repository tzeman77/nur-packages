{ lib, stdenv, fetchFromGitHub }:

let
  pkg = "ucspi-ipc";
  ver = "0.70";
  web = https://github.com/SuperScript/ucspi-ipc;
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchFromGitHub {
    owner = "SuperScript";
    repo = pkg;
    rev = "2efb8562506e16f39e3bd18d89ec9d92a991009f";
    sha256 = "sha256:15b097vyjciinpkkkagpcfg0jy9hk30iljplhi625fs96z3znyhd";
  };
  sourceRoot = "source/src";

  patches = [
    # Avoid need to have secondary groups for compilation
    ./hasshsgr.h.patch
  ];

  configurePhase = ''
    for i in ipccat ipcconnect ipcdo ipcrun; do
      substituteInPlace $i.sh --replace '#HOME#/command/' $out/bin/
    done
  '';

  buildPhase = "make it";

  installPhase = ''
    # binaries
    mkdir -p $out/bin
    for i in $(cat it\=d); do
      [ -f $i ] && cp $i $out/bin/
    done
  '';

  dontStrip = true; # diet does not need stripping
  dontPatchELF = true; # we produce static binaries

  meta = {
    description = "Command-line tools for building local-domain client-server applications";
    homepage = web;
    license = lib.licenses.publicDomain.shortName;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ tzeman ];
  };
}

# vim: et ts=2 sw=2 
