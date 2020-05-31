{ stdenv, fetchFromGitHub, buildPythonPackage, future }:

buildPythonPackage rec {
  pname = "pywhois"; # -${version}";
  version = "2020-01-25";

  doCheck = false; # fails to pass because it tries to run in home directory

  src = fetchFromGitHub {
    owner = "richardpenman";
    repo = "pywhois";
    rev = "b9cf01fccef9bc5bbfd7b2ae6d4d37699a70bf78";
    sha256 = "0zjp2d1sqf5bi9s69afmjbm1z0w5mgkjxgji0nl5cbznpi7nq03w";
  };

  propagatedBuildInputs = [ future ];

  meta = with stdenv.lib; {
    description = "Python WHOIS library";
    homepage = https://github.com/richardpenman/pywhois;
  };
}

# vim: et ts=2 sw=2 
