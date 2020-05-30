# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  bglibs = pkgs.callPackage ./pkgs/bglibs { };
  ccollect = pkgs.callPackage ./pkgs/ccollect { };
  cvm = pkgs.callPackage ./pkgs/cvm { inherit bglibs; };
  djbdns = pkgs.callPackage ./pkgs/djbdns { };
  fehqlibs = pkgs.callPackage ./pkgs/fehqlibs { };
  guilt = pkgs.callPackage ./pkgs/guilt { };
  hgeditor = pkgs.callPackage ./pkgs/hgeditor { };
  ipsvd = pkgs.callPackage ./pkgs/ipsvd { };
  mailfront = pkgs.callPackage ./pkgs/mailfront { inherit bglibs cvm; };
  mailfront-addons = pkgs.callPackage ./pkgs/mailfront/addons.nix {
    inherit bglibs mailfront opendmarc;
  };
  mailfront-lua = pkgs.callPackage ./pkgs/mailfront {
    inherit bglibs cvm;
    luaPackage = pkgs.lua5_1;
  };
  mess822 = pkgs.callPackage ./pkgs/mess822 { };
  opendmarc = pkgs.callPackage ./pkgs/opendmarc { };
  qmail = pkgs.callPackage ./pkgs/qmail { };
  ucspi-ipc = pkgs.callPackage ./pkgs/ucspi-ipc { };
  ucspi-ssl = pkgs.callPackage ./pkgs/ucspi-ssl { inherit fehqlibs; };
  vmailmgr = pkgs.callPackage ./pkgs/vmailmgr { };
}

