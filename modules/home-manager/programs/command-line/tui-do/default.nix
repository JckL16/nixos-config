{ pkgs, lib, config, ... }:

let
  cfg = config.programs.tui-do;

  tui-do = pkgs.rustPlatform.buildRustPackage {
    pname = "tui-do";
    version = "1.0.2";

    src = pkgs.fetchFromGitHub {
      owner = "sjwasko";
      repo = "tui-do";
      rev = "v1.0.2";
      hash = "sha256-Gij4I/21yDiZ1VADCYtmk66H0ZJ6Js1Cb2VPO216Nvo=";
    };

    cargoLock.lockFile = ./Cargo.lock;

    # Only the tui-do binary crate; xtask/tui-do-smoke are dev-only workspace members.
    cargoBuildFlags = [ "-p" "tui-do" ];

    # tui-do-api's client-builder unit tests need a system CA store, which the Nix
    # build sandbox doesn't provide; the built binary itself is unaffected at runtime.
    doCheck = false;

    nativeBuildInputs = [ pkgs.installShellFiles ];

    postInstall = ''
      installShellCompletion --cmd tui-do --zsh <($out/bin/tui-do completions zsh)
    '';

    meta = {
      description = "Fast, local-first TUI for Vikunja";
      homepage = "https://github.com/sjwasko/tui-do";
      license = with lib.licenses; [ mit asl20 ];
      mainProgram = "tui-do";
      platforms = lib.platforms.unix;
    };
  };
in {
  options.programs.tui-do.enable = lib.mkEnableOption "tui-do, a local-first TUI for Vikunja";

  config = lib.mkIf cfg.enable {
    home.packages = [ tui-do ];
  };
}
