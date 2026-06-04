# Contributing to quiNix

Thanks for your interest in contributing to quiNix.

## Principles

Please keep contributions aligned with the direction of this repository:

- prefer small, composable Nix building blocks
- keep naming and structure consistent
- favor readable, modular organization over cleverness
- preserve a practical developer experience
- document behavior when adding or changing public library surfaces

## Before you open a change

1. Check existing docs in `Documentation/`
2. Keep the scope focused
3. If changing public behavior, update docs in the same change
4. If adding a new namespace or pattern, keep it wired into the project consistently

## Development workflow

Typical local checks:

```bash
nix flake show
nix flake check
```

If you change shell behavior, template behavior, or library assembly, verify those paths directly as well.

## Style expectations

- use clear attrset-oriented Nix structure
- prefer modular folder-based organization
- avoid unnecessary churn in naming or layout
- keep comments useful and short
- update documentation when behavior changes

## Pull requests

Good pull requests usually include:

- a clear summary of the change
- the motivation or problem being solved
- any follow-up work still needed
- documentation updates where appropriate

## Licensing

By contributing to quiNix, you agree that your contributions may be distributed under the project's dual-license terms:

- MIT
- Apache-2.0

If that does not work for you, please do not submit code or documentation changes.
