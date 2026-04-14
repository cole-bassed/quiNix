{
  lib ? {},
  inputs ? {},
}: let
  paths = {
    root = ./.;
    libraries = ./libraries;
    modules = ./modules;
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
    modules = import paths.modules {
      inherit inputs;
      inherit (flake) lib;
    };
    inherit (flake.modules) mkOutputs;
  };
in
  if flake != {}
  then flake
  else {
    #~@ Basic
    inherit paths;
    lib = libraries;
  }
