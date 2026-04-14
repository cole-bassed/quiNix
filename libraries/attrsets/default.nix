/**
libraries/attrsets/default.nix

Namespace owner for lib.attrsets.

Leaf files in this directory contribute raw members of lib.attrsets.
*/
/**
libraries/attrsets/default.nix

Mounts lib.attrsets extensions from leaf files.
*/
{lib}: lib.filesystem.importLibs ./.
