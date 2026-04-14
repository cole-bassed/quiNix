/**
libraries.nix

Project-local lib entrypoint.

Each child path here is a namespace root whose default.nix is responsible
for importing and mounting its own leaf fragments.

Usage:
```nix
lib = import ./libraries.nix { inherit (inputs.NixPackages) lib; };
```
*/
{lib ? (import <nixpkgs> {}).lib}:
lib.extend (
  lib.composeManyExtensions [
    (import ./filesystem)
    # (import ./attrsets)
    # (import ./packages)
    # (import ./shells)
  ]
)
