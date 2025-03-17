pkgs: {
  name ? "booru_image",
  url,
  hash,
  cropString ? null,
}: rec {
  package = pkgs.stdenv.mkDerivation (final: {
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
      filename = final.src.name;
      croppedFilename = "cropped${final.src.name}";
    };
  });
  image = "${package}/${package.filename}";
  croppedImage = pkgs.lib.optionalString (cropString != null) "${package}/${package.croppedFilename}";
}
