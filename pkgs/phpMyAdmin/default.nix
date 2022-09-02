{ lib, stdenv, fetchurl, unzip, writeText }:

stdenv.mkDerivation rec {
  pname = "phpMyAdmin";
  version = "5.2.0";

  src = fetchurl {
    url = "https://files.phpmyadmin.net/phpMyAdmin/${version}/phpMyAdmin-${version}-all-languages.zip";
    sha256 = "sha256-4dNz5yDtQCCH7VaRt6GTXuo5rzDqxmpY5qeR5kgWewY=";
  };

  buildInputs = [ unzip ];

  phases = "unpackPhase installPhase";

  installPhase = ''
    mkdir -p $out
    cp -prd . $out
    rm -rf $out/setup
    cat <<EOF > $out/config.inc.php
<?php
  return require(getenv('PMA_CONFIG'));
?>
EOF
  '';

  meta = with lib; {
    description = "Web based MySQL administration tool";
    homepage = "https://www.phpmyadmin.net";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };

}


