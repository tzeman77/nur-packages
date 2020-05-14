{ stdenv }:

stdenv.mkDerivation rec {
  pname = "guilt";
  version = "0.36";

  src = fetchTarball {
    url = "http://guilt.31bits.net/src/guilt-0.36.tar.gz";
    sha256 = "0q4pnyxkw1nrw9ap4z41vqg68ifsqp5llbdmpsiyrbl76nqx1857";
  };

  installPhase = ''
    make install PREFIX=$out
  '';

}
