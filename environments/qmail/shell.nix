{ pkgs ? import <nixpkgs> {} }:

let

  my-nur = import ../.. {
    inherit pkgs;
  };

in pkgs.mkShell {
  buildInputs = with my-nur; [
    bglibs
    cvm
    fehqlibs
    ipsvd
    mailfront
    mailfront-addons
    mailfront-lua
    mess822
    opendmarc
    qmail
    qmail-autoresponder
    qmail-queue-dkimsign
    ucspi-ipc
    ucspi-ssl
    vmailmgr
  ];
}

# vim: et ts=2 sw=2 
