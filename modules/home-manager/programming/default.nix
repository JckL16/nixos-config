# modules/home-manager/programming/default.nix
{ ... }: {
  
  imports = [
    ./rust.nix
    ./c-cpp.nix
  ];

}