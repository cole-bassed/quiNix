/**
lib/shells/build.nix

Shell finalization.

lib.shells.mkShell is deliberately namespaced so it does NOT shadow
pkgs.mkShell. Callers use either:

  lib.shells.mkShell spec     → derivation
  pkgs.mkShell { ... }        → derivation (raw attrs, no spec)

lib.shells.mkShell is the only place in the codebase that calls pkgs.mkShell.
*/
{pkgs}: {
  /**
  Finalize a ShellSpec into a derivation.

  Strips `__meta` (not valid in pkgs.mkShell) and passes
  `spec.shell` directly.
  */
  mkShell = spec: pkgs.mkShell spec.shell;
}
