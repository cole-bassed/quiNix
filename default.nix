{
  lib ? (import <nixpkgs> {}).lib,
  self ? {},
}: let
  inputs = self.inputs or {};
  paths = {
    root = ./.;
    libraries = ./libraries;
    modules = ./modules;
  };
  modules = import paths.modules {inherit lib inputs;};
  libraries = import paths.libraries {inherit lib;};
in
  if inputs != {}
  then {
    inherit modules inputs paths;
    lib = libraries;
  }
  else {
    inherit paths;
    lib = libraries;
  }
