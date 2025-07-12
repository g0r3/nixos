# nixos/desktop/user.nix
{ pkgs, ... }:

{

  imports = [
  ../../dotfiles/zsh/default.nix
];

  # Define users
  users.users = {
    reinhard = {
      isNormalUser = true;
      description = "Reinhard Staudacher";
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
      # OMIT HASHED PASSWORD! Set it on first boot or use sops-nix.
    };
    root = {
      # OMIT HASHED PASSWORD!
      shell = pkgs.zsh;
    };
  };


}
