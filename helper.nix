pkgs: {
  name ? "booru_image",
  url,
  hash,
  cropString ? null,
}:
pkgs.stdenv.mkDerivation (final: {
  inherit name;
  src = pkgs.fetchurl {
    inherit url hash;
  };
  dontUnpack = true;
  nativeBuildInputs = [pkgs.imagemagick];
  installPhase = let
    cropCommand = "magick $src -crop ${cropString} ${"cropped${final.src.name}"}";
  in ''
    mkdir $out
    cd $out
    ${pkgs.lib.optionalString (cropString != null) cropCommand}
    cp $src ./${final.src.name}
  '';
  passthru = {
    image = final.src;
    filename = final.src.name;
    croppedFilename = "cropped${final.src.name}";
  };
})
