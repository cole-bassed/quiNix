/**
libraries/shells/build.nix

Shell finalization helpers for lib.shells.
*/
{lib}: let
  inherit (lib.packages) mkPkgsPerSystem;
  inherit (lib.attrsets) attrValues mapAttrs optionalAttrs;
  inherit (lib.lists) findFirst optionals;
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) isNotEmpty;

  /**
  Turn a shell spec into a `pkgs.mkShell` derivation.

  # Type
  ```nix
  mkShell :: { pkgs :: AttrSet; spec :: AttrSet; } -> derivation
  ```

  # Examples
  ```nix
  mkShell {
    pkgs = pkgs.x86_64-linux;
    args = {
      name = "demo";
      packages = [];
      env = {};
      shellHook = "";
    };
  }
  ```
  */
  mkShell = {
    pkgs,
    args ? {},
    name ? "",
    packages ? [],
    env ? {},
    shellHook ? "",
    ...
  }: let
    shell =
      args
      // {
        name = optionalString (isNotEmpty name) name;
        packages = optionals (isNotEmpty packages) packages;
        env = optionalAttrs (isNotEmpty env) env;
        shellHook = optionalString (isNotEmpty shellHook) shellHook;
      };
  in
    pkgs.mkShell shell;

  mkShells = {
    inputs,
    shells ? {},
    default ? {},
  }:
    mapAttrs
    (_: pkgs: let
    in
      shells
      // {
        default =
          if (default != {})
          then default
          else findFirst (shell: isNotEmpty shell) "" (attrValues shells);
      })
    (mkPkgsPerSystem {inherit inputs;});
in {inherit mkShell mkShells;}
