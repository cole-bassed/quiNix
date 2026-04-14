/**
libraries/shells/config.nix

Shell spec constructors.

Exports raw members for lib.shells.
*/
final: prev: {
  mkRustSpec = {
    lib,
    pkgs,
    mkTools,
    mkEnvironment,
    mkTemplates,
    mkWelcome,
    channel ? "nightly",
  }: let
    inherit (lib.packages) mkRust;
    inherit (pkgs.stdenv) isDarwin;
    inherit (pkgs.lib.lists) optionals;

    rust = mkRust {inherit pkgs channel;};
    templates = mkTemplates {inherit pkgs;};
    tools = mkTools {inherit pkgs rust templates;};
    env = mkEnvironment {inherit rust channel;};
    welcome = mkWelcome {inherit pkgs tools;};
  in {
    __meta = {
      kind = "rust";
      inherit channel rust templates tools welcome pkgs;
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

  mkAiSpec = {
    lib,
    pkgs,
  }: let
    inherit (lib.packages) mkOpenClaw mkLLM;

    claw = mkOpenClaw {inherit pkgs;};
    llm = mkLLM {inherit pkgs lib;};
  in {
    __meta = {
      kind = "ai";
      inherit claw llm pkgs;
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

  mkCombinedSpec = {
    lib,
    pkgs,
    mkTools,
    mkEnvironment,
    mkTemplates,
    mkWelcome,
    channel ? "nightly",
  }: let
    inherit (lib.shells) mergeShellSpecs;

    base =
      mergeShellSpecs
      (final.shells.mkRustSpec {
        inherit lib pkgs mkTools mkEnvironment mkTemplates mkWelcome channel;
      })
      (final.shells.mkAiSpec {
        inherit lib pkgs;
      });
  in
    mergeShellSpecs base {
      __meta.kind = "combined";
      __meta.sources = ["rust.${channel}" "ai"];

      shell = {
        name = "full-${channel}";
        packages = [];
        env = {};
        shellHook = "";
      };
    };
}
