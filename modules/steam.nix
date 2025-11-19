{ pkgs, ... }:

let
  # This SHA256 seems different from the one we settled on. If the fix below
  # doesn't work, consider changing it back to:
  # sha256 = "15v7d1wq2mmvy735773k7jg2x873y0jbrrj6g401r0hjr3z7p4g3";
  pkgs-fixed =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/5b09dc45f24cf32316283e62aec81ffee3c3e376.tar.gz";
        sha256 = "09nmwsahc0zsylyk5vf6i62x4jfvwq4r2mk8j0lmr3zzk723dwj3";
      })
      {
        config.allowUnfree = true;
        system = pkgs.system;
      };

  steam-with-fixed-drivers = pkgs.steam.override {
    extraPkgs =
      p:
      (with pkgs-fixed; [
        mesa
        vulkan-loader
        pkgsi686Linux.mesa
        pkgsi686Linux.vulkan-loader
      ])
      ++ (with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        xorg.libSM
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ]);
  };

in
{
  nixpkgs.config.allowUnfree = true;

  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      # FIX 1: Tell the steam module to use your custom package.
      package = steam-with-fixed-drivers;
      gamescopeSession.enable = true;
    };
  };

  services.displayManager.gdm.wayland = true;
  systemd.user.services.steam = {
    description = "Start Steam after graphical login";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      # FIX 2: Make the systemd service launch your custom package.
      ExecStart = "${steam-with-fixed-drivers}/bin/steam -nochatui -nofriendsui -silent %U";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
