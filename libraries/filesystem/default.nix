{lib}:
lib.assembly.importLibs {
  path = ./.;
  priority = ["paths.nix" "imports.nix"];
}
