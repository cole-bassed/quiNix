{
  lib ? (import <nixpkgs> {}).lib,
  inputs ? {},
}: let
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
    #~@ Flake
    inherit modules inputs paths;
    lib = libraries;
    inherit (modules) mkOutputs;
  }
  else {
    #~@ Basic
    inherit paths;
    lib = libraries;
  }
