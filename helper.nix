pkgs: {
  name,
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
      metadata = let 
        metaList = builtins.match "__(.*)_drawn_by_(.*)__(.*)\\.(.*)" final.src.name;
      in {
        character = builtins.elemAt metaList 0;
        artist = builtins.elemAt metaList 1;
        id = builtins.elemAt metaList 2;
        filetype = builtins.elemAt metaList 3;
      };
    };
  });
  image = "${package}/${package.filename}";
  croppedImage = pkgs.lib.optionalString (cropString != null) "${package}/${package.croppedFilename}";
}
