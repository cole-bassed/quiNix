{lib}:
lib.assembly.importLibs {
  inherit lib;
  path = ./.;
  ignore = ["llm.nix" "openclaw.nix" "rust.nix"];
}
