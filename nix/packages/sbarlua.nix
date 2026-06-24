{
  fetchFromGitHub,
  lib,
  readline,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "sbarlua";
  version = "unstable-2026-03-05";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SbarLua";
    rev = "dba9cc421b868c918d5c23c408544a28aadf2f2f";
    hash = "sha256-lhLTrdufA3ALJ2S5HLdgNOr5seWIWEHkVhZNPObzbvI=";
  };

  buildInputs = [readline];

  buildPhase = ''
    runHook preBuild
    make bin/sketchybar.so CC=clang
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/lua
    install -m755 lua-5.5.0/src/lua $out/bin/lua
    install -m755 bin/sketchybar.so $out/lib/lua/sketchybar.so
    runHook postInstall
  '';

  meta = {
    description = "Lua IPC module for SketchyBar";
    homepage = "https://github.com/FelixKratz/SbarLua";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin;
  };
}
