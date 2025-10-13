{ config, pkgs, ... }:

{
  programs.neofetch = {
    enable = true;
    
    settings = {
      print_info = ''
        info title
        info underline
        info "OS" distro
        info "Kernel" kernel
        info "Shell" shell
        info "Terminal" term
        info "Memory" memory
      '';
    };
  };
}