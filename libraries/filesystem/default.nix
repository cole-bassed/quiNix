/**
libraries/filesystem/default.nix

Namespace owner for lib.filesystem.

Bootstraps lib.filesystem directly from local leaf overlays to avoid
self-recursion during fixed-point construction.
*/
final: prev: let
  overlays = [
    (import ./paths.nix)
    (import ./imports.nix)
  ];

  overlay = prev.composeManyExtensions overlays;
in {
  filesystem =
    (prev.filesystem or {})
    // (overlay final (prev.filesystem or {}));
}
