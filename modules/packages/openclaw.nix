/**
modules/packages/openclaw.nix

Selects the OpenClaw package from pkgs after openclaw.overlays.default
is applied in packages/default.nix.

OpenClaw is an AI-powered code search and agent orchestration tool.
See: https://github.com/Scout-DJ/openclaw-nix

Returns: { package, bin, cmd }
*/
{pkgs}: let
  package = pkgs.openclaw;

  bin = {
    openclaw = "${package}/bin/${package.meta.mainProgram or "openclaw"}";
  };

  cmd = {
    claw = bin.openclaw;
    claw-ask = "${bin.openclaw} ask";
    claw-idx = "${bin.openclaw} index";
    claw-run = "${bin.openclaw} run";
  };
in {inherit package bin cmd;}
