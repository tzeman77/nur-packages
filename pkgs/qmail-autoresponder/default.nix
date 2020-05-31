{ stdenv, fetchurl, bglibs }:

let
  pkg = "qmail-autoresponder";
  ver = "0.98";
  web = http://untroubled.org/qmail-autoresponder;
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "${web}/archive/${pkg}-${ver}.tar.gz";
    sha256 = "1ckwanysk8dvh3zh9kni9dbss0zjzrfnhvs3lz1sxzglkkck2ha0";
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

