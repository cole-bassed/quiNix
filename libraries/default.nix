{lib ? (import <nixpkgs> {}).lib}: let
  lib' = lib // (import ./assembly.nix {inherit lib;});
in
  lib'.assembly.assemble {
    start = lib';
    scope = acc: acc;
    entries = [
      ./filesystem
      ./attrsets
      ./strings
      ./packages
      ./shells
    ];
  }
