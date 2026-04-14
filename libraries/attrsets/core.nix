/**
libraries/attrsets/core.nix

Project-local additions to lib.attrsets.

Exports raw members for the attrsets namespace.
*/
final: prev: let
  inherit
    (final.attrsets)
    attrValues
    filterAttrs
    mapAttrs
    optionalAttrs
    recursiveUpdate
    ;
  inherit (final.lists) foldl;

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
