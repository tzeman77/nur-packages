{ stdenv }:

stdenv.mkDerivation rec {
  pname = "hgeditor";
  version = "5.4";

  src = builtins.fetchurl {
    url = "https://www.mercurial-scm.org/repo/hg/raw-file/${version}/hgeditor";
    sha256 = "085srm14v0bvi6sa7gbjl7gihgb2mzv3h5ygfzixmpr3z9sxffxk";
  };

  phases = "installPhase fixupPhase";

  installPhase = ''
    install -D $src $out/bin/hgeditor
  '';

}
