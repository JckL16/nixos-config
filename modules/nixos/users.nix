{ pkgs, variables, ... }: {

  users.users."${variables.username}" = {
    isNormalUser = true;
    description = variables.description;
    extraGroups = [ "wheel" "dialout" ];
    packages = [];
    shell = pkgs.zsh;

    initialPassword = "nixos";
  };

}
