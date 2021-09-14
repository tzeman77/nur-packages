{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "zabbix-scripts";
  version = "2021-04-15";

  src = fetchMercurial {
    url = "https://hg.functionals.cz/zabbix-scripts";
    rev = "a0015fe2009a";
  };

  buildInputs = [ unzip ];

  phases = "unpackPhase installPhase";

  installPhase = ''
    mkdir -p $out
    cp -prvd . $out
    patchShebangs $out
  '';
}

