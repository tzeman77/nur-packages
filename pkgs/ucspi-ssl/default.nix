{ stdenv, fetchurl, openssl_1_1, ucspi-tcp, fehqlibs }:

let
  pkg = "ucspi-ssl";
  ver = "0.10.11";
  web = "https://www.fehcom.de/ipnet/ucspi-ssl";
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "${web}/${pkg}-${ver}.tgz";
    sha256 = "16bk19z6m9jd1ybr58iw0v9wrkr1dk1lnx2kjjnilqmwqic8kfgz";
  };
  sourceRoot = "host/superscript.com/net/${pkg}-${ver}";

  buildInputs = [openssl_1_1 fehqlibs];

  configurePhase = ''
    echo /etc/ssl/certs > conf-cadir
    echo /etc/ssl/pem/dh1024.pem > conf-dhfile
    echo > conf-ssl
    echo ${ucspi-tcp}/bin > conf-tcpbin
    echo $out > conf-home
    substituteInPlace src/sslclient.c --replace 'log(WHO' 'logmsg(WHO,0,LOG'
    substituteInPlace src/sslserver.c --replace 'log(WHO' 'logmsg(WHO,0,LOG'
    substituteInPlace src/sslhandle.c --replace 'log(who' 'logmsg(who,0,LOG'
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
    license = stdenv.lib.licenses.publicDomain.shortName;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ tzeman ];
  };
}

# vim: et ts=2 sw=2 
