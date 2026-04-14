/**
modules/libraries/packages/openclaw.nix

Exports OpenClaw package selectors and command helpers.
*/
{
  /**
  Select the OpenClaw package and derive canonical bin/cmd aliases.

  # Signature
  { pkgs } -> { package, bin, cmd }
  */
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
