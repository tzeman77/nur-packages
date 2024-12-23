{ lib, stdenv, fetchFromGitHub, autoreconfHook, libmilter, perl, perlPackages, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "opendmarc";
  version = "1.4.1.1";

  src = fetchFromGitHub {
    owner = "trusteddomainproject";
    repo = "opendmarc";
    rev = "rel-opendmarc-${builtins.replaceStrings [ "." ] [ "-" ] version}";
    sha256 = "sha256:12id8zcnspv09ypx2m8i993a507d3gdz4mfrhj04k9hnmbbp74vf";
  };

  outputs = [ "bin" "dev" "out" "doc" ];

  buildInputs = [ perl ];
  nativeBuildInputs = [ autoreconfHook makeWrapper ];

  postPatch = ''
    substituteInPlace configure.ac --replace '	docs/Makefile' ""
    patchShebangs contrib reports
  '';

  configureFlags = [
    "--with-milter=${libmilter}"
  ];

  postFixup = ''
    for b in $bin/bin/opendmarc-{expire,import,params,reports}; do
      wrapProgram $b --set PERL5LIB ${perlPackages.makeFullPerlPath (with perlPackages; [ Switch DBI DBDmysql HTTPMessage ])}
    done
  '';

  meta = with lib; {
    description = "A free open source software implementation of the DMARC specification";
    homepage = "http://www.trusteddomain.org/opendmarc/";
    license = with licenses; [ bsd3 sendmail ];
    maintainers = with maintainers; [ ajs124 das_j ];
  };
}
