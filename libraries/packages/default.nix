/**
libraries/packages/default.nix

Mounts lib.packages extensions from leaf files.
*/
{lib}: let
  inherit (lib) fix foldl';

  entries = [
    ./resolve.nix
    ./rust.nix
    ./openclaw.nix
    ./llm.nix
  ];

  packages = fix (self:
    foldl'
    (acc: entry:
      acc // ((import entry) (lib // {packages = self;}) acc))
    {}
    entries);
in {
  inherit packages;
}
