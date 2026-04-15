{lib}: let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.lists) findFirst;
  inherit (lib.packages) currentSystem supportedSystems;
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
    inputs ? {},
    system ? currentSystem,
    extraOverlays ? [],
  }: let
    packages = resolvePackages inputs;
  in
    if isEmpty inputs
    then import <nixpkgs> {inherit system;}
    else
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

  mkPkgsPerSystem = {inputs, ...}:
    (genAttrs (supportedSystems {})) (
      system: mkPkgs {inherit inputs system;}
    );

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
in {inherit mkPkgs mkPkgsPerSystem;}
