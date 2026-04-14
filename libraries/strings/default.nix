/**
libraries/strings/default.nix

Mounts lib.strings extensions from leaf files.
*/
{lib}: {
  strings = lib.assemble {
    start = lib.strings;
    scope = acc: lib // {strings = acc;};
    entries = ./.;
  };
}
