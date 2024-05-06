{
  pkgs,
  nodejs,
  ...
}:
pkgs.mkYarnPackage rec {
  pname = "angular-language-server";
  version = "17.3.2";

  src = ./.;
  inherit nodejs;

  nativeBuildInputs = with pkgs; [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r $node_modules $out
    cp $src/index.js $out/bin/${pname}-unwrapped
    chmod a+x $out/bin/${pname}-unwrapped

    makeWrapper $out/bin/${pname}-unwrapped $out/bin/${pname} \
      --add-flags "--ngProbeLocations $out/node_modules --tsProbeLocations $out/node-modules"

    runHook postInstall
  '';

  dontFixup = true;
  doDist = false;
}
