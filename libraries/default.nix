/**
libraries/default.nix

Bootstrap lib.assembly from assembly.nix, then sequentially extend lib with
each namespace.  Order = dependency order; later entries see earlier ones on
their incoming `lib`.
*/
{lib ? (import <nixpkgs> {}).lib}: let
  lib' = lib // (import ./assembly.nix {inherit lib;});
in
  lib'.assembly.assemble {
    start = lib';
    scope = acc: acc;
    entries = ./.;
    ignore = ["tests" "assembly.nix"];
  }
