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
