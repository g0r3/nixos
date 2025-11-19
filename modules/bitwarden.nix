{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
  ];

  systemd.user.services.bitwarden = {
    description = "Start Bitwarden after graphical login";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Environment = [ "GTK_USE_PORTAL=0" ];
      ExecStart = "${pkgs.bitwarden-desktop}/bin/bitwarden";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
