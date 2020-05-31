{ stdenv, fetchurl, buildPythonPackage, future }:

buildPythonPackage rec {
  pname = "pywhois"; # -${version}";
  version = "2019-09-07";

  doCheck = false; # fails to pass because it tries to run in home directory

  src = fetchurl {
    url = "https://github.com/richardpenman/pywhois/archive/c6b441a3e9ae7d66d34166ba801009f00f72291c.zip";
    sha256 = "0yr7yp0hzdysaxrzky2f5nv0kngjxw4i5ynkmbygvhj6jh9skd0q";
  };

  propagatedBuildInputs = [ future ];

  meta = with stdenv.lib; {
    description = "Python WHOIS library";
    homepage = https://github.com/richardpenman/pywhois;
  };
}

# vim: et ts=2 sw=2 
