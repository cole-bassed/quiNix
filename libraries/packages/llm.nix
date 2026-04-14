/**
libraries/packages/llm.nix

Exports LLM agent package selectors and command helpers.
*/
final: prev: {
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
