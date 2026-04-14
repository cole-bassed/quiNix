/**
modules/packages/default.nix

Constructs the unified package set with all overlays applied:
  - rust-overlay       → pkgs.rust-bin.*
  - openclaw overlay   → pkgs.openclaw
  - llm-agents overlay → pkgs.llm-agents.{ claude-code, codex, gemini-cli, ... }

Returns: { system } -> pkgs
*/
{inputs}: {system}:
import inputs.NixPackages {
  inherit system;
  overlays = with inputs; [
    (import Rust)
    OpenClaw.overlays.default
    AIAgents.overlays.default
  ];
  config.allowUnfree = true;
}
