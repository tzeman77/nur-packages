{ lib, stdenv, fetchPypi, buildPythonPackage, http-parser }:

buildPythonPackage rec {
  pname = "http-parser";
  version = "0.9.0";

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "0896llw23zwmv1f4rg40927hznkg03d3jxd9ibwk0wi2qrbkl7a4";
  };

  propagatedBuildInputs = [ ];

  meta = with lib; {
    description = "HTTP request/response parser for Python";
    homepage = http://github.com/benoitc/http-parser;
  };
}

# vim: et ts=2 sw=2 
