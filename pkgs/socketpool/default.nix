{ stdenv, fetchPypi, buildPythonPackage }:

buildPythonPackage rec {
  pname = "socketpool";
  version = "0.5.3";

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "1v72lsyvp9ijapah8n226qyjb1i35l86i8faiw5vdi2n991k6rx0";
  };

  propagatedBuildInputs = [ ];

  meta = with stdenv.lib; {
    description = "Socketpool - a simple Python socket pool.";
    homepage = http://github.com/benoitc/socketpool;
  };
}

# vim: et ts=2 sw=2 
