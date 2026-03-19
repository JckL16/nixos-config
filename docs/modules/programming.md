# Programming Environments

These are user-level modules set in `home.nix`. Each provides a complete development environment with compilers, tools, and LSP support for Neovim.

## Python

- **Option:** `python-dev.enable = true;`

Installs:
- Python 3 with pip, setuptools, wheel, virtualenv
- Poetry (dependency management)
- Pipenv (virtual environment manager)
- Pyright (LSP server)

Additional Python packages can be specified:

```nix
python-dev.enable = true;
python-dev.packages = [ "requests" "numpy" "pandas" ];
```

Sets `PYTHONDONTWRITEBYTECODE=1`.

## Rust

- **Option:** `rust.enable = true;`

Installs:
- rustc (compiler)
- cargo (package manager)
- rustfmt (formatter)
- clippy (linter)
- rust-analyzer (LSP server)
- gcc (for linking)

Adds `~/.cargo/bin` to `PATH`.

## C/C++

- **Option:** `c-cpp.enable = true;`

Installs:
- Compilers: gcc
- Build tools: cmake, ninja, meson, autoconf, automake, gnumake, pkg-config
- Debug tools: gdb, valgrind, lldb, strace
- LSP: clangd (via clang-tools)
- Libraries: Boost, fmt, spdlog, Catch2, Google Test

## Go

- **Option:** `go.enable = true;`

Installs:
- go (compiler)
- gopls (LSP server)
- golangci-lint (linter)
- delve (debugger)
- gotools (additional tools)

Sets `GOPATH=$HOME/go` and adds `~/go/bin` to `PATH`.

## Example Configuration

```nix
# home.nix
python-dev.enable = true;
python-dev.packages = [ "flask" "sqlalchemy" ];
rust.enable = true;
c-cpp.enable = true;
go.enable = true;
```

## LSP Integration

All programming environments include LSP servers that integrate with Neovim. The Neovim configuration auto-detects installed LSP servers:

| Language | LSP Server |
|----------|------------|
| Python | pyright |
| Rust | rust-analyzer |
| C/C++ | clangd |
| Go | gopls |
| Nix | nixd |
| Lua | lua_ls |
| TypeScript/JavaScript | ts_ls |
| Bash | bashls |
| JSON | jsonls |
| YAML | yamlls |
