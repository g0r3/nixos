# nixos/desktop/user.nix
{ pkgs, ... }:

{
  # Define users
  users.users = {
    reinhard = {
      isNormalUser = true;
      description = "Reinhard Staudacher";
      extraGroups = [ "audio" "networkmanager" "wheel" "scanner" "lp" ];
      shell = pkgs.zsh;
    };
    root = {
      shell = pkgs.zsh;
    };
  };


}
