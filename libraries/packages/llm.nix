/**
libraries/packages/llm.nix

LLM-agent package selectors and command helpers for lib.packages.
*/
final: prev: {
  /**
  Build a normalized view of installed LLM agent tooling.

  Returns package lists, binary paths, shell command aliases, and the standard
  API-key environment contract expected by the AI shell.

  # Type
  ```nix
  mkLLM :: {
    pkgs :: AttrSet;
    lib :: AttrSet;
  } -> {
    packages :: [derivation];
    bin :: AttrSet;
    cmd :: AttrSet;
    env :: AttrSet;
  }
  ```

  # Examples
  ```nix
  mkLLM { inherit pkgs lib; }
  # => {
  #   packages = [ ... ];
  #   bin.codex = "/nix/store/.../bin/codex";
  #   cmd.cx = "/nix/store/.../bin/codex";
  #   env.OPENAI_API_KEY = "$OPENAI_API_KEY";
  # }
  ```

  # Returns
  A normalized tool description containing package derivations, binary paths,
  shell command aliases, and expected API-key environment variables.
  */
  mkLLM = {
    pkgs,
    lib,
  }: let
    inherit (lib.attrsets) attrValues mapAttrs' nameValuePair;

    agents = pkgs.llm-agents;
    packages = attrValues agents;

    bin =
      mapAttrs'
      (_: drv: let
        mainProgram = drv.meta.mainProgram or drv.pname or drv.name;
      in
        nameValuePair mainProgram "${drv}/bin/${mainProgram}")
      agents;

    cmd =
      bin
      // {
        cc = bin.claude;
        cc-auto = "${bin.claude} --dangerously-skip-permissions";
        cx = bin.codex;
        cx-full = "${bin.codex} --full-auto";
        gm = bin.gemini;
        oc = bin.opencode;
      };

    env = {
      ANTHROPIC_API_KEY = "$ANTHROPIC_API_KEY";
      OPENAI_API_KEY = "$OPENAI_API_KEY";
      GEMINI_API_KEY = "$GEMINI_API_KEY";
      CODEX_UNSAFE_ALLOW_NO_SANDBOX = "0";
    };
  in {
    inherit packages bin cmd env;
  };
}
