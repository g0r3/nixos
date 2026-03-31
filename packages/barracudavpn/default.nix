{
  stdenvNoCC,
  lib,
  fetchurl,
  binutils-unwrapped,
  autoPatchelfHook,
  makeWrapper,
  iproute2,
  kmod,
  zstd,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "barracudavpn";
  version = "5.3.6";

  src = fetchurl {
    url = "http://d.barracuda.com/VPN/Linux/VPNClient_5.3.6_Linux.tar.gz";
    sha256 = "sha256-vshbIpfuWIvzyC6OlFJF65dVvL9J0q9o64V7LmGHVpk=";
  };

  nativeBuildInputs = [
    binutils-unwrapped
    autoPatchelfHook
    makeWrapper
    zstd
  ];

  unpackPhase = ''
    tar xf "''${src}" || cp "''${src}" ./
    ar -x *.deb || true
    tar xf data.tar.*
  '';

  installPhase = ''
    mkdir -p "$out/bin" "$out/config"
    cp usr/local/bin/barracudavpn "$out/bin/barracudavpn"
    cat > "$out/config/barracudavpn.conf" <<'EOF'
     BINDIP =
     CERTFILE =
     DYNSSA = 2
     HANDSHAKETIMEOUT = 200
     KEEPALIVE = 20
     KEYFILE =
     PROXYADDR =
     PROXYPORT = 8080
     PROXYTYPE = NO PROXY
     PROXYUSER =
     #SERVER = vpn.cuda-inc.com                                                                                                     
     #SERVER = vix.vpn.cuda-inc.com
     SERVER = vpn.barracuda.eu
     SERVERPORT = 691
     SPECIAL = NONE
     TAP = /dev/net/tun
     TUNNELENC = AES256-SHA
     TUNNELMODE = TCP
     TUNNELREKEY = 20
     WRITEDNS = MERGE

     .
    EOF
    wrapProgram "$out/bin/barracudavpn" \
      --prefix PATH : "${
        lib.makeBinPath [
          iproute2
          kmod
        ]
      }"
  '';

  doCheckInstall = true;
  checkInstallPhase = "$out/bin/barracudavpn --help >/dev/null";

  meta = {
    description = "Barracuda VPN Client for Linux";
    longDescription = ''
      After the switch to Azure Entra-ID, if the client suddenly starts to ask for a OTP:
        1. Open the MFA App (e.g. MS Authenticator) and go the "Barracuda Networks, Inc." profile.
        2. Select "Enable phone sign-in"
        3. Follow the configuration steps, you can click "Skip" the one that wants to scan the QR-Code
      The Authenticator should now prompt you with VPN approval request instead of failing because of missing OTPs.
    '';
    homepage = "https://folsom.ngdev.eu.ad.cuda-inc.com/projects/MISC/repos/ux-vpnclients/";
    license = lib.licenses.free; # unfree really, but we want it easy
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.confus ];
  };
})
