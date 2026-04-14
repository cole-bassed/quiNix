/**
lib/shells/config.nix

Shell spec constructors.

Each function returns a ShellSpec — it does NOT call pkgs.mkShell.
Finalization is handled by lib.shells.build.

Exported:
  mkRust    : { channel ? "nightly" } → ShellSpec
  mkAi      : { }                     → ShellSpec
  mkCombined: { channel ? "nightly" } → ShellSpec
*/
{
  lib,
  pkgs,
  mkTools,
  mkEnvironment,
  mkTemplates,
  mkWelcome,
}: let
  inherit (lib.shells) mergeShellSpecs;
  inherit (lib.packages) mkRust mkOpenClaw mkLLM;
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.lib.lists) optionals;

  /**
  Rust shell spec.

  Produces a spec for one Rust toolchain channel.
  The caller picks "nightly" | "stable" | "beta".
  */
  mkRustSpec = {channel ? "nightly"}: let
    rust = mkRust {inherit pkgs channel;};
    templates = mkTemplates {inherit pkgs;};
    tools = mkTools {inherit pkgs rust templates;};
    env = mkEnvironment {inherit rust channel;};
    welcome = mkWelcome {inherit pkgs tools;};
  in {
    __meta = {
      kind = "rust";
      inherit channel rust templates tools welcome;
    };

    shell = {
      name = "rust-${channel}";
      packages = tools.packages ++ optionals isDarwin [pkgs.libiconv];
      env = env;
      shellHook = ''
        ${tools.init}
        [ -n "$PRJ_HOME" ] || PRJ_HOME=$PWD
        [ -n "$PRJ_NAME" ] || PRJ_NAME=$(basename "$PRJ_HOME")
        RUST_VERSION=$(${tools.rustvv})
        export PRJ_HOME PRJ_NAME RUST_VERSION
        ${welcome}
      '';
    };
  };

  /**
  AI shell spec.

  Packages LLM tools + openclaw into a spec.
  */
  mkAiSpec = {}: let
    claw = mkOpenClaw {inherit pkgs;};
    llm = mkLLM {inherit pkgs lib;};
  in {
    __meta = {
      kind = "ai";
      inherit claw llm;
    };

    shell = {
      name = "ai-dev";
      packages = [claw.package] ++ llm.packages;
      env = llm.env;
      shellHook = ''
        echo "🤖 AI Development Environment"
        echo "   Tools: openclaw, claude-code, codex, gemini-cli, opencode"
        echo "   Set ANTHROPIC_API_KEY / OPENAI_API_KEY / GEMINI_API_KEY as needed."
      '';
    };
  };

  /**
  Combined (full) shell spec.

  Merges Rust + AI specs then overrides name and __meta.
  Relies on mergeShellSpecs to concatenate packages and shellHook.
  */
  mkCombinedSpec = {channel ? "nightly"}: let
    base =
      mergeShellSpecs
      (mkRustSpec {inherit channel;})
      (mkAiSpec {});
  in
    mergeShellSpecs base {
      __meta.kind = "combined";
      __meta.sources = ["rust.${channel}" "ai"];

      shell = {
        name = "full-${channel}";
        packages = [];
        env = {};
        shellHook = ""; # nothing to add; merge already accumulated both hooks
      };
    };
in {
  inherit mkRustSpec mkAiSpec mkCombinedSpec;
}
