/**
modules/libraries/default.nix

Composes all library extensions into a single lib.extend chain,
so each overlay can reference functions from earlier ones via `final`.

Usage in modules/default.nix:

  lib = import ./libraries { inherit (inputs.NixPackages) lib; };

Downstream modules then receive the extended lib and call
lib.compactAttrs, lib.resolveBin, etc. directly — no separate
mkLib attrset needed.
*/
{lib}:
lib.extend (
  final: prev:
    {}
    // (import ./attrsets.nix final prev)
    // (import ./packages.nix final prev)
)
