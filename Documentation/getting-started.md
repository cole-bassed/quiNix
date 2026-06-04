# Getting Started

## Requirements

You should have:

- Nix installed
- flakes enabled if you plan to use the flake entrypoint

## Common commands

### Inspect outputs

```bash
nix flake show
```

### Enter the development shell

```bash
nix develop
```

### Run checks

```bash
nix flake check
```

## Consuming quiNix as an input

```nix
{
  inputs.quiNix.url = "github:cole-bassed/quiNix";

  outputs = { self, nixpkgs, quiNix, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      qlib = import quiNix { inherit (pkgs) lib; };
    in {
      # use qlib
    };
}
```

## Local layout

Important directories:

- `libraries/`
- `environment/`
- `templates/`
- `Documentation/`

## Next reading

- [Architecture](./architecture.md)
- [Roadmap](./roadmap.md)
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md)
