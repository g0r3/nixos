{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ferdium
  ];

  systemd.user.services.ferdium = {
    description = "Start Ferdium after graphical login";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.ferdium}/bin/ferdium %U";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}