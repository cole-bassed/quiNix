{
  lib ? {},
  inputs ? {},
}: let
  paths = {
    root = ./.;
    libraries = ./libraries;
    devShells = ./modules;
  };

  libraries = import paths.libraries {
    lib =
      if inputs != {}
      then inputs.NixPackages.lib
      else if lib != {}
      then lib
      else (import <nixpkgs> {}).lib;
  };

  inherit (libraries.attrsets) optionalAttrs;

  flake = optionalAttrs (inputs != {}) {
    inherit inputs paths;
    lib = libraries;
    inherit
      (import paths.devShells {
        inherit inputs;
        inherit (flake) lib;
      })
      devShells
      ;
  };
in
  if flake != {}
  then flake
  else {
    #~@ Basic
    inherit paths;
    lib = libraries;
  }
