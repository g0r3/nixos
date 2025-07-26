# nixos/desktop/user.nix
{ pkgs, ... }:

{
  # Define users
  users.users = {
    reinhard = {
      isNormalUser = true;
      description = "Reinhard Staudacher";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
    };
    root = {
      shell = pkgs.zsh;
    };
  };


}
