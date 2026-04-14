/**
libraries/shells/default.nix

Mounts lib.shells extensions from leaf files.
*/
{lib}: let
  inherit (lib) fix foldl';

  entries = [
    ./meta.nix
    ./build.nix
    ./config.nix
  ];

  shells = fix (self:
    foldl'
    (acc: entry:
      acc // ((import entry) (lib // {shells = self;}) acc))
    {}
    entries);
in {
  inherit shells;
}
