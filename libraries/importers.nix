/**
modules/libraries/importers.nix

Extends lib.importers with project-local import helpers.

# Extensions
- importPaths: collect importable nix paths
- importAttrs: import and merge attrset-producing files
- importLibs: import lib fragments and optionally mount under a namespace

# Input shapes (accepted by all three importers)
All importers accept any of:
  - a single path:   importLibs ./packages
  - a list of paths: importLibs [ ./a.nix ./b.nix ]
  - an attrset:      importLibs { path = ./packages; namespace = "pkgs"; }

# Namespace inference
When `namespace` is not explicitly set, it is inferred from the basename:
  ./packages      → "packages"
  ./attrsets.nix  → "attrsets"
When input is a list of paths, namespace defaults to null.

# Return shape
When namespace = null:
  { __meta = { names, values, all; }; } // all

When namespace != null:
  { ${namespace} = (prev.${namespace} or {}) // all; __meta = ...; }

# Reserved key
`__meta` is reserved for importer metadata.
*/
final: prev: let
  inherit
    (prev.attrsets)
    attrNames
    attrValues
    filterAttrs
    mergeAttrsList
    ;
  inherit
    (prev.filesystem)
    isPath
    pathIsRegularFile
    pathType
    readDir
    ;
  inherit (prev.lists) concatMap elem filter flatten isList map;
  inherit (prev.strings) hasSuffix removeSuffix;
  inherit (prev.trivial) functionArgs isFunction;

  foldersToExclude = [
    "archives"
    "review"
    "temp"
    "tmp"
  ];

  # ── internal helpers ────────────────────────────────────────────────────────

  /**
  Infer a namespace string from a path.
    ./packages      → "packages"
    ./attrsets.nix  → "attrsets"
  */
  inferNamespace = path:
    removeSuffix ".nix" (baseNameOf (toString path));

  /**
  Normalize any accepted input shape into a canonical attrset.

  Handles:
    - path       → { path, recurse, namespace, args }
    - [path]     → { path, recurse, namespace = null, args }
    - attrset    → merged with defaults; namespace inferred if not set

  # Type
  ```nix
  normalizeInput :: any -> { path, recurse, namespace, args }
  ```
  */
  normalizeInput = defaults: input: let
    base =
      {
        recurse = false;
        namespace = null;
        args = {};
      }
      // defaults;
  in
    if isPath input
    then
      base
      // {
        path = input;
        namespace = inferNamespace input;
      }
    else if isList input
    then
      base
      // {
        path = input;
        namespace = null;
      }
    else
      # attrset — infer namespace from path if not explicitly set
      base
      // input
      // {
        namespace =
          if input ? namespace
          then input.namespace
          else inferNamespace (input.path or input);
      };

  isNixFile = name: entry:
    entry
    == "regular"
    && hasSuffix ".nix" name
    && name != "default.nix";

  isIncludedDir = name: entry:
    entry
    == "directory"
    && !(elem name foldersToExclude);

  importWithFilteredArgs = path: args: let
    target = import path;
  in
    if isFunction target
    then let
      required = attrNames (functionArgs target);
      filtered = filterAttrs (name: _: elem name required) args;
    in
      target filtered
    else target;

  # ── path collection ─────────────────────────────────────────────────────────

  collectFromDir = {
    path,
    recurse ? false,
  }: let
    entries = readDir path;

    filePaths =
      map
      (name: path + "/${name}")
      (filter (name: isNixFile name entries.${name}) (attrNames entries));

    dirPaths =
      concatMap
      (name: let
        subPath = path + "/${name}";
        subEntries = readDir subPath;
        hasDefault =
          subEntries ? "default.nix"
          && subEntries."default.nix" == "regular";
      in
        if hasDefault
        then [subPath]
        else if recurse
        then
          collectFromDir {
            path = subPath;
            inherit recurse;
          }
        else [])
      (filter (name: isIncludedDir name entries.${name}) (attrNames entries));
  in
    filePaths ++ dirPaths;

  collectPaths = {
    path,
    recurse ? false,
  }:
    flatten (map
      (p:
        if pathType p == "directory"
        then
          collectFromDir {
            path = p;
            inherit recurse;
          }
        else if pathIsRegularFile p && hasSuffix ".nix" (baseNameOf p)
        then [p]
        else [])
      (
        if isList path
        then path
        else [path]
      ));

  # ── public API ──────────────────────────────────────────────────────────────

  /**
  Collect importable nix paths from a path, list of paths, or attrset config.

  # Type
  ```nix
  importPaths :: path | [path] | { path, recurse ? false } -> [path]
  ```

  # Examples
  ```nix
  lib.importers.importPaths ./modules
  lib.importers.importPaths { path = ./modules; recurse = true; }
  ```
  */
  importPaths = input: let
    n = normalizeInput {} input;
  in
    collectPaths {inherit (n) path recurse;};

  /**
  Import and merge attrset-producing files from a path, list, or attrset.

  Function-valued files are called with only the args they declare.

  # Type
  ```nix
  importAttrs :: path | [path] | { path, recurse ? false, args ? {} } -> AttrSet
  ```

  # Examples
  ```nix
  lib.importers.importAttrs ./tools
  lib.importers.importAttrs { path = ./tools; args = { inherit pkgs; }; }
  ```
  */
  importAttrs = input: let
    n = normalizeInput {} input;
    paths = collectPaths {inherit (n) path recurse;};
  in
    mergeAttrsList (map (p: importWithFilteredArgs p n.args) paths);

  /**
  Import lib fragments shaped as `{ final, prev }: { ... }`,
  merge them, and mount under an inferred or explicit namespace.

  # Type
  ```nix
  importLibs :: path | [path] | {
    path :: path | [path];
    recurse ? false;
    namespace ? inferNamespace path;
  } -> AttrSet
  ```

  # Metadata
  When `namespace = null`:
    { __meta = { names, values, all; }; } // all

  When `namespace != null`:
    {
      ${namespace} = ...;
      __meta.${namespace} = { names, values, all; };
    }
  */
  importLibs = input: let
    n = normalizeInput {} input;
    paths = collectPaths {inherit (n) path recurse;};
    all = mergeAttrsList (map (p: import p {inherit final prev;}) paths);
    names = attrNames all;
    values = attrValues all;
    meta = {inherit names values all;};
  in
    if n.namespace == null
    then {__meta = meta;} // all
    else {
      ${n.namespace} = (prev.${n.namespace} or {}) // all;
      __meta = {
        ${n.namespace} = meta;
      };
    };
in {
  importers =
    (prev.importers or {})
    // {
      inherit
        importPaths
        importAttrs
        importLibs
        ;
    };
}
