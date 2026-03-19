# modules/home-manager/programming/go.nix

{ pkgs, config, lib, ... }: {

  options = {
    go.enable =
      lib.mkEnableOption "Enable Go development environment";
  };

  config = lib.mkIf config.go.enable {
    home.packages = with pkgs; [
      go
      gopls
      golangci-lint
      delve
      (lib.lowPrio gotools)
    ];

    home.sessionPath = [
      "$HOME/go/bin"
    ];

    home.sessionVariables = {
      GOPATH = "$HOME/go";
    };
  };
}
