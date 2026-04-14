# {lib}: lib.assembly.importLibs {path = ./.;}
{lib}: {
  attrsets = lib.assembly.assemble {
    start = lib.attrsets;
    scope = acc: lib // {attrsets = acc;};
    entries = ./.;
  };
}
