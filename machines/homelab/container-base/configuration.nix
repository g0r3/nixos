{
  config,
  pkgs,
  modulesPath,
  lib,
  ...
}:

{
  imports = [
    # This module contains the logic to use the IP address set in Proxmox UI
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  # Enable the Proxmox-specific network management
  proxmoxLXC.manageNetwork = true;

  # Explicitly enable DHCP on eth0
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  # Optimize for container usage
  boot.isContainer = true;

  # COMPATIBILITY: Create /bin/bash to allow "pct exec" to work
  system.activationScripts.binbash = {
    deps = [ ];
    text = ''
      mkdir -m 0755 -p /bin
      ln -sfn ${pkgs.bash}/bin/bash /bin/bash
      ln -sfn ${pkgs.bash}/bin/bash /bin/sh
    '';
  };

  # Standard Root setup
  users.users.root = {
    initialHashedPassword = ""; # Empty password for console access
    openssh.authorizedKeys.keys = [
      # Optional: Add your SSH key here for instant access
    ];
  };

  # User Configuration: 'nixos' with passwordless sudo
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable sudo
    initialHashedPassword = ""; # Empty password initially
    openssh.authorizedKeys.keys = [
      # Add your SSH key here
    ];
  };

  # Passwordless sudo for the "wheel" group
  security.sudo.wheelNeedsPassword = false;

  # Automatic Login for user 'nixos'
  services.getty.autologinUser = "nixos";

  # Allow login with empty password (optional, for console convenience)
  security.pam.services.sshd.allowNullPassword = true;
  security.pam.services.login.allowNullPassword = true;

  # Enable SSH so you can access it remotely
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  system.stateVersion = "25.11";
}
