# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

with pkgs;
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  bglibs = pkgs.callPackage ./pkgs/bglibs { };
  ccollect = pkgs.callPackage ./pkgs/ccollect { };
  couchapp = with python2.pkgs; pkgs.callPackage ./pkgs/couchapp {
    inherit buildPythonPackage fetchPypi restkit watchdog060;
  };
  cvm = pkgs.callPackage ./pkgs/cvm { inherit bglibs; };
  djbdns = pkgs.callPackage ./pkgs/djbdns { };
  fehqlibs = pkgs.callPackage ./pkgs/fehqlibs { };
  guilt = pkgs.callPackage ./pkgs/guilt { };
  hgeditor = pkgs.callPackage ./pkgs/hgeditor { };
  http-parser = with python2.pkgs; pkgs.callPackage ./pkgs/http-parser {
    inherit buildPythonPackage fetchPypi;
  };
  ipsvd = pkgs.callPackage ./pkgs/ipsvd { };
  libspf2 = pkgs.callPackage ./pkgs/libspf2 { }; # backport to 19.03
  mailfront = pkgs.callPackage ./pkgs/mailfront { inherit bglibs cvm; };
  mailfront-addons = pkgs.callPackage ./pkgs/mailfront/addons.nix {
    inherit bglibs mailfront opendmarc;
  };
  mailfront-lua = pkgs.callPackage ./pkgs/mailfront {
    inherit bglibs cvm;
    luaPackage = pkgs.lua5_1;
  };
  mariadb55 = pkgs.callPackage ./pkgs/mariadb/5.5.nix {
    openssl = openssl_1_0_2;
    stdenv = gcc8Stdenv;
  };
  mess822 = pkgs.callPackage ./pkgs/mess822 { };
  opendmarc = pkgs.callPackage ./pkgs/opendmarc { };
  php53 = (pkgs.callPackage ./pkgs/php/5.3.nix {
    stdenv = gcc6Stdenv;
    openssl = openssl_1_0_2;
    icu = icu59;
    mysql = mysql57.override {
      openssl = openssl_1_0_2;
    };
  }).php53;
  php54 = (pkgs.callPackage ./pkgs/php/5.3.nix {
    openldap = openldap.override {
      openssl = openssl_1_0_2;
    };
    openssl = openssl_1_0_2;
    icu = icu59;
    mysql = mysql57.override {
      openssl = openssl_1_0_2;
    };
  }).php54;
  php56 = (pkgs.callPackage ./pkgs/php/5.6.nix {
    icu = icu59;
    mysql = mysql57;
  }).php56;
  phpMyAdmin = pkgs.callPackage ./pkgs/phpMyAdmin { };
  pure-ftpd = pkgs.callPackage ./pkgs/pure-ftpd { };
  pywhois = with python3.pkgs; pkgs.callPackage ./pkgs/pywhois {
    inherit buildPythonPackage future;
  };
  qmail = pkgs.callPackage ./pkgs/qmail { };
  qmail-autoresponder = pkgs.callPackage ./pkgs/qmail-autoresponder {
    inherit bglibs;
  };
  qmail-queue-dkimsign = pkgs.callPackage ./pkgs/qmail-queue-dkimsign {
    inherit qmail mess822;
  };
  restkit = with python2.pkgs; pkgs.callPackage ./pkgs/restkit {
    inherit buildPythonPackage fetchPypi http-parser socketpool;
  };
  socketpool = with python2.pkgs; pkgs.callPackage ./pkgs/socketpool {
    inherit buildPythonPackage fetchPypi;
  };
  ucspi-ipc = pkgs.callPackage ./pkgs/ucspi-ipc { };
  ucspi-ssl = pkgs.callPackage ./pkgs/ucspi-ssl { inherit fehqlibs; };
  vmailmgr = pkgs.callPackage ./pkgs/vmailmgr { };
  watchdog060 = with python2.pkgs; pkgs.callPackage ./pkgs/watchdog/0.6.0.nix {
    inherit buildPythonPackage fetchPypi argh pathtools pyyaml;
  };
  zabbix = pkgs.callPackage ./pkgs/zabbix/3.4.nix { };
  zabbix34_mysql = recurseIntoAttrs (callPackage ./pkgs/zabbix/3.4.nix {
    mysqlPackage = mysql57.client;
  });
  zabbix-scripts = pkgs.callPackage ./pkgs/zabbix-scripts { };
  zoom-us = pkgs.callPackage ./pkgs/zoom-us {
    alsa-lib = alsaLib;
  };
}

# vim: et ts=2 sw=2 
