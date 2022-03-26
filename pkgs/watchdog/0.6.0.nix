{ stdenv
, lib
, buildPythonPackage
, fetchPypi
, argh
, pathtools
, pyyaml
, pkgs
}:

buildPythonPackage rec {
  pname = "watchdog";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1ncxbqb0absalr984pww3lif5hz1wanha0a0vk2lc7dkfv28xbma";
  };

  buildInputs = lib.optionals stdenv.isDarwin
    [ pkgs.darwin.apple_sdk.frameworks.CoreServices ];
  propagatedBuildInputs = [ argh pathtools pyyaml ];

  doCheck = false;

  meta = with lib; {
    description = "Python API and shell utilities to monitor file system events";
    homepage = https://github.com/gorakhargosh/watchdog;
    license = licenses.asl20;
    maintainers = with maintainers; [ goibhniu ];
  };

}
