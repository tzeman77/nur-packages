{ pkgs ? import <nixpkgs> {} }:

let

  my-nur = import ../.. {
    inherit pkgs;
  };

in pkgs.mkShell {
  buildInputs = with my-nur; [
    pure-ftpd
  ];
}

# vim: et ts=2 sw=2 
