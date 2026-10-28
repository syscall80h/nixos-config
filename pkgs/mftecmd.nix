{
  lib,
  stdenvNoCC,
  fetchzip,
  makeWrapper,
  dotnetCorePackages,
}:

# MFTECmd (Eric Zimmerman), build .NET 10
  stdenvNoCC.mkDerivation {
  pname = "mftecmd";
  version = "2026.10.6";

  src = fetchzip {
    url = "https://download.ericzimmermanstools.com/net/MFTECmd.zip";
    stripRoot = false;
    hash = "sha256-thQiE+wi6MV+5tg1hoNwfv4AeL8yCxMNDFdjd6T/ryI=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/mftecmd $out/bin
    cp -r ./* $out/lib/mftecmd/
    dll=$(find $out/lib/mftecmd -name MFTECmd.dll | head -n1)
    if [ -z "$dll" ]; then
      echo "MFTECmd.dll not found in the archive:" >&2
      find $out/lib/mftecmd >&2
      exit 1
    fi
    makeWrapper ${dotnetCorePackages.runtime_10_0}/bin/dotnet $out/bin/MFTECmd \
      --add-flags "$dll"
    runHook postInstall
  '';

  meta = {
    description = "MFT and USN journal parser";
    homepage = "https://ericzimmerman.github.io/";
    mainProgram = "MFTECmd";
    platforms = lib.platforms.linux;
  };
}
