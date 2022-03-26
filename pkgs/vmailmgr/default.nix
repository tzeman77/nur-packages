{ lib, stdenv, fetchurl }:

let
  pkg = "vmailmgr";
  ver = "0.97";
  homepage = http://untroubled.org/vmailmgr;
in stdenv.mkDerivation rec {
  name = "${pkg}-${ver}";

  src = fetchurl {
    url = "${homepage}/current/${pkg}-${ver}.tar.gz";
    sha256 = "1hlrqcs5ddynh8v43sj4p6ri3gsyxqy45s0jr5sbz4crn8yqfrk2";
  };

  patches = [ ./compile.patch ./checkvpw.patch ]; # compile (strcasestr redefined)

  preConfigure = ''
    sed -i -e "s@phpdir=.*\$@phpdir=\"$out/lib/php\"@" configure
  '';

  meta = {
    description = "Virtual e-mail domains/users management programs";
    homepage = homepage;
    license = lib.licenses.gpl2;
    #platforms = stdenv.lib.platforms.gnu;
    maintainers = with lib.maintainers; [ tzeman ];
  };
}

