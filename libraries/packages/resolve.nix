/**
modules/libraries/packages/bin.nix

Exports pure package/binary resolution helpers.
*/
{lib}: let
  inherit (lib.attrsets) filterAttrs mapAttrs attrNames;
  /**
  Construct nixpkgs with all project overlays applied.

  # Signature
  { inputs } -> { system } -> pkgs
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
  Extract the primary executable name from a derivation,
  falling back through pname -> name -> "" if meta.mainProgram is unset.
  */
  extractMainProgram = pkg:
    if pkg ? meta.mainProgram
    then pkg.meta.mainProgram
    else pkg.pname or pkg.name or "";

  /**
  Derive the full store path to a package's main binary.
  */
  resolveBin = drv: "${drv}/bin/${extractMainProgram drv}";

  /**
  Build a name -> bin-path attrset from a name -> derivation attrset,
  dropping null entries.
  */
  mkBins = packages:
    mapAttrs (_: resolveBin)
    (removeAttrs packages (
      attrNames (filterAttrs (_: v: v == null) packages)
    ));

  /**
  Build a name -> shell-string attrset by applying f to each bin path.
  */
  mkCmds = bins: f:
    builtins.mapAttrs (_: bin: f bin) bins;
in {
  inherit
    mkPkgs
    extractMainProgram
    resolveBin
    mkBins
    mkCmds
    ;
}
