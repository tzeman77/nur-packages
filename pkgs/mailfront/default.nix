{ lib, stdenv, fetchurl, bglibs, cvm, luaPackage ? null }:

let
  pkg = "mailfront";
  ver = "2.22";
  web = http://untroubled.org;
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "${web}/${pkg}/archive/${pkg}-${ver}.tar.gz";
    sha256 = "0gsjdajwsqcd814r5ylfrb2cmhvdnkkm02vnvag8pl7dvkjyv02v";
  };

  patches = [
    ./auth-to-env.patch
    # http://choonrpms.choon.net/sl/6x/choonrpms/SRPMS/mailfront-2.01-1.choon.sl6.src.rpm
    # https://github.com/giamteckchoon/mailfront/commits/2.01
    ./Add-ucspitls.c-and-ucspitls.h-with-fix-CVE-2011-0411.patch
    ./Add-STARTTLS-support-in-imapfront-auth.c.patch # minor fix of include <bglibs/...>
    ./Add-ucspitls.h-and-ucspitls.c-in-Makefile-and-ucspit.patch
    ./Add-STLS-support-in-pop3front-auth.c.patch
  ];

  buildInputs = [cvm bglibs] ++ lib.optional (luaPackage != null) luaPackage;
  inherit bglibs;

  configurePhase = ''
    echo "gcc -W -Wall -Wshadow -O -g -I$bglibs/include -I$cvm/include" > conf-cc
    echo "gcc -s -L$bglibs/lib -L$cvm/lib" > conf-ld
    echo "gcc -W -Wall -Wshadow -O -g -I$bglibs/include -I$cvm/include -fPIC -shared" > conf-ccso
    echo $out/bin > conf-bin
    echo $out/include > conf-include
    echo $out/lib/mailfront > conf-modules
  '';

  postBuild = ''
  ${lib.optionalString (luaPackage != null) ''
    make lua
  ''}
  '';

  meta = {
    description = "Mail server network protocol front-ends";
    homepage = "${web}/${pkg}";
    license = lib.licenses.gpl2Plus.fullName;
    platforms = lib.platforms.gnu;
    maintainers = with lib.maintainers; [ tzeman ];
  };

}

# vim: et ts=2 sw=2 
