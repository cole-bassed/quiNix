/**
libraries/packages/resolve.nix

Pure package and binary resolution helpers for lib.packages.
*/
{lib}: let
  inherit (lib.attrsets) attrNames genAttrs mapAttrs filterAttrs;
  inherit (lib.lists) elem findFirst head;
  inherit (lib.trivial) isFunction isNotEmpty isEmpty;

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
  mkPkgs = {
    inputs,
    system ? currentSystem,
    extraOverlays ? [],
  }: let
    packages = resolvePackages inputs;
  in
    import (packages.nix) {
      inherit system;
      overlays =
        [
          (resolveOverlay (packages.ai))
          (resolveOverlay (packages.openclaw))
          (resolveOverlay (packages.rust))
        ]
        ++ extraOverlays;
      config.allowUnfree = true;
    };

  #~@ System
  supportedSystems = {
    systems ? [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ],
  }:
    systems;

  currentSystem =
    if builtins ? currentSystem
    then builtins.currentSystem
    else head (supportedSystems {});

  defineSystem = {
    system ? currentSystem,
    systems ? supportedSystems {},
  }:
    if elem system systems
    then system
    else throw "Unsupported system: ${system}";

  getSystem = pkgs: pkgs.stdenv.hostPlatform.system;

  mkPkgsPerSystem = {inputs}:
    (genAttrs (supportedSystems {})) (
      system: mkPkgs {inherit inputs system;}
    );

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

  parseInput = {
    inputs,
    names,
    error ? "",
  }: let
    foundName = findFirst (name: inputs ? ${name}) null names;
    result =
      if foundName != null
      then inputs.${foundName}
      else null;
  in
    if (isEmpty result) && (isNotEmpty error)
    then throw error
    else result;

  /**
    Resolve specific package set inputs from the flake input attribute set.
    This allows for flexible naming conventions in flake.nix while maintaining
    a consistent internal API.

    # Inputs
    - `inputs`: The attribute set of flake inputs, typically passed from a Nixpkgs overlay or devShell.

    # Type
    ```nix
    resolvePackages :: AttrSet -> AttrSet
    ```

  # Examples
  ```nix
  let
    resolved = resolvePackages inputs;
  in
  resolved.nix # => returns inputs.nixpkgs-unstable or null
  ```

  # Returns
  - An attribute set containing resolved package inputs or null if not found.
  */
  resolvePackages = inputs: {
    nix = parseInput {
      inherit inputs;
      names = [
        "NixPackagesUnstable"
        "nixpkgs-unstable"
        "NixPackages"
        "nixpkgs-stable"
        "nixpkgs"
      ];
      error = "mkPkgs: Critical dependency 'nixpkgs' not found in inputs.";
    };

    rust = parseInput {
      inherit inputs;
      names = [
        "Rust"
        "RustOverlay"
        "rust-overlay"
        "oxalica"
      ];
    };

    openclaw = parseInput {
      inherit inputs;
      names = [
        "OpenClaw"
        "openclaw"
        "claw"
      ];
    };

    ai = parseInput {
      inherit inputs;
      names = [
        "AIAgents"
        "ai-agents"
        "ai-tooling"
        "llm"
        "llm-agents"
        "AI"
        "ai"
      ];
    };
  };

  resolveOverlay = input: let
    noop = _: _: {};
  in
    if isNotEmpty input
    then
      if input ? overlays.default
      then input.overlays.default #? Modern Flake? Use it.
      else if isFunction (import input)
      then (import input) #? Old school? Import it and hope for the best.
      else noop #? Can't import it, give up.
    else noop;

  /**
  Resolve a derivation's main executable path.

  # Inputs
  - `drv`: A derivation package with an executable output.

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
  # Inside resolve.nix
  resolveBin = drv:
    if lib ? getExe
    then lib.getExe drv
    else "${drv}/bin/${drv.meta.mainProgram or drv.pname or (lib.parseDrvName drv.name).name}";

  resolveBins = packages:
    mapAttrs
    (_: resolveBin)
    (filterAttrs (_: isNotEmpty) packages);

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
    mapAttrs (_: resolveBin)
    (removeAttrs packages (
      attrNames (filterAttrs (_: v: v == null) packages)
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
  # Logic: Map over bins, apply f, and filter out any null results automatically.
  mkCmds = bins: f:
    filterAttrs (_: isNotEmpty) (mapAttrs (
        _: bin:
          if isNotEmpty bin
          then f bin
          else null
      )
      bins);
in {
  inherit
    defineSystem
    currentSystem
    supportedSystems
    getSystem
    mkPkgs
    mkPkgsPerSystem
    extractMainProgram
    resolveBin
    resolveBins
    mkBins
    mkCmds
    ;
}
