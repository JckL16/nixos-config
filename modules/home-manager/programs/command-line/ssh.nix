{ lib, ... }: {
  services.ssh-agent.enable = true;

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
      "gitea.direct.arpa" = {
        # git-over-SSH doesn't go through Caddy -- git.jckl.site only ever
        # resolves to the Caddy host, which doesn't forward port 22.
        # gitea.direct.arpa resolves straight to gitea itself instead (see
        # homelab/nixos/hosts/gitea/deploy.nix's directDomain).
        HostName = "gitea.direct.arpa";
        User = "gitea";
        IdentityFile = "~/.ssh/gitea";
        IdentitiesOnly = true;
      };
      "*" = {
        IdentitiesOnly = true;
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
