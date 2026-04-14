{
  description = "AI + Rust Development Environment";

  outputs = inputs @ {self, ...}:
    (import ./modules {inherit inputs;}).mkOutputs;

  inputs = {
    NixPackages.url = "github:NixOS/nixpkgs/nixos-unstable";
    Rust = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "NixPackages";
    };
    OpenClaw = {
      url = "github:Scout-DJ/openclaw-nix";
      inputs.nixpkgs.follows = "NixPackages";
    };
    #? nixpkgs.follows intentionally omitted — see modules/packages/llm.nix
    AIAgents.url = "github:numtide/llm-agents.nix";
  };
}
