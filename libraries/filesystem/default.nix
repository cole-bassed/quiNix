# {lib}: lib.assembly.importLibs {path = ./.;}
{lib}: {
  filesystem = lib.assembly.assemble {
    start = lib.filesystem;
    scope = ./.;
  };
}
