/**
libraries/attrsets/default.nix

Namespace owner for lib.attrsets.

Leaf files in this directory contribute raw members of lib.attrsets.
*/
final: prev: let
  imported = final.importers.importLibs ./.;
in
  (final.importers.mountNamespace "attrsets" imported) final prev
