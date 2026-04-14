/**
modules/libraries/packages/rust.nix

Exports Rust package builders and helpers.
*/
{
  /**
  Select a Rust toolchain from rust-overlay (already applied via pkgs).
  Includes rust-src, rust-analyzer, rustfmt, clippy, and wasm32 target.

  # Signature
  { pkgs, channel ? "nightly" } -> { channel, toolchain, environment }
  */
  mkRust = {
    pkgs,
    channel ? "nightly",
  }: let
    components = {
      extensions = [
        "rust-src"
        "rust-analyzer"
        "rustfmt"
        "clippy"
      ];
      targets = ["wasm32-unknown-unknown"];
    };

    toolchains = with pkgs.rust-bin; {
      nightly = selectLatestNightlyWith (t: t.default.override components);
      beta = beta.latest.default.override components;
      stable = stable.latest.default.override components;
    };

    toolchain = toolchains.${channel};

    environment = {
      RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
      RUST_CHANNEL = channel;
      RUST_BACKTRACE = "full";
      RUST_LOG = "info";
      CARGO_INCREMENTAL = "1";
    };
  in {
    inherit channel toolchain environment;
  };
}
