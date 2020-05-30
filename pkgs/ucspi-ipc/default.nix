{ stdenv, fetchurl }:

let
  pkg = "ucspi-ipc";
  ver = "0.67";
  web = http://www.superscript.com/ucspi-ipc;
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "${web}/${pkg}-${ver}.tar.gz";
    sha256 = "12wy9l5aak3n5yxnyyasdh3gcn8nkca9gflbbjvpfwza9c6rf34m";
  };
  sourceRoot = "host/superscript.com/net/${pkg}-${ver}";

  patches = [
    # Avoid need to have secondary groups for compilation
    ./hasshsgr.h.patch
  ];

  configurePhase = ''
    for i in ipccat ipcconnect ipcdo ipcrun; do
      substituteInPlace src/$i.sh --replace HOME/command/ $out/bin/
    done
  '';

  buildPhase = "./package/compile base";

  installPhase = ''
    # binaries
    mkdir -p $out/bin
    cp command/* $out/bin/
  '';

  dontStrip = true; # diet does not need stripping
  dontPatchELF = true; # we produce static binaries

  meta = {
    description = "Command-line tools for building local-domain client-server applications";
    homepage = web;
    license = stdenv.lib.licenses.publicDomain.shortName;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ tzeman ];
  };
}

# vim: et ts=2 sw=2 
