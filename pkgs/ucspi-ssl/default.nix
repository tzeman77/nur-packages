{ lib, stdenv, fetchurl, openssl, ucspi-tcp, fehqlibs }:

let
  pkg = "ucspi-ssl";
  ver = "0.13.03";
  web = "https://www.fehcom.de/ipnet/ucspi-ssl";
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "${web}/${pkg}-${ver}.tgz";
    sha256 = "SxNnZ2NLLWXeGQzCGha6p1N/efqZlqD1+ocOIzbvfm4=";
  };
  sourceRoot = "host/superscript.com/net/${pkg}-${ver}";

  buildInputs = [openssl fehqlibs];

  configurePhase = ''
    echo /etc/ssl/certs > conf-cadir
    echo /etc/ssl/pem/dh1024.pem > conf-dhfile
    echo ${ucspi-tcp}/bin > conf-tcpbin
    echo $out > conf-home
  '';

  buildPhase = "./package/compile base";

  installPhase = ''
    # binaries
    mkdir -p $out/bin
    cp command/* $out/bin/

    # man
    mdir=$out/share/man
    mkdir -p $mdir/man{1,2}
    for i in 1 2; do cp man/*.$i $mdir/man$i/; done

    # doc
    mkdir -p $out/share/doc
    cp doc/* $out/share/doc/
  '';

  meta = {
    description = "TLS encryption for Client/Server IPv6/IPv4 communication";
    homepage = "${web}.html";
    license = lib.licenses.publicDomain.shortName;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ tzeman ];
  };
}

# vim: et ts=2 sw=2 
