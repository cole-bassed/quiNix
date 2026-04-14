/**
libraries/attrsets/default.nix

Mounts lib.attrsets extensions from leaf files.
*/
{lib}: lib.filesystem.importLibs ./.
