{lib}: let
  inherit (lib) assemble;
  inherit (lib.attrsets) attrNames attrValues filterAttrs mergeAttrsList;
  inherit (lib.filesystem) isPath collectPaths;
  inherit (lib.lists) elem map isList;
  inherit (lib.strings) removeSuffix;
  inherit (lib.trivial) functionArgs isFunction;

  normalizeInput = defaults: input: let
    base =
      {
        recurse = false;
        namespace = null;
        args = {};
        priority = [];
        ignore = [];
      }
      // defaults;
  in
    if isPath input
    then base // {path = input;}
    else if isList input
    then base // {path = input;}
    else base // input;

  inferNamespace = path:
    removeSuffix ".nix" (baseNameOf (toString path));

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
    collectPaths {inherit (n) path recurse;};

  importAttrs = input: let
    n = normalizeInput {} input;
    paths = collectPaths {inherit (n) path recurse;};
    all = mergeAttrsList (map (p: importWithFilteredArgs p n.args) paths);
    names = attrNames all;
    values = attrValues all;
  in
    {__meta = {inherit names values all;};} // all;

  importLibs = input: let
    n = normalizeInput {args = {};} input;
    paths = collectPaths {inherit (n) path recurse;};
    namespace =
      if n.namespace != null
      then n.namespace
      else inferNamespace n.path;

    all = assemble {
      start = {};
      entries = paths;
      scope = acc: lib // {${namespace} = acc;};
      priority = n.priority or [];
      ignore = n.ignore or [];
    };

    names = attrNames all;
    values = attrValues all;
  in {
    ${namespace} = all;
    __meta.${namespace} = {inherit namespace names values all paths;};
  };
in {
  inherit
    importPaths
    importAttrs
    importLibs
    normalizeInput
    inferNamespace
    ;
  imports = importPaths;
}
