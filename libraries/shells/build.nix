/**
libraries/shells/build.nix

Shell finalization helpers for lib.shells.
*/
final: prev: {
  /**
  Turn a shell spec into a `pkgs.mkShell` derivation.

  # Type
  ```nix
  mkShell :: AttrSet -> derivation
  ```

  # Examples
  ```nix
  mkShell {
    __meta.pkgs = pkgs;
    shell = {
      name = "demo";
      packages = [];
      env = {};
      shellHook = "";
    };
  }
  # => pkgs.mkShell { ... }
  ```

  # Returns
  The final `pkgs.mkShell` derivation built from the shell spec.
  */
  mkShell = spec: spec.__meta.pkgs.mkShell spec.shell;
}
