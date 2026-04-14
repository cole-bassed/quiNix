/**
libraries/attrsets/core.nix

Attrset utilities for lib.attrsets.
*/
{lib}: let
  inherit
    (lib.attrsets)
    attrValues
    filterAttrs
    mapAttrs
    optionalAttrs
    recursiveUpdate
    ;
  inherit (lib.lists) foldl;

  optionalAttr = condition: name: value:
    optionalAttrs condition {"${name}" = value;};

  recursiveAttrs = conditions:
    foldl recursiveUpdate {} (attrValues conditions);

  compactAttrs = filterAttrs (_: v: v != null);

  mapFilterAttrs = f: attrs:
    compactAttrs (mapAttrs f attrs);

  toEnv = attrs:
    compactAttrs (mapAttrs (_: v: toString v) attrs);
in {
  inherit
    optionalAttr
    recursiveAttrs
    compactAttrs
    mapFilterAttrs
    toEnv
    ;
}
