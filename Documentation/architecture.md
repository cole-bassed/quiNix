# Architecture

quiNix is structured as a reusable Nix foundation with a small number of clear entrypoints.

## Entry points

### `flake.nix`

Defines the repository as a flake and delegates outputs to `default.nix`.

### `default.nix`

Acts as the main assembly point for:

- project paths
- library loading
- package construction
- dev shell export when flake inputs are available

## Library assembly

The main library entrypoint is `libraries/default.nix`.

It bootstraps `assembly.nix` first, then loads namespaces in dependency order:

1. `trivial`
2. `filesystem`
3. `attrsets`
4. `strings`
5. `packages`
6. `shells`

This ordering allows later namespaces to build on earlier ones.

## Environment layer

`environment/default.nix` defines development shells using `lib.shells.mkShells`.

This is the place to expand shared shell behavior for project and team workflows.

## Templates layer

`templates/default.nix` manages reusable scaffold files and deployment logic for downstream projects.

This gives quiNix a second role:

- reusable library for Nix code
- reusable project bootstrap support for new repositories

## Design direction

The design emphasis is:

- composability
- predictable structure
- reusable abstractions
- maintainable project setup
