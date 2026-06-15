# modules/home-manager/programs/command-line/ssh.nix

{ lib, ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/github_jckl16";
        IdentitiesOnly = true;
      };
      "*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        Compression = true;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/control/%r@%h:%p";
        ControlPersist = "10m";
      };
    };
  };

  home.activation.createSshControlDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.ssh/control"
    chmod 700 "$HOME/.ssh/control"
  '';
}
