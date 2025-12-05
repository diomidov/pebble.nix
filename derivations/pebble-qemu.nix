{
  stdenv,
  lib,
  fetchFromGitHub,
  autoconf,
  automake,
  bison,
  darwin,
  flex,
  glib,
  libtool,
  perl,
  pixman,
  pkg-config,
  python2,
  SDL2,
  zlib,
}:

let
  darwinDeps = lib.optionals stdenv.isDarwin (
    with darwin.apple_sdk.frameworks;
    with darwin.stubs;
    [
      CoreAudio
      IOKit
      rez
      setfile
    ]
  );
in
stdenv.mkDerivation {
  name = "pebble-qemu";
  version = "2.5.0-pebble6";

  src = fetchFromGitHub {
    owner = "coredevices";
    repo = "qemu";
    rev = "606b793bbb79fa4105dc2be6a8d43939bb2d342e";
    hash = "sha256-9HlnlT0gIzAf7/M9D47JK7GKhYM1EMVKPGkbVBZIhZ4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoconf
    automake
    bison
    flex
    libtool
    perl
    pkg-config
    python2
  ];

  buildInputs = [
    glib
    pixman
    SDL2
    zlib
  ] ++ darwinDeps;

  configureFlags = [
    "--with-coroutine=gthread"
    "--disable-werror"
    "--disable-mouse"
    "--disable-vnc"
    "--disable-cocoa"
    "--enable-debug"
    "--enable-sdl"
    "--with-sdlabi=2.0"
    "--target-list=arm-softmmu"
    "--extra-cflags=-DSTM32_UART_NO_BAUD_DELAY"
    "--extra-ldflags=-g"
  ];

  postInstall = ''
    mv $out/bin/qemu-system-arm $out/bin/qemu-pebble
  '';

  meta = with lib; {
    homepage = "https://github.com/pebble/qemu";
    description = "Fork of QEMU with support for Pebble devices";
    license = licenses.gpl2Plus;
    mainProgram = "qemu-pebble";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
