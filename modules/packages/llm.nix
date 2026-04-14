/**
modules/packages/llm.nix

Selects LLM agent packages from pkgs.llm-agents after
AIAgents.overlays.default is applied in packages/default.nix.

# Available packages (numtide/llm-agents.nix):
  pkgs.llm-agents.claude-code
  pkgs.llm-agents.codex
  pkgs.llm-agents.gemini-cli
  pkgs.llm-agents.opencode
  pkgs.llm-agents.qwen-code

# Note:
nixpkgs.follows is intentionally omitted for AIAgents — following a
non-unstable branch breaks their packages and loses binary cache hits.

# Returns:
```nix
{ packages, bin, cmd, env }
```
*/
{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.attrsets) attrValues mapAttrs' nameValuePair;
  agents = pkgs.llm-agents;
  packages = attrValues agents;

  bin =
    mapAttrs'
    (_: drv:
      let
        mainProgram = drv.meta.mainProgram or drv.pname or drv.name;
      in
        nameValuePair mainProgram "${drv}/bin/${mainProgram}")
    agents;

  cmd = bin // {
    # Claude Code
    cc = bin.claude;
    cc-auto = "${bin.claude} --dangerously-skip-permissions";

    # Codex
    cx = bin.codex;
    cx-full = "${bin.codex} --full-auto";

    # Gemini CLI
    gm = bin.gemini;

    # OpenCode (TUI agent)
    oc = bin.opencode;
  };

  # API keys are read from the process environment — never baked into the store.
  # Export these in your shell profile, .env (via direnv), or a secrets manager.
  env = {
    ANTHROPIC_API_KEY = "$ANTHROPIC_API_KEY";
    OPENAI_API_KEY = "$OPENAI_API_KEY";
    GEMINI_API_KEY = "$GEMINI_API_KEY";

    # Codex requires bubblewrap on Linux for sandboxing.
    # Set to "1" only if bubblewrap is unavailable in your environment.
    CODEX_UNSAFE_ALLOW_NO_SANDBOX = "0";
  };
in {inherit packages bin cmd env;}
