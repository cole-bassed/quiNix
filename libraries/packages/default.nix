# {lib}:
# lib.assembly.importLibs {
#   path = ./.;
#   ignore = ["llm.nix" "openclaw.nix" "rust.nix"];
# }
{lib}: {
  filesystem = lib.assembly.assemble {
    start = lib.filesystem;
    scope = acc: lib // {filesystem = acc;};
    entries = [
      ./resolve.nix
      # ./llm.nix
      # ./openclaw.nix
      # ./rust.nix
    ];
  };
}
