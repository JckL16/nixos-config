# modules/home-manager/programs/steam.nix

{ pkgs, lib, config, ... }: {

  options = {
    nvim.enable = 
      lib.mkEnableOption "Enable nvim home-manager configuration";
  };

  config = lib.mkIf config.nvim.enable {
    programs.neovim = {
      enable = true;
      extraConfig = ''
        set number relativenumber
      '';
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        vim-nix
        nerdtree
        vim-airline
        vim-fugitive
        coc-nvim
      ];
    };

    environment.variables.EDITOR = "nvim";
  };
}