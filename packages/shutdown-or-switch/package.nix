{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  kdePackages,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "shutdown-or-switch";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "Davide-sd";
    repo = "shutdown_or_switch";
    rev = "ee2e597337d69930c97c63ef83b1ee096ec4fa99";
    hash = "sha256-Q/rahjtryiXvzzwkjQiwL4cPTCfuYdjp6q4QkodrhZI=";
  };

  propagatedUserEnvPkgs = with kdePackages; [ kconfig ];

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids/org.kde.plasma.shutdownorswitch
    cp -r package/* $out/share/plasma/plasmoids/org.kde.plasma.shutdownorswitch
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "KDE Plasma6 widget for easy access to the leave options";
    homepage = "https://github.com/Davide-sd/shutdown_or_switch";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ "Rstaudacher" ];
    inherit (kdePackages.kwindowsystem.meta) platforms;
  };
})
