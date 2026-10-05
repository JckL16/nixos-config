# Project Dev Shells

Scaffold a blank per-project `flake.nix` dev shell, instead of writing one from scratch each time.

The template only depends on `nixpkgs` and installs nothing by default — it's a starting point with commented-out examples for C/C++, Python, Rust, and LaTeX. Add whatever packages the project actually needs.

## Usage

From inside a project directory:

```bash
new-devshell
```

This is a shell function (`zsh.nix`) that:

1. Runs `noglob nix flake init -t ~/nixos-config#devshell`, copying `templates/devshell/flake.nix` and `templates/devshell/.envrc` into the current directory (the `noglob` prefix is needed because this repo's zsh config sets `EXTENDED_GLOB`, which otherwise treats the `#devshell` in the flake ref as a glob pattern)
2. Runs `direnv allow`, which loads the shell automatically via `use flake` whenever you `cd` into the project
3. Creates `.gitignore` if it doesn't exist, or appends to it if it does — either way ensuring it contains `.direnv/`, `result`, and `result-*` without duplicating lines already present

## Adding packages

Open the generated `flake.nix` and uncomment or add to `buildInputs`:

```nix
buildInputs = [
  # C/C++
  # pkgs.gcc
  # pkgs.gnumake
  # pkgs.cmake
  # pkgs.gdb

  # Python (with extra packages)
  # (pkgs.python3.withPackages (ps: with ps; [
  #   requests
  #   numpy
  # ]))

  # Rust
  # pkgs.rustc
  # pkgs.cargo
  # pkgs.rustfmt
  # pkgs.clippy
  # pkgs.rust-analyzer

  # LaTeX
  # (pkgs.texlive.combine {
  #   inherit (pkgs.texlive) scheme-medium titlesec enumitem microtype;
  # })
  # pkgs.zathura
];
```

These are just starting examples — add any other `nixpkgs` package the same way.
