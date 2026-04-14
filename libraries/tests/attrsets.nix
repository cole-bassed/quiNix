{
  lib,
  assertMsg,
}: let
  inherit (lib.attrsets) optionalAttr recursiveAttrs compactAttrs mapFilterAttrs toEnv;
in {
  optionalAttr =
    assertMsg
    ((optionalAttr true "foo" 42) == {foo = 42;})
    "optionalAttr true";

  optionalAttrFalse =
    assertMsg
    ((optionalAttr false "foo" 42) == {})
    "optionalAttr false";

  recursiveAttrs =
    assertMsg
    ((recursiveAttrs {
        a = {b = 1;};
        c = {
          b = 2;
          d = {e = 3;};
        };
      })
      == {
        a.b = 1;
        c.b = 2;
        c.d.e = 3;
      })
    "recursiveAttrs merges";

  compactAttrs =
    assertMsg
    ((compactAttrs {
        a = 1;
        b = null;
        c = "";
      })
      == {
        a = 1;
        c = "";
      })
    "compactAttrs removes null";

  mapFilterAttrs =
    assertMsg
    ((mapFilterAttrs (n: v:
          if v == null
          then null
          else "${n}_x${toString v}")
        {
          a = 1;
          b = null;
          c = 2;
        })
      == {
        a = "a_x1";
        c = "c_x2";
      })
    "mapFilterAttrs compacts";

  toEnv =
    assertMsg
    ((toEnv {
        VERSION = 1;
        DEBUG = true;
        NULL = null;
      })
      == {
        VERSION = "1";
        DEBUG = "true";
      })
    "toEnv stringifies/compacts";
}
