/**
libraries/attrsets/default.nix

Mounts lib.attrsets extensions from leaf files.
*/
{lib}: {
  attrsets = lib.assemble {
    start = lib.attrsets;
    scope = acc: lib // {attrsets = acc;};
    entries = ./.;
  };
}
