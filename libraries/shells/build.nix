/**
libraries/shells/build.nix

Shell finalization.

Exports raw members for lib.shells.
*/
final: prev: {
  mkShell = spec: spec.__meta.pkgs.mkShell spec.shell;
}
