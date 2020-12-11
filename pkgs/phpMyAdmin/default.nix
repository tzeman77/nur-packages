{ stdenv, fetchurl, unzip, writeText }:

stdenv.mkDerivation rec {
  pname = "phpMyAdmin";
  version = "5.0.4";

  src = fetchurl {
    url = "https://files.phpmyadmin.net/phpMyAdmin/${version}/phpMyAdmin-${version}-all-languages.zip";
    sha256 = "1pkpyspk6pp7xnh8y9j4a0va0367w8w1i4s98ap1gr6m62lvq2w3";
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


