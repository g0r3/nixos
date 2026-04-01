{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.secureedge;
in
{
  options.modules.secureedge.enable = lib.mkEnableOption "Whether to enable the Barracuda SecureEdge Agent";

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        secureedge = final.callPackage ../packages/secureedge/default.nix { };
      })
    ];

    environment.systemPackages = [ pkgs.secureedge ];

    # The secureedge-tunnel binary needs a group for setgid
    users.groups.secureedge = { };

    # System service: secureedge-interface (tunnel controller)
    systemd.services.secureedge-interface = {
      description = "Barracuda SecureEdge Agent Tunnel Interface";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.secureedge}/bin/secureedge-interface -g secureedge";
        AmbientCapabilities = "CAP_NET_ADMIN";
        KillMode = "process";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # User service: secureedge-tunnel
    systemd.user.services.secureedge-tunnel = {
      description = "Barracuda SecureEdge Agent Tunnel";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.secureedge}/bin/secureedge-tunnel";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
