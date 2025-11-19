{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  kdePackages,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "windows-title-applet";
  version = "0.7.1-3";

  src = fetchFromGitHub {
    owner = "dhruv8sh";
    repo = "plasma6-window-title-applet";
    rev = "a6eaf5086a473919ed2fffc5d3b8d98237c2dd41";
    hash = "sha256-pFXVySorHq5EpgsBz01vZQ0sLAy2UrF4VADMjyz2YLs=";
  };

  propagatedUserEnvPkgs = with kdePackages; [ kconfig ];

  dontWrapQtApps = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids/org.kde.windowtitle
    cp -r ./* $out/share/plasma/plasmoids/org.kde.windowtitle
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "KDE Plasma6 applet that shows the current window title and icon in your panels";
    homepage = "https://github.com/psifidotos/applet-window-title";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ "Rstaudacher" ];
    inherit (kdePackages.kwindowsystem.meta) platforms;
  };
})
