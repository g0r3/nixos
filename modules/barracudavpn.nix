{
  config,
  lib,
  pkgs,
  isNixos,
  isDarwin,
  ...
}:

let
  cfg = config.modules.barracudavpn;
  interactiveShellInit = ''
    vpnstart() {
      sudo ${pkgs.barracudavpn}/bin/barracudavpn --verbose --start --login rstaudacher@barracuda.com  --serverpwd $(kwallet-query -r password kdewallet -f "LDAP")
    }
    vpnstop() {
      sudo ${pkgs.barracudavpn}/bin/barracudavpn --verbose --stop
    }
  '';
in
{
  options.modules.barracudavpn.enable = lib.mkEnableOption "Whether to enable the Barracudavpn module";

  config = lib.mkIf cfg.enable ({
    nixpkgs.overlays = [
      (final: prev: {
        barracudavpn = final.callPackage ../packages/barracudavpn/default.nix { };
      })
    ];
    environment.systemPackages = [ pkgs.barracudavpn ];
    environment.interactiveShellInit = interactiveShellInit;
    environment.etc."barracudavpn/barracudavpn.conf".source =
      "${pkgs.barracudavpn}/config/barracudavpn.conf";
    systemd.tmpfiles.rules = [
      "d /etc/barracudavpn/ca 0755 root root -"
    ];
    security.sudo.extraRules = [
      {
        users = [ "rstaudacher" ];
        commands = [
          {
            command = "${pkgs.barracudavpn}/bin/barracudavpn";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  });
}
