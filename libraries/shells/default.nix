/**
libraries/shells/default.nix

Mounts lib.shells extensions from leaf files.
*/
{lib}:
lib.filesystem.importLibs {
  path = ./.;
  priority = ["build.nix"];
  ignore = ["meta.nix" "config.nix"];
}
