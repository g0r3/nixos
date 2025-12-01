{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
  libfprint-tod,
  openssl_1_1
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libfprint-2-tod1-broadcom-cv3plus";
  version = "6.3.299-6.3.040.0";

  src = fetchzip {
    url = "http://dell.archive.canonical.com/updates/pool/public/libf/${finalAttrs.pname}/${finalAttrs.pname}_${finalAttrs.version}.orig.tar.gz";
    hash = "sha256-q+EYW7Vmnn3OQ6OXXPEyGsrlJlsNmaIR3fO3xJMwuEY=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libfprint-tod
    openssl_1_1 # Use the older OpenSSL version
  ];

  installPhase = ''
    runHook preInstall

    # Install driver .so file
    install -D -m 644 -t $out/lib/libfprint-2/tod-1/ usr/lib/x86_64-linux-gnu/libfprint-2/tod-1/libfprint-2-tod-1-broadcom-cv3plus.so

    # Install udev rules
    install -D -m 644 -t $out/lib/udev/rules.d/ lib/udev/rules.d/60-libfprint-2-device-broadcom-cv3plus.rules

    # Install firmware files
    install -d $out/firmware
    cp -r var/lib/fprint/.broadcomCv3plusFW/* $out/firmware/

    runHook postInstall
  '';

  passthru = {
    # This is used by the services.fprintd.tod NixOS module
    driverPath = "/lib/libfprint-2/tod-1";
    # We'll use this to easily access the firmware path in our configuration
    firmwarePath = "/firmware";
  };

  meta = with lib; {
    description = "Broadcom driver module for fprintd-tod Touch OEM Driver (from Dell)";
    homepage = "http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-broadcom/";
    license = licenses.unfree;
    maintainers = with maintainers; [ rstaudacher ]; # Assuming you are the maintainer now
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
})