/**
modules/libraries/default.nix

Composes all library extensions into a single lib.extend chain.

# Usage
```nix
lib = import ./libraries { inherit (inputs.NixPackages) lib; };
```
*/
# {lib ? (import <nixpkgs> {}).lib}:
# lib.extend (
#   lib.composeManyExtensions [
#     (import ./importers.nix)
#     (
#       final: prev: let
#         inherit (final.importers) importLibs;
#         inherit (prev.attrsets) mergeAttrsList;
#       in
#         mergeAttrsList [
#           (importLibs ./attrsets.nix)
#           (importLibs ./packages)
#           (importLibs ./shells)
#         ]
#     )
#   ]
# )
{lib ? (import <nixpkgs> {}).lib}: let
  inherit (import ./importers.nix {inherit lib;}) importLibs;
in
  importLibs [
    ./attrsets.nix
    ./packages
    ./shells
  ]
