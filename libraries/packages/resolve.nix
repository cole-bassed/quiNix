/**
libraries/packages/resolve.nix

Pure package and binary resolution helpers for lib.packages.
*/
final: prev: {
  /**
  Construct a `pkgs` set with the project overlays applied.

  # Type
  ```nix
  mkPkgs :: { inputs :: AttrSet; } -> { system :: string; } -> AttrSet
  ```

  # Examples
  ```nix
  mkPkgs { inherit inputs; } { system = "x86_64-linux"; }
  # => import inputs.NixPackages { ... }
  ```

  # Returns
  A `pkgs` set imported from `inputs.NixPackages` with the project overlays applied.
  */
  mkPkgs = {inputs}: {system}:
    import inputs.NixPackages {
      inherit system;
      overlays = with inputs; [
        (import Rust)
        OpenClaw.overlays.default
        AIAgents.overlays.default
      ];
      config.allowUnfree = true;
    };

  /**
  Resolve the main program name from a derivation.

  # Type
  ```nix
  extractMainProgram :: derivation -> string
  ```

  # Examples
  ```nix
  extractMainProgram pkgs.hello
  # => "hello"
  ```

  # Returns
  The executable name resolved from `meta.mainProgram`, `pname`, or `name`.
  */
  extractMainProgram = pkg:
    if pkg ? meta.mainProgram
    then pkg.meta.mainProgram
    else pkg.pname or pkg.name or "";

  /**
  Resolve a derivation's main executable path.

  # Type
  ```nix
  resolveBin :: derivation -> string
  ```

  # Examples
  ```nix
  resolveBin pkgs.hello
  # => "/nix/store/.../bin/hello"
  ```

  # Returns
  The absolute path to the derivation's main executable.
  */
  resolveBin = drv: "${drv}/bin/${final.packages.extractMainProgram drv}";

  /**
  Convert an attrset of derivations into an attrset of executable paths.

  Null values are dropped first.

  # Type
  ```nix
  mkBins :: AttrSet -> AttrSet
  ```

  # Examples
  ```nix
  mkBins {
    hello = pkgs.hello;
    skipped = null;
  }
  # => {
  #   hello = "/nix/store/.../bin/hello";
  # }
  ```

  # Returns
  An attrset of executable paths with `null` package entries removed first.
  */
  mkBins = packages:
    final.mapAttrs (_: final.packages.resolveBin)
    (final.removeAttrs packages (
      final.attrNames (final.filterAttrs (_: v: v == null) packages)
    ));

  /**
  Map executable paths into shell-command helpers.

  # Type
  ```nix
  mkCmds :: AttrSet -> (string -> string) -> AttrSet
  ```

  # Examples
  ```nix
  mkCmds { hello = "/nix/store/.../bin/hello"; } (bin: "${bin} --help")
  # => {
  #   hello = "/nix/store/.../bin/hello --help";
  # }
  ```

  # Returns
  An attrset produced by mapping each binary path through the provided function.
  */
  mkCmds = bins: f:
    builtins.mapAttrs (_: bin: f bin) bins;
}
