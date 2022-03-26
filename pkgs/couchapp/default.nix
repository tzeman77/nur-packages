{ lib, stdenv, fetchPypi, buildPythonPackage, restkit, watchdog060 }:

buildPythonPackage rec {
  pname = "Couchapp";
  version = "1.0.2";

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "1lbfrzfmr1mzlp4mf0ma6ybk1agf1b28lv3qw8x0lgph6rsvl6ls";
  };

  propagatedBuildInputs = [ restkit watchdog060 ];

  meta = with lib; {
    description = "CouchApp is designed to structure standalone CouchDB application development for maximum application portability.";
    homepage = http://github.com/couchapp/couchapp;
  };
}

# vim: et ts=2 sw=2 
