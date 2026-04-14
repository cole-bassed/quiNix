{lib}:
lib.filesystem.importLibs {
  path = ./.;
  dependencies = [../filesystem];
  priority = ["resolve.nix"];
  ignore = ["llm.nix" "openclaw.nix" "rust.nix"];
}
