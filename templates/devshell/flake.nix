{
  description = "Project dev shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
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

        shellHook = ''
          echo "Entered dev shell for $(basename $PWD)"
        '';
      };
    };
}
