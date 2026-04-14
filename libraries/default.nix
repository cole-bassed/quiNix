{lib ? (import <nixpkgs> {}).lib}: let
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
  }:
    lib.foldl'
    (acc: entry: let
      lib' = scope acc;
    in
      acc // (import entry {lib = lib';}))
    start
    entries;
in
  assemble {
    start = lib // {inherit assemble;};
    scope = acc: acc;
    entries = [
      ./filesystem
      ./attrsets
      ./packages
      ./shells
      ./strings
    ];
  }
