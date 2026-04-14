/**
lib/shells/meta.nix

Shell-aware merge logic.

A ShellSpec has the shape:
```nix
{
  __meta = { kind, ... };
  shell = {
    name     = string;
    packages = [ drv ];
    env      = { ... };
    shellHook = string;
  };
}
```

Plain `recursiveUpdate` is NOT enough here because:
- `packages`  → must concatenate, not replace
- `shellHook` → must concatenate, not replace
- `env`       → recursiveUpdate is correct
- `__meta`    → recursiveUpdate is correct
- `name`      → right wins (caller sets final name explicitly)
*/
{lib}: let
  inherit (lib.attrsets) recursiveUpdate;

  /**
  The empty / identity spec.
  Folding from this guarantees a complete shape even if
  individual specs omit optional fields.
  */
  emptySpec = {
    __meta = {};
    shell = {
      name = "unnamed";
      packages = [];
      env = {};
      shellHook = "";
    };
  };

  /**
  Merge two ShellSpecs with shell-aware semantics.
  Right side wins for `name`.
  `packages` and `shellHook` are accumulated.
  `env` and `__meta` are recursively updated.
  */
  mergeShellSpecs = left: right: {
    __meta =
      recursiveUpdate
      (left.__meta  or {})
      (right.__meta or {});

    shell = {
      name = right.shell.name or left.shell.name or "unnamed";

      packages =
        (left.shell.packages  or [])
        ++ (right.shell.packages or []);

      env =
        recursiveUpdate
        (left.shell.env  or {})
        (right.shell.env or {});

      shellHook = let
        l = left.shell.shellHook  or "";
        r = right.shell.shellHook or "";
      in
        if l == ""
        then r
        else if r == ""
        then l
        else "${l}\n${r}";
    };
  };

  /**
  Fold a list of ShellSpecs into one via mergeShellSpecs.
  Starts from emptySpec so callers never need to handle
  an empty list specially.
  */
  mergeMany = builtins.foldl' mergeShellSpecs emptySpec;
in {
  inherit emptySpec mergeShellSpecs mergeMany;
}
