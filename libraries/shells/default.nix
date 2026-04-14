{lib}:
lib.assembly.importLibs {
  path = ./.;
  dependencies = [../packages];
  priority = ["build.nix"];
  ignore = ["meta.nix" "config.nix"];
}
