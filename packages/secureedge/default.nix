{
  lib,
  stdenv,
  fetchurl,
  binutils-unwrapped,
  unzip,
  autoPatchelfHook,
  makeShellWrapper,
  wrapGAppsHook3,
  # Runtime dependencies
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libayatana-appindicator,
  libdbusmenu,
  libgbm,
  libGL,
  libglvnd,
  libnotify,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libxtst,
  xdg-utils,
  systemdLibs,
  libva,
  wayland,
  pipewire,
  libpulseaudio,
  tpm2-openssl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "secureedge";
  version = "3.0.1-6";

  src = fetchurl {
    url = "http://d.barracuda.com/SEA/SecureEdgeAgent_${finalAttrs.version}_Linux.zip";
    sha256 = "sha256-jJjmTeY5G4gX+/JlvytPw5bp3/ceW2oxPY17/lgdVUk=";
  };

  libPath = lib.makeLibraryPath [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libayatana-appindicator
    libdbusmenu
    libgbm
    libGL
    libglvnd
    libnotify
    libxkbcommon
    mesa
    nspr
    nss
    pango
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxtst
    systemdLibs
    libva
    wayland
    pipewire
    libpulseaudio
    stdenv.cc.cc.lib
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    binutils-unwrapped
    makeShellWrapper
    unzip
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libGL
    libnotify
    libxkbcommon
    mesa
    nspr
    nss
    pango
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxtst
  ];

  runtimeDependencies = [
    libayatana-appindicator
    libdbusmenu
    systemdLibs
  ];

  dontWrapGApps = true;
  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    unzip "$src"
    ar -x secureedge_${finalAttrs.version}_amd64.deb
    tar xf data.tar.*
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/secureedge"
    cp -r opt/secureedge/* "$out/lib/secureedge/"

    # Replace the bundled scripts/systemctl stub with a wrapper that
    # delegates to the real systemctl.  The original stub only checks a
    # PID file and knows nothing about systemd, so is-active queries
    # always fail — which triggers the native watchdog after 60 s.
    #
    # For "is-active secureedge-tunnel.service": always return active.
    # The tunnel exits immediately when not enrolled ("No point of entry
    # configured"), but the watchdog still expects it to be running —
    # creating a chicken-and-egg during initial enrollment.
    cat > "$out/lib/secureedge/scripts/systemctl" <<'WRAPPER'
    #!/bin/sh
    for arg in "$@"; do
      case "$arg" in secureedge-tunnel*)
        for a in "$@"; do
          if [ "$a" = "is-active" ]; then
            echo "active"
            exit 0
          fi
        done
      ;; esac
    done
    exec systemctl "$@"
    WRAPPER
    chmod +x "$out/lib/secureedge/scripts/systemctl"

    # Desktop entry
    mkdir -p "$out/share/applications"
    substitute usr/share/applications/secureedge.desktop "$out/share/applications/secureedge.desktop" \
      --replace-fail "/opt/secureedge/secureedge" "$out/bin/secureedge" \
      --replace-fail "Icon=secureedge" "Icon=$out/share/icons/hicolor/256x256/apps/secureedge.png"

    # Icons
    mkdir -p "$out/share/icons"
    cp -r usr/share/icons/* "$out/share/icons/"

    # TPM2 OpenSSL provider
    ln -s "${tpm2-openssl}/lib/ossl-modules/tpm2.so" "$out/lib/secureedge/tpm2.so"

    runHook postInstall
  '';

  postFixup = ''
    # Main GUI binary — wrapped with GTK/library paths and Chromium flags
    mkdir -p "$out/bin"
    wrapProgramShell "$out/lib/secureedge/secureedge" \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${finalAttrs.libPath}:$out/lib/secureedge" \
      --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
      --add-flags "--no-sandbox"

    ln -s "$out/lib/secureedge/secureedge" "$out/bin/secureedge"

    # Helper binaries (used by systemd services) — only need glibc
    ln -s "$out/lib/secureedge/secureedge-interface" "$out/bin/secureedge-interface"
    ln -s "$out/lib/secureedge/secureedge-tunnel" "$out/bin/secureedge-tunnel"
  '';

  meta = {
    description = "Barracuda SecureEdge Agent — VPN and ZTNA client";
    homepage = "https://www.barracuda.com/products/network-security/secureedge";
    license = lib.licenses.free; # Mark it as free for convenience
    platforms = [ "x86_64-linux" ];
    mainProgram = "secureedge";
  };
})
