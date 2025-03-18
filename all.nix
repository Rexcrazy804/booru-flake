{
  self,
  pkgs,
}: let
  parser = {name, ...}: let
    imgSet = self.packages.${pkgs.system}.${name};
  in {
    name = imgSet.package.filename;
    path = imgSet.image;
    __metadata = imgSet.package.metadata;
  };
  mainlist = builtins.attrValues (import ./imgList.nix parser);
  characterList =
    builtins.map (x: rec {
      name = x.__metadata.character;
      path = let
        filter = attrs: (attrs.__metadata.character == name);
      in
        pkgs.linkFarm name (builtins.filter filter mainlist);
    })
    mainlist;

  ArtistList =
    builtins.map (x: rec {
      name = x.__metadata.artist;
      path = let
        filter = attrs: (attrs.__metadata.artist == name);
      in
        pkgs.linkFarm name (builtins.filter filter mainlist);
    })
    mainlist;
in
  pkgs.linkFarm "Danbooru" [
    {
      name = "artists";
      path = pkgs.linkFarm "artists" ArtistList;
    }
    {
      name = "characters";
      path = pkgs.linkFarm "characters" characterList;
    }
  ]
