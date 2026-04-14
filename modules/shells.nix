# modules/shells.nix
#
# Shell variants:
#   nix develop              → default (Rust nightly + AI)
#   nix develop .#rust       → Rust nightly only
#   nix develop .#stable     → Rust stable
#   nix develop .#beta       → Rust beta
#   nix develop .#ai         → AI tools only
#   nix develop .#full       → Rust nightly + AI (explicit)
{
  mkPkgs,
  mkRust,
  mkOpenClaw,
  mkLLM,
  mkTools,
  mkEnvironment,
  mkTemplates,
  mkWelcome,
}: {
  system,
  lib,
}: let
  inherit (lib.lists) optionals;

  pkgs = mkPkgs {inherit system;};
  inherit (pkgs) mkShell;

  mkRustShell = {
    channel ? "nightly",
    name ? "rust-${channel}",
  }: let
    rust = mkRust {inherit pkgs channel;};
    templates = mkTemplates {inherit pkgs;};
    tools = mkTools {inherit pkgs rust templates;};
    env = mkEnvironment {inherit rust channel;};
    welcome = mkWelcome {inherit pkgs tools;};
  in
    mkShell {
      inherit name;
      packages =
        tools.packages
        ++ optionals pkgs.stdenv.isDarwin (with pkgs; [libiconv]);
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

  mkAIShell = {name ? "ai-dev"}: let
    claw = mkOpenClaw {inherit pkgs;};
    llm = mkLLM {inherit pkgs;};
  in
    mkShell {
      inherit name;
      packages = [claw.package] ++ llm.packages;
      env = llm.env;
      shellHook = ''
        echo "🤖 AI Development Environment"
        echo "   Tools: openclaw, claude-code, codex, gemini-cli, opencode"
        echo "   Set ANTHROPIC_API_KEY / OPENAI_API_KEY / GEMINI_API_KEY as needed."
      '';
    };

  mkFullShell = {
    channel ? "nightly",
    name ? "full-${channel}",
  }: let
    rust = mkRust {inherit pkgs channel;};
    templates = mkTemplates {inherit pkgs;};
    tools = mkTools {inherit pkgs rust templates;};
    claw = mkOpenClaw {inherit pkgs;};
    llm = mkLLM {inherit pkgs;};
    env = mkEnvironment {
      inherit rust channel;
      aiEnv = llm.env;
    };
    welcome = mkWelcome {inherit pkgs tools;};
  in
    mkShell {
      inherit name;
      packages =
        tools.packages
        ++ [claw.package]
        ++ llm.packages
        ++ optionals pkgs.stdenv.isDarwin (with pkgs; [libiconv]);
      env = env;
      shellHook = ''
        ${tools.init}
        [ -n "$PRJ_HOME" ] || PRJ_HOME=$PWD
        [ -n "$PRJ_NAME" ] || PRJ_NAME=$(basename "$PRJ_HOME")
        RUST_VERSION=$(${tools.rustvv})
        export PRJ_HOME PRJ_NAME RUST_VERSION
        ${welcome}
        echo ""
        echo "🤖 AI tools: openclaw · claude-code · codex · gemini-cli · opencode"
      '';
    };
in {
  nightly = mkRustShell {channel = "nightly";};
  stable = mkRustShell {channel = "stable";};
  beta = mkRustShell {channel = "beta";};
  rust = mkRustShell {};
  ai = mkAIShell {};
  full = mkFullShell {};
  default = mkFullShell {};
}
