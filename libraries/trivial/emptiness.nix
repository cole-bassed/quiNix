{lib}: let
  inherit (lib.attrsets) isAttrs attrNames;
  inherit (lib.lists) isList length;

  /**
  Determine whether a value is empty.

  This function checks if a value is empty by testing multiple conditions:
  - An empty string
  - null value
  - An empty attribute set
  - An empty list

  # Inputs

  `x` (any type)
  : The value to check for emptiness.

  # Type

  ```
  isEmpty :: a -> bool
  ```

  # Return

  `true` if the value is empty, `false` otherwise.

  # Examples

  ```nix
  isEmpty ""        # Returns: true
  isEmpty null      # Returns: true
  isEmpty {}        # Returns: true
  isEmpty []        # Returns: true
  isEmpty "hello"   # Returns: false
  isEmpty { a = 1; } # Returns: false
  isEmpty [ 1 ]     # Returns: false
  ```
  */
  isEmpty = x:
    (x == "")
    || (x == null)
    || (isAttrs x && length (attrNames x) == 0)
    || (isList x && length x == 0);

  /**
  Determine whether a value is not empty.

  This is the logical negation of `lib.trivial.isEmpty`.

  # Inputs

  `x` (any type)
  : The value to check.

  # Type

  ```
  isNotEmpty :: a -> bool
  ```

  # Return

  `true` if the value is not empty, `false` otherwise.
  */
  isNotEmpty = x: !isEmpty x;
in {
  inherit
    isEmpty
    isNotEmpty
    ;
}
