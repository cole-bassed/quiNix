/**
modules/libraries/attrsets.nix

Extends lib.attrsets with project-local utilities.

# Extensions
- optionalAttr: conditionally include a single attribute
- recursiveAttrs: fold multiple optional sets into one via recursiveUpdate
- compactAttrs: remove all null-valued attributes
- mapFilterAttrs: map over attrset and drop null results
- toEnv: convert attrset to string-valued environment variables
*/
final: prev: let
  inherit
    (prev.attrsets)
    attrValues
    filterAttrs
    mapAttrs
    optionalAttrs
    recursiveUpdate
    ;
  inherit (prev.lists) foldl;

  /**
  Conditionally include a single attribute.
    lib.optionalAttr true  "key" val  →  { key = val; }
    lib.optionalAttr false "key" val  →  {}
  */
  optionalAttr = condition: name: value:
    optionalAttrs condition {"${name}" = value;};

  /**
  Fold a set of optional attrsets into one via recursiveUpdate,
  so deeper keys are merged rather than replaced.

    lib.recursiveAttrs {
      a = lib.optionalAttr true  "x" 1;
      b = lib.optionalAttr false "y" 2;
    }
    →  { x = 1; }
  */
  recursiveAttrs = conditions:
    foldl recursiveUpdate {} (attrValues conditions);

  /**
  Remove all attributes whose value is null.

    lib.compactAttrs { a = 1; b = null; c = 3; }  →  { a = 1; c = 3; }
  */
  compactAttrs = filterAttrs (_: v: v != null);

  /**
  Map over an attrset and drop entries where f returns null.

    lib.mapFilterAttrs (n: v: if v > 1 then v * 2 else null) { a = 1; b = 2; c = 3; }
    →  { b = 4; c = 6; }
  */
  mapFilterAttrs = f: attrs:
    compactAttrs (mapAttrs f attrs);

  /**
  Normalize an attrset into string-valued env vars and strip nulls.
    lib.toEnv { A = 1; B = null; }  →  { A = "1"; }
  */
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
