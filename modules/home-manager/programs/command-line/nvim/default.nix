# modules/home-manager/programs/command-line/nvim/default.nix

{ pkgs, lib, config, ... }:

{
  options = {
    nvim.enable = lib.mkEnableOption "Enable nvim home-manager configuration";
  };

  config = lib.mkIf config.nvim.enable {
    programs.neovim = {
      enable = true;
      
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      
      extraPackages = import ./lsp-servers.nix { inherit pkgs; };
      
      plugins = import ./plugins.nix { inherit pkgs; };

      initLua = ''
        ${builtins.readFile ./config/utils.lua}
        ${builtins.readFile ./config/options.lua}
        ${builtins.readFile ./config/ui.lua}
        ${builtins.readFile ./config/lsp.lua}
        ${builtins.readFile ./config/completion.lua}
        ${builtins.readFile ./config/keymaps.lua}
      '';
    };
  };
}
