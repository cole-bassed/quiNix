/**
libraries/packages/openclaw.nix

Exports OpenClaw package selectors and command helpers.
*/
final: prev: {
  mkOpenClaw = {pkgs}: let
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
  in {
    inherit package bin cmd;
  };
}
