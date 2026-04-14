/**
  modules/libraries/package.nix

  Extends lib with package and binary resolution utilities.
  Consumed via lib.extend in libraries/default.nix.

  Additions:
    lib.extractMainProgram — safely read meta.mainProgram with fallbacks
    lib.resolvePackage     — null-safe package selection
    lib.resolveBin         — derive a /bin/<prog> path from a derivation
    lib.mkBins             — build a complete name → bin-path attrset
    lib.mkCmds             — build a name → shell-string attrset from bins
*/
final: prev:

let
  inherit (prev.attrsets) mapAttrs filterAttrs;
in {

  /**
    Extract the primary executable name from a derivation,
    falling back through pname → name → "" if meta.mainProgram is unset.
  */
  extractMainProgram = pkg:
    if pkg ? meta.mainProgram
    then pkg.meta.mainProgram
    else pkg.pname or pkg.name or "";

  /**
    Return pkg if non-null, otherwise fall back to fallback.
    Useful for optional overlay packages that may not exist yet.

      lib.resolvePackage pkgs.someNew pkgs.someOld
  */
  resolvePackage = pkg: fallback:
    if pkg != null then pkg else fallback;

  /**
    Derive the full store path to a package's main binary.

      lib.resolveBin pkgs.ripgrep  →  "/nix/store/.../bin/rg"
  */
  resolveBin = drv:
    "${drv}/bin/${final.extractMainProgram drv}";

  /**
    Build a name → bin-path attrset from a name → derivation attrset,
    dropping null entries (optional packages that weren't found).

      lib.mkBins { rg = pkgs.ripgrep; missing = null; }
      →  { rg = "/nix/store/.../bin/rg"; }
  */
  mkBins = packages:
    mapAttrs (_: final.resolveBin)
      (filterAttrs (_: v: v != null) packages);

  /**
    Build a name → shell-string attrset by applying f to each bin path.

      lib.mkCmds { rg = "..."; } (bin: "${bin} --color=always")
      →  { rg = ".../bin/rg --color=always"; }
  */
  mkCmds = bins: f:
    mapAttrs (_: bin: f bin) bins;
}
