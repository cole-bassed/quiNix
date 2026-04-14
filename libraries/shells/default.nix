# {lib}:
# lib.assembly.importLibs {
#   path = ./.;
#   # priority = ["build.nix"];
#   ignore = ["meta.nix" "config.nix"];
# }
{lib}: {
  strings = lib.assembly.assemble {
    start = lib.strings; # nixpkgs base
    scope = acc: lib // {strings = acc;};
    entries = ./.;
  };
}
