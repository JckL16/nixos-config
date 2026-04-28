# modules/home-manager/programs/command-line/ssh.nix

{ lib, ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
      compression = true;
      controlMaster = "auto";
      controlPath = "~/.ssh/control/%r@%h:%p";
      controlPersist = "10m";
    };
  };

  home.activation.createSshControlDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.ssh/control"
    chmod 700 "$HOME/.ssh/control"
  '';
}
