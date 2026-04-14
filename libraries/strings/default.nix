/**
libraries/strings/default.nix

Namespace owner for lib.strings.

Leaf files in this directory contribute raw members of lib.strings.
*/
final: prev:
final.strings.importLibs ./. final prev
