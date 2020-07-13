{ stdenv, fetchPypi, buildPythonPackage, http-parser, socketpool }:

buildPythonPackage rec {
  pname = "restkit"; # -${version}";
  version = "4.2.2";

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "17ark3apjl08hjdvwv4wb34ap4qk294snbb1if0mwfv4gkmsigf0";
  };

  propagatedBuildInputs = [ http-parser socketpool ];

  meta = with stdenv.lib; {
    description = "HTTP resource kit for Python";
    homepage = http://benoitc.github.io/restkit;
  };
}

# vim: et ts=2 sw=2 
