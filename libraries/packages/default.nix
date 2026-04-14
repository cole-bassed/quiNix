/**
libraries/packages/default.nix

Namespace owner for lib.packages.

Leaf files in this directory contribute raw members of lib.packages.
*/
final: prev: let
  imported = final.importers.importLibs ./.;
in
  (final.importers.mountNamespace "packages" imported) final prev
