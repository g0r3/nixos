{ stdenv, lib, fetchurl, binutils-unwrapped, autoPatchelfHook, zstd, version ? "5.3.5" }:
let
  urls = [
    "http://10.17.6.4/repo/Barracuda%20VPN%20Client/Linux/${version}/VPNClient_${version}_Linux.tar.gz"
    "http://10.17.6.4/repo/Barracuda%20VPN%20Client/linux/${version}/VPNClient_${version}_Linux.tar.gz"
    "http://10.17.6.4/repo/vpn-client/Linux/${version}/VPNClient_${version}_Linux.tar.gz"
    "http://10.17.6.4/repo/vpn-client/linux/${version}/VPNClient_${version}_Linux.tar.gz"
  ];
  hack = ./bcvpn-hack-post535.sh;
  hack-pre = ./bcvpn-hack-pre535.sh;

  downloads = {
    # If you change any of the hashes below, MAKE SURE THE NEW VERSIONS ARE SECURE!
    "5.3.5" = { sha256 = "JMs5qgqWfI4HmUWnGJdFiOejS8aCDbZ5wn/prLPhwJg="; inherit urls hack; };  # released, latest
    "5.3.5-2024-06-13" = {
      inherit hack;
      urls = [
        "http://10.17.6.4/repo/vpn-client/linux/5.3.5/2024-06-13/barracudavpn_5.3.5_amd64.deb"
      ];
      sha256 = "sha256-vJf/LKo9V+XEjlXTI73HklAhEPoIXq+ttxbJDFHaY1U=";
    };
    "5.2.2" =    { sha256 = "1bp47179rvs2ahv02f0hna210n886bg7bj8x68qclkk3xj39hici"; inherit urls hack-pre; }; # released
    "5.1.5rc1" = { sha256 = "0gdn8rw0r9d4vb0vwy9ylwmbqd6zdaafgjfhx7l3b3ngy1syz56n"; inherit urls hack-pre; };
    "5.1.4" =    { sha256 = "00qwq3ma5whfws9i2z205q48j8z9i3vgbvaqgx6rvcbip6ld14zy"; inherit urls hack-pre; }; # released
  };

  download = downloads.${version};

  # vpnfile = fetchurl { inherit (download) urls sha256; };
  vpnfile = builtins.trace
    ''...
      If this fails to download the client:
      Outside the office network, you can try downloading the Linux VPN client from
          https://dlportal.barracudanetworks.com"/#/search?page=1&search=Linux&type=6
      and add it to the nix store maually:
          nix-store --add-fixed sha256 VPNClient_${version}_Linux.tar.gz
      If the hashes match with those here, everything should work.
    ''
    (fetchurl { inherit (download) urls sha256; })
  ;
in
stdenv.mkDerivation {
  inherit version;
  pname = "barracudavpn";

  src = null;

  nativeBuildInputs = [ binutils-unwrapped autoPatchelfHook zstd ];

  unpackPhase = ''
    tar xf "${vpnfile}" || cp "${vpnfile}" ./
    ar -x *.deb || true
    tar xf data.tar.*
    cp ${download.hack} bcvpn-hack
    patchShebangs bcvpn-hack
  '';

  installPhase = ''
    mkdir -p "$out/bin" "$out/config"
    cp usr/local/bin/barracudavpn "$out/bin/barracudavpn"
    cp ${./barracudavpn.conf} "$out/config/barracudavpn.conf"
    substituteInPlace bcvpn-hack \
      --replace 'sudo barracudavpn' "sudo $out/bin/barracudavpn" \
      --replace ' barracudavpn.conf ' " $out/config/barracudavpn.conf "
    install -Dm755 bcvpn-hack $out/bin/bcvpn-hack
  '';

  doCheckInstall = true;
  checkInstallPhase = ''$out/bin/barracudavpn --help >/dev/null'';

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
}

