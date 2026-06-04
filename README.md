# quiNix

quiNix is the silent-`n` Nix toolkit and project foundation behind Cole-Bassed Solutions.

It packages a reusable Nix library, flake entrypoints, development-shell helpers, and project templates that make it easier to build consistent Rust, AI, and general development environments.

## Goals

- provide a clean, reusable Nix library surface
- make dev shell composition easier across projects
- support practical Rust and AI-oriented workflows
- keep project scaffolding simple and reproducible
- grow into a reliable foundation for Cole-Bassed Solutions projects

## What is in this repo

- `flake.nix` — flake entrypoint
- `default.nix` — non-flake/library entrypoint
- `libraries/` — reusable Nix library namespaces
- `environment/` — dev shell definitions
- `templates/` — bootstrap files for new projects
- `Documentation/` — project docs and contributor guidance

## Current library areas

- `trivial`
- `filesystem`
- `attrsets`
- `strings`
- `packages`
- `shells`

## Quick start

### Enter the default dev shell

```bash
nix develop
```

### Inspect flake outputs

```bash
nix flake show
```

### Run checks

```bash
nix flake check
```

### Load the library from Nix

```nix
let
  quiNix = import ./. {};
in
  quiNix.lib
```

### Use from another flake

```nix
{
  inputs.quiNix.url = "github:cole-bassed/quiNix";

  outputs = { self, nixpkgs, quiNix, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      qlib = import quiNix { inherit (pkgs) lib; };
    in {
      # use qlib here
    };
}
```

## Documentation

Start here:

- `Documentation/index.md`
- `Documentation/getting-started.md`
- `Documentation/architecture.md`
- `Documentation/roadmap.md`
- `CONTRIBUTING.md`

## License

This project is dual-licensed under:

- MIT — see `LICENSE-MIT`
- Apache-2.0 — see `LICENSE-APACHE`

You may use this project under either license.

## Contributing

Contributions are welcome. Please read `CONTRIBUTING.md` before opening larger changes.
