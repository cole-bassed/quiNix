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

  /**
  Conditionally create a single-attribute attrset.

  Returns an empty attrset when `condition` is false.

  # Type
  ```nix
  optionalAttr :: bool -> string -> any -> AttrSet
  ```

  # Examples
  ```nix
  optionalAttr true "foo" 42
  # => { foo = 42; }

  optionalAttr false "foo" 42
  # => {}
  ```
  */
  optionalAttr = condition: name: value:
    optionalAttrs condition {"${name}" = value;};

  /**
  Merge a set of attrsets recursively.

  Later nested values override earlier ones using `recursiveUpdate`.

  # Type
  ```nix
  recursiveAttrs :: AttrSet -> AttrSet
  ```

  # Examples
  ```nix
  recursiveAttrs {
    a = { services.nginx.enable = true; };
    b = { services.postgresql.enable = true; };
  }
  # => {
  #   services.nginx.enable = true;
  #   services.postgresql.enable = true;
  # }
  ```
  */
  recursiveAttrs = conditions:
    foldl recursiveUpdate {} (attrValues conditions);

  /**
  Remove attributes whose values are `null`.

  Non-null falsey values such as `false`, `0`, and `""` are preserved.

  # Type
  ```nix
  compactAttrs :: AttrSet -> AttrSet
  ```

  # Examples
  ```nix
  compactAttrs {
    a = 1;
    b = null;
    c = "";
  }
  # => {
  #   a = 1;
  #   c = "";
  # }
  ```
  */
  compactAttrs = filterAttrs (_: v: v != null);

  /**
  Map an attrset and drop attributes whose mapped values are `null`.

  Same notion of "drop" as `compactAttrs`.

  # Type
  ```nix
  mapFilterAttrs :: (string -> any -> any | null) -> AttrSet -> AttrSet
  ```

  # Examples
  ```nix
  mapFilterAttrs
  (name: value:
    if value == null
    then null
    else "${name}-${toString value}")
  {
    a = 1;
    b = null;
    c = 2;
  }
  # => {
  #   a = "a-1";
  #   c = "c-2";
  # }
  ```
  */
  mapFilterAttrs = f: attrs:
    compactAttrs (mapAttrs f attrs);

  /**
  Convert attrset values to strings and drop `null` values.

  Useful for producing environment-variable attrsets.

  # Type
  ```nix
  toEnv :: AttrSet -> AttrSet
  ```

  # Examples
  ```nix
  toEnv {
    VERSION = 1;
    DEBUG = true;
    NULL = null;
  }
  # => {
  #   VERSION = "1";
  #   DEBUG = "true";
  # }
  ```
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
