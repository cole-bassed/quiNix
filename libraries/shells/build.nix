/**
libraries/shells/build.nix

Shell finalization helpers for lib.shells.
*/
{lib}: let
  inherit (lib.packages) mkPkgsPerSystem;
  inherit (lib.attrsets) attrValues mapAttrs optionalAttrs;
  inherit (lib.lists) findFirst optionals;
  inherit (lib.strings) optionalString;
  # TODO: Move isEppty to a relevant namespace.
  inherit (lib.attrsets) isAttrs attrNames;
  inherit (lib.lists) isList length;
  isEmpty = x:
    (x == "")
    || (x == null)
    || (isAttrs x && length (attrNames x) == 0)
    || (isList x && length x == 0);

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
        name = optionalString (isEmpty name) name;
        packages = optionals (isEmpty packages) packages;
        env = optionalAttrs (isEmpty env) env;
        shellHook = optionalString (isEmpty shellHook) shellHook;
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
          else findFirst (shell: !isEmpty shell) "" (attrValues shells);
      })
    (mkPkgsPerSystem {inherit inputs;});
in {inherit mkShell mkShells;}
