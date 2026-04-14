/**
libraries/filesystem/default.nix

Extends lib.filesystem with path-discovery and import helpers.
Starts from nixpkgs lib.filesystem so all upstream functions are preserved.
*/
{lib}: {
  filesystem = lib.assembly.assemble {
    start   = lib.filesystem;             # nixpkgs base
    scope   = acc: lib // {filesystem = acc;};
    entries = [
      ./paths.nix
      ./imports.nix
    ];
  };
}
