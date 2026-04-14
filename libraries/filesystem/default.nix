{lib}: {
  filesystem = lib.project.foldScoped {
    start = lib.filesystem;
    scope = acc: lib // {filesystem = acc;};
    entries = [
      ./paths.nix
      ./imports.nix
    ];
  };
}
