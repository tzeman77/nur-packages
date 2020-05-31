{ stdenv, fetchurl, unzip }:

let

  version = "2018-12-11";


in stdenv.mkDerivation {

  name = "zabbix-scripts-${version}";

  src = fetchMercurial {
    url = "https://hg.functionals.cz/zabbix-scripts";
    rev = "1eada2e65e7a";
  };

  buildInputs = [ unzip ];

  phases = "unpackPhase installPhase";

  installPhase = ''
    mkdir -p $out
    cp -prvd . $out
    patchShebangs $out
  '';
}

