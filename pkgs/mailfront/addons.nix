{ lib, stdenv, fetchFromGitHub, bglibs, mailfront, openssl, opendkim, libspf2
, opendmarc }:

let
  pkg = "mailfront-addons";
  ver = "2013-05-31";
  web = https://github.com/spamvictim/mailfront-addons;
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchFromGitHub {
    owner = "spamvictim";
    repo = "mailfront-addons";
    rev = "2467b672b84aaf13b61905885c7ffa185cd86ae8";
    sha256 = "1bm1f8dlxiz9h56i30zc4h6qhdk7527p70msrx5rf668jxjl3dcy";
  };

  patches = [
    ./addons.patch
    ./authres.patch
  ];

  buildInputs = [bglibs mailfront openssl opendkim libspf2 opendmarc];
  inherit bglibs mailfront;

  configurePhase = ''
    ln -sf Makefile.local Makefile
    ln -sf $mailfront/include/mailfront/*.h .
    echo "/var/qmail" > conf-qmail
    echo "gcc -W -Wall -Wshadow -O -g -DHAVE_NS_TYPE" > conf-cc
    echo "gcc -s " > conf-ld
    echo "gcc -W -Wall -Wshadow -O -g -fPIC -shared -DHAVE_NS_TYPE" > conf-ccso
    echo $out/bin > conf-bin
    echo $out/include > conf-include
    echo $out/lib/mailfront-addons > conf-modules
  '';

  meta = {
    description = "Plugins for mailfront SMTP daemon";
    homepage = web;
    platforms = lib.platforms.gnu;
    maintainers = with lib.maintainers; [ tzeman ];
  };

}

# vim: et ts=2 sw=2 
