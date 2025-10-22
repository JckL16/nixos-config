# modules/nixos/users.nix

{ pkgs, variables, ... }: {

  users.users."${variables.username}" = {
    isNormalUser = true;
    description = variables.description;
    extraGroups = [ "networkmanager" "wheel" "input" "video" ];
    packages = with pkgs; [
      firefox
    ];
    shell = pkgs.zsh;
  };

  environment.variables.EDITOR = "nvim";

  programs.zsh.enable = true;

}