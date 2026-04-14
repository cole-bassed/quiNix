/**
libraries/packages/resolve.nix

Exports pure package/binary resolution helpers.
*/
final: prev: {
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

  extractMainProgram = pkg:
    if pkg ? meta.mainProgram
    then pkg.meta.mainProgram
    else pkg.pname or pkg.name or "";

  resolveBin = drv: "${drv}/bin/${final.packages.extractMainProgram drv}";

  mkBins = packages:
    final.mapAttrs (_: final.packages.resolveBin)
    (final.removeAttrs packages (
      final.attrNames (final.filterAttrs (_: v: v == null) packages)
    ));

  mkCmds = bins: f:
    builtins.mapAttrs (_: bin: f bin) bins;
}
