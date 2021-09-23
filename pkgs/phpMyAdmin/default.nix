{ stdenv, fetchurl, unzip, writeText }:

stdenv.mkDerivation rec {
  pname = "phpMyAdmin";
  version = "5.1.1";

  src = fetchurl {
    url = "https://files.phpmyadmin.net/phpMyAdmin/${version}/phpMyAdmin-${version}-all-languages.zip";
    sha256 = "sha256:0k2ms0ckg6hakl598sjdgay1m767bl10a1sk38igrzgr44vdk9bq";
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

  meta = with stdenv.lib; {
    description = "Web based MySQL administration tool";
    homepage = "https://www.phpmyadmin.net";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };

}


