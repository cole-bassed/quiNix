{
  inputs,
  lib,
  ...
}: let
  inherit (lib.packages) mkPkgs;
  inherit (lib.shells) mkShell mkShells;

  pkgs = mkPkgs {inherit inputs;};

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
  # default=testShell;
  # in {devShells = mkPkgsPerSystem {inherit inputs;};}
in {
  devShells = mkShells {
    inherit inputs;
    shells = {
      inherit testShell;
    };
  };
}
