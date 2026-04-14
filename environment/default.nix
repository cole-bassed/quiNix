{
  inputs,
  lib,
  ...
}: let
  inherit (lib.packages) mkPkgs;
  inherit (lib.shells) mkShell mkShells;

  pkgs = mkPkgs {inherit inputs;};

  shells = rec {
    testShell = mkShell {
      inherit pkgs;
      name = "ai-rust";
      packages = [];
      env = {};
      shellHook = ''
        echo "🔧 AI+Rust REPL"
        echo "REPL: nix repl"
      '';
    };
    default = testShell;
  };
in {devShells = mkShells {inherit inputs shells;};}
