/**
libraries/packages/default.nix

Mounts lib.packages extensions from leaf files.
*/
{lib}:
lib.filesystem.importLibs {
  path = ./.;
  priority = ["resolve.nix"];
  ignore = ["llm.nix" "openclaw.nix" "rust.nix"];
}
