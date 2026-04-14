/**
libraries/filesystem/imports.nix

Import and composition helpers for lib.filesystem.

Exports raw members of the filesystem namespace:
- importPaths
- imports
- importAttrs
- importLibs

Design:
- importPaths discovers importable nix paths.
- imports is an alias to importPaths.
- importAttrs imports plain attrset-producing files.
- importLibs imports overlay fragments and mounts them under the inferred
  or explicit namespace.
*/
final: prev: let
  lib = final;

  inherit
    (final.filesystem)
    inferNamespace
    normalizeInput
    collectPaths
    ;
  inherit
    (final.attrsets)
    attrNames
    filterAttrs
    mergeAttrsList
    ;
  inherit (final.lists) map;
  inherit (final.strings) removeSuffix;
  inherit (final.trivial) functionArgs isFunction;

  importWithFilteredArgs = path: args: let
    target = import path;
  in
    if isFunction target
    then let
      declared = attrNames (functionArgs target);
      filtered = filterAttrs (name: _: builtins.elem name declared) args;
    in
      target filtered
    else target;

  importPaths = input: let
    n = normalizeInput {} input;
  in
    collectPaths {
      inherit (n) path recurse;
    };

  importAttrs = input: let
    n = normalizeInput {} input;
    paths = collectPaths {
      inherit (n) path recurse;
    };
    all = mergeAttrsList (map (p: importWithFilteredArgs p n.args) paths);
    names = attrNames all;
    values = builtins.attrValues all;
  in
    {
      __meta = {
        inherit names values all;
      };
    }
    // all;

  importLibs = input: let
    n = normalizeInput {} input;
    paths = collectPaths {
      inherit (n) path recurse;
    };
    namespace =
      if n.namespace != null
      then n.namespace
      else inferNamespace n.path;

    overlays = map import paths;
    overlay = lib.composeManyExtensions overlays;
    names =
      map
      (p: removeSuffix ".nix" (baseNameOf (toString p)))
      paths;
  in
    final': prev': let
      base = prev'.${namespace} or {};
      loaded = overlay final' base;
    in {
      ${namespace} = base // loaded;
      __meta =
        (prev'.__meta or {})
        // {
          ${namespace} = {
            inherit namespace names paths;
            values = builtins.attrValues loaded;
            all = loaded;
          };
        };
    };
in {
  inherit
    importPaths
    importAttrs
    importLibs
    ;
  imports = importPaths;
}
