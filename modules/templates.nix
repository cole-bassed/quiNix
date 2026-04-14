# nix/templates.nix
# Returns an attrset of writeText derivations used as config file templates.
{ pkgs }:

let inherit (pkgs) writeText; in {

  cargo = writeText "cargo-config.toml" ''
    [alias]
    b  = "build"
    br = "build --release"
    c  = "check"
    cl = "clippy"
    t  = "test"
    r  = "run"
    rr = "run --release"
    w  = "watch -x check"
    wr = "watch -x run"

    [build]
    jobs = 4

    [term]
    color = "always"
  '';

  envrc = writeText ".envrc" ''
    use flake
  '';

  gitignore = writeText ".gitignore" ''
    #~@ Rust
    target/
    Cargo.lock
    **/*.rs.bk
    *.pdb

    #~@ Coverage
    coverage/
    *.profraw
    tarpaulin-report.html

    #~@ Environment
    .direnv
    .env
    !.env.example

    #~@ Editor
    .helix/
    .idea/
    .vscode/
    *.swp
    *.swo
    *~

    #~@ OS
    .DS_Store
    Thumbs.db
  '';

  markdownlint = writeText ".markdownlint-cli2.yaml" ''
    config:
      default: true
      MD013:
        line_length: 100
      MD033: false
      MD041: false
    fix: true
  '';

  mise = writeText "mise.toml" ''
    [tasks.dev]
    description = "Run in watch mode"
    run = "bacon"

    [tasks.test]
    description = "Run tests"
    run = "cargo nextest run"

    [tasks.coverage]
    description = "Generate coverage report"
    run = "cargo tarpaulin --out Html --output-dir coverage"

    [tasks.bench]
    description = "Run benchmarks"
    run = "cargo bench"

    [tasks.fmt]
    description = "Format all files"
    run = "treefmt"

    [tasks.check]
    description = "Format and clippy"
    run = "treefmt && cargo clippy"

    [tasks.audit]
    description = "Security audit"
    run = "cargo audit"

    [tasks.info]
    description = "Show project info"
    run = "onefetch"

    [tasks.git]
    description = "Open gitui"
    run = "gitui"
  '';

  treefmt = writeText "treefmt.toml" ''
    [global]
    excludes = [".direnv/**", "target/**"]

    [formatter.rust]
    command  = "rustfmt"
    options  = ["--edition", "2024"]
    includes = ["*.rs"]

    [formatter.toml]
    command  = "taplo"
    options  = ["format"]
    includes = ["*.toml"]

    [formatter.markdownlint]
    command  = "markdownlint"
    options  = ["--fix"]
    includes = ["*.md"]
    priority = 1

    [formatter.prettier]
    command  = "prettiest"
    options  = ["--write"]
    includes = ["*.md", "*.json"]
    priority = 2

    [formatter.yaml]
    command  = "yamlfmt"
    includes = ["*.yaml", "*.yml"]
  '';
}
