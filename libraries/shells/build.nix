/**
libraries/shells/build.nix

Shell finalization helpers for lib.shells.
*/
{lib}: let
  inherit (lib.attrsets) attrNames attrValues genAttrs isDerivation mapAttrs optionalAttrs;
  inherit (lib.packages) currentSystem supportedSystems mkPkgsPerSystem;
  inherit (lib.lists) filter findFirst optionals;
  inherit (lib.strings) isString concatStringsSep;
  inherit (lib.trivial) isEmpty isNotEmpty;

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
    pkgs ? null,
    inputs ? {},
    system ? currentSystem,
    shell ? {},
    name ? "",
    packages ? [],
    env ? {},
    shellHook ? "",
    ...
  }: let
    #? Performance note: We use null-check here because pkgs can be huge.
    #? isNotEmpty (nixpkgs) would force evaluation of all attribute names.
    pkgs' =
      if pkgs != null
      then pkgs
      else mkPkgsPerSystem {inherit inputs system;};

    #> Recursively update or manual merge preserve data.
    finalShellArgs =
      shell
      // {
        name =
          if isNotEmpty name
          then name
          else (shell.name or "nix-dev");

        packages =
          (shell.packages or [])
          ++ (optionals (isNotEmpty packages) packages);

        env =
          (shell.env or {})
          // (optionalAttrs (isNotEmpty env) env);

        #> Combine hooks rather than overwriting them
        #? Filtering out empty strings and joining with a newline.
        shellHook = concatStringsSep "\n" (
          filter isNotEmpty [
            (shell.shellHook or "")
            shellHook
          ]
        );
      };
  in
    pkgs'.mkShell finalShellArgs;

  # mkShells = {
  #   inputs,
  #   shells ? {},
  #   default ? null,
  # }:
  #   mapAttrs
  #   (_: pkgs: let
  #     processShell = shell:
  #       if isDerivation shell
  #       then shell
  #       else mkShell {inherit pkgs shell;};

  #     processedShells = mapAttrs (_: processShell) shells;

  #     defaultShell =
  #       if isEmpty default
  #       then
  #         #> Find the first actual derivation in the set
  #         let
  #           found =
  #             findFirst
  #             isDerivation
  #             null
  #             (attrValues processedShells);
  #         in
  #           if found == null
  #           then throw "mkShells: No shells defined and no default provided."
  #           else found
  #       else if isString default
  #       then
  #         processedShells.${
  #           default
  #         } or (throw ''
  #           mkShells: default shell '${default}' not found.
  #           Available shells: ${
  #             concatStringsSep ", " (attrNames processedShells)
  #           }'')
  #       else if isDerivation default
  #       then default
  #       else processShell default;
  #   in
  #     processedShells // {default = defaultShell;})
  #   (mkPkgsPerSystem {inherit inputs;});
  mkShells = {
    # inputs,
    shells ? {},
    default ? null,
  }: let
    resolvedDefault =
      if default == null
      then let
        found = findFirst isDerivation null (attrValues shells);
      in
        if found == null
        then throw "mkShells: no shells defined and no default provided."
        else found
      else if isString default
      then
        shells.${
          default
        }
      or (throw ''
          mkShells: default shell '${default}' not found.
          Available: ${concatStringsSep ", " (attrNames shells)}'')
      else if isDerivation default
      then default
      else mkShell {shell = default;}; # treat plain attrset as a spec

    finalShells = shells // {default = resolvedDefault;};
  in
    # Wrap the same shells under every system key.
    # For true per-system builds, pass specs instead of pre-built derivations.
    genAttrs (supportedSystems {}) (_: finalShells);
in {inherit mkShell mkShells;}
