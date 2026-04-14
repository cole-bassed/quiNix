{lib ? (import <nixpkgs> {}).lib}: let
  inherit (lib.attrsets) attrNames;
  inherit (lib.filesystem) readDir;
  inherit (lib.lists) elem isList filter;

  /**
  Assemble a list of modules in sequence, passing each module the progressively
  extended `lib`.

  This avoids fixed-point recursion from `lib.extend` while still allowing later
  namespaces to depend on earlier custom namespaces.

  # Type
  ```nix
  assemble :: {
    start :: AttrSet;
    entries :: [path];
    scope ? (AttrSet -> AttrSet);
  } -> AttrSet
  ```

  # Parameters
  - `start`: the initial accumulator
  - `entries`: files or directories to import in order
  - `scope`: maps the current accumulator to the `lib` value passed to the next import

  # Examples
  ```nix
  assemble {
    start = lib;
    entries = [ ./filesystem ./attrsets ];
    scope = acc: acc;
  }

  assemble {
    start = lib.filesystem;
    entries = [ ./paths.nix ./imports.nix ];
    scope = acc: lib // { filesystem = acc; };
  }
  ```
  */
  assemble = {
    start,
    entries,
    scope ? (acc: acc),
    priority ? [],
    ignore ? [],
  }: let
    orderedEntries =
      if isList entries
      then
        filter
        (entry: !(elem (baseNameOf (toString entry)) ignore))
        entries
      else let
        dir = readDir entries;
        names =
          filter
          (name:
            !(elem name ignore)
            && name != "default.nix"
            && (
              dir.${name}
              == "directory"
              || (
                dir.${name}
                == "regular"
                && lib.strings.hasSuffix ".nix" name
              )
            ))
          (attrNames dir);

        prioritized =
          filter
          (name: elem name names)
          priority;

        remaining =
          filter
          (name: !(elem name prioritized))
          names;
      in
        map
        (name: entries + "/${name}")
        (prioritized ++ remaining);
  in
    lib.foldl'
    (acc: entry: let
      lib' = scope acc;
    in
      acc // (import entry {lib = lib';}))
    start
    orderedEntries;
in
  assemble {
    start = lib // {inherit assemble;};
    scope = acc: acc;
    entries = ./.;
    priority = ["filesystem"];
    ignore = ["tests"];
  }
