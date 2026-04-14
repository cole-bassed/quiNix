{lib}: let
  inherit (lib.filesystem) isPath pathIsRegularFile pathType readDir;
  inherit (lib.attrsets) attrNames;
  inherit (lib.lists) concatMap elem filter flatten isList map;
  inherit (lib.strings) hasSuffix;

  foldersToExclude = ["archives" "review" "temp" "tmp"];

  isNixFile = name: entry:
    entry == "regular" && hasSuffix ".nix" name && name != "default.nix";

  isIncludedDir = name: entry:
    entry == "directory" && !(elem name foldersToExclude);

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
    isNixFile
    isIncludedDir
    collectFromDir
    collectPaths
    ;
}
