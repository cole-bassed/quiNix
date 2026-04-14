{lib ? (import <nixpkgs> {}).lib}: let
  inherit (lib.asserts) assertMsg;
  attrsets = import ./attrsets.nix {inherit lib assertMsg;};
  filesystem = import ./filesystem.nix {inherit lib assertMsg;};
in
  true
