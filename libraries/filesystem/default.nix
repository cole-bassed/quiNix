/**
libraries/filesystem/default.nix

Mounts lib.filesystem extensions from leaf files.
*/
{lib}: {
  filesystem = lib.assemble {
    start = lib.filesystem;
    scope = acc: lib // {filesystem = acc;};
    entries = [
      ./paths.nix
      ./imports.nix
    ];
  };
}
