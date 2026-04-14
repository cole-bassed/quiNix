/**
libraries/filesystem/paths.nix

Path and discovery helpers for lib.filesystem.

Exports raw members of the filesystem namespace:
- foldersToExclude
- inferNamespace
- normalizeInput
- isNixFile
- isIncludedDir
- collectFromDir
- collectPaths
*/
final: prev: let
  inherit
    (final.filesystem)
    isPath
    pathIsRegularFile
    pathType
    readDir
    ;
  inherit (final.attrsets) attrNames;
  inherit (final.lists) concatMap elem filter flatten isList map;
  inherit (final.strings) hasSuffix removeSuffix;

  foldersToExclude = [
    "archives"
    "review"
    "temp"
    "tmp"
  ];

  inferNamespace = path:
    removeSuffix ".nix" (baseNameOf (toString path));

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
    then base // {path = input;}
    else if isList input
    then base // {path = input;}
    else base // input;

  isNixFile = name: entry:
    entry
    == "regular"
    && hasSuffix ".nix" name
    && name != "default.nix";

  isIncludedDir = name: entry:
    entry
    == "directory"
    && !(elem name foldersToExclude);

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
    flatten (
      map
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
      )
    );
in {
  inherit
    foldersToExclude
    inferNamespace
    normalizeInput
    isNixFile
    isIncludedDir
    collectFromDir
    collectPaths
    ;
}
