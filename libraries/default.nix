/**
libraries/default.nix

Bootstrap lib.assembly from assembly.nix, then sequentially extend lib with
each namespace.  Order = dependency order; later entries see earlier ones on
their incoming `lib`.
*/
{lib ? (import <nixpkgs> {}).lib}: let
  # Put assembly helpers on lib FIRST so every namespace default.nix can call
  # lib.assembly.importLibs / lib.assembly.assemble.
  lib' = lib // (import ./assembly.nix {inherit lib;});
in
  lib'.assembly.assemble {
    start  = lib';
    scope  = acc: acc;          # each entry receives the accumulated lib
    entries = [
      ./filesystem              # no custom deps — only nixpkgs needed
      ./attrsets                # depends on lib.filesystem (collectPaths etc.)
      ./strings                 # no cross-namespace deps
      ./packages                # depends on lib.filesystem
      ./shells                  # depends on lib.packages
    ];
    ignore = ["tests" "assembly.nix"];
  }
