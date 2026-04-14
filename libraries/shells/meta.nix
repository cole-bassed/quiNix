/**
libraries/shells/meta.nix

Shell-aware merge logic.
*/
final: prev: let
  inherit (final.attrsets) recursiveUpdate;

  emptySpec = {
    __meta = {};
    shell = {
      name = "unnamed";
      packages = [];
      env = {};
      shellHook = "";
    };
  };

  mergeShellSpecs = left: right: {
    __meta =
      recursiveUpdate
      (left.__meta or {})
      (right.__meta or {});

    shell = {
      name = right.shell.name or left.shell.name or "unnamed";

      packages =
        (left.shell.packages or [])
        ++ (right.shell.packages or []);

      env =
        recursiveUpdate
        (left.shell.env or {})
        (right.shell.env or {});

      shellHook = let
        l = left.shell.shellHook or "";
        r = right.shell.shellHook or "";
      in
        if l == ""
        then r
        else if r == ""
        then l
        else "${l}\n${r}";
    };
  };

  mergeMany = builtins.foldl' mergeShellSpecs emptySpec;
in {
  inherit emptySpec mergeShellSpecs mergeMany;
}
