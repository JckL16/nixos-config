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

  programs.zsh.enable = true;

}