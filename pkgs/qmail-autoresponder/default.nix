{ stdenv, fetchurl, bglibs }:

let
  pkg = "qmail-autoresponder";
  ver = "2.0";
  web = http://untroubled.org/qmail-autoresponder;
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "${web}/archive/${pkg}-${ver}.tar.gz";
    sha256 = "152kxz96binw480lf514wb0242xf0w91prx9ln4hbjjqjwqir0sv";
  };

  buildFlags = "qmail-autoresponder";

  buildInputs = [bglibs];

  inherit bglibs;

  patches = [
    # don't use mysql.h
    ./options.patch
  ];

  configurePhase = ''
    echo $out/lib > conf-lib
    echo "gcc -g -L$bglibs/lib" > conf-ld
    echo $out/bin > conf-bin
    echo $out/man > conf-man
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 qmail-autoresponder $out/bin

    mkdir -p $out/man/man1
    install -m644 qmail-autoresponder.1 $out/man/man1
  '';

  meta = {
    description = "A secure, reliable, efficient, SMTP/POP3 server.";
    homepage = "${web}/${pkg}.html";
    license = stdenv.lib.licenses.publicDomain.shortName;
    platforms = stdenv.lib.platforms.gnu;
    maintainers = with stdenv.lib.maintainers; [ tzeman ];
  };
}

# vim: et ts=2 sw=2 

