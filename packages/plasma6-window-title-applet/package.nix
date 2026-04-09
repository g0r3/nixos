{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  kdePackages,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "plasma6-window-title-applet";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "dhruv8sh";
    repo = "plasma6-window-title-applet";
    rev = "9dd66da8c22f7d77e4ce3608f45c34ed81035b48";
    hash = "sha256-jdoa2dz+7VgwQsbfjqOSfZfV3KOwHC+lSLzg3e1vSSs=";
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
    homepage = "https://github.com/dhruv8sh/plasma6-window-title-applet";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ "Rstaudacher" ];
    inherit (kdePackages.kwindowsystem.meta) platforms;
  };
})
