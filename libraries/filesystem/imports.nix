/**
libraries/filesystem/imports.nix

Import and composition helpers for lib.filesystem.

# Exports:
- importPaths
- imports
- importAttrs
- importLibs

# Design:
- importPaths discovers importable nix paths.
- imports is an alias to importPaths.
- importAttrs imports and merges plain attrset-producing files.
- importLibs imports and assembles plain lib fragment files for a namespace.
*/
{lib}: let
  inherit (lib) assemble;
  inherit (lib.filesystem) inferNamespace normalizeInput collectPaths;
  inherit (lib.attrsets) attrNames attrValues filterAttrs mergeAttrsList;
  inherit (lib.lists) elem map;
  inherit (lib.trivial) functionArgs isFunction;

  importWithFilteredArgs = path: args: let
    target = import path;
  in
    if isFunction target
    then let
      declared = attrNames (functionArgs target);
      filtered = filterAttrs (name: _: elem name declared) args;
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
    values = attrValues all;
  in
    {
      __meta = {
        inherit names values all;
      };
    }
    // all;

  importLibs = input: let
    n = normalizeInput {args = {};} input;
    paths = collectPaths {
      inherit (n) path recurse;
    };
    namespace =
      if n.namespace != null
      then n.namespace
      else inferNamespace n.path;

    all = assemble {
      start = {};
      entries = paths;
      scope = acc:
        lib
        // {
          ${namespace} = acc;
        };
    };

    names = attrNames all;
    values = attrValues all;
  in {
    ${namespace} = all;
    __meta = {
      ${namespace} = {
        inherit namespace names values all paths;
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
