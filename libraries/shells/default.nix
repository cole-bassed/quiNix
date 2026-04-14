/**
libraries/shells/default.nix

Namespace owner for lib.shells.

Leaf files in this directory contribute raw members of lib.shells.
*/
final: prev: let
  imported = final.importers.importLibs ./.;
in
  (final.importers.mountNamespace "shells" imported) final prev
