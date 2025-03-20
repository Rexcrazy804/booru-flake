{
  self,
  pkgs,
}: let
  inherit (pkgs) lib system;
  parser = {id, ...}: let
    package = self.packages.${system}.${id};
  in {
    name = package.name;
    path = package;
    __metadata = package.metadata;
  };
  imgList = builtins.attrValues (import ./newImgList.nix parser);
  imgListLen = lib.lists.length imgList;

  genList = {
    charlist ? {},
    artistlist ? {},
    copyrightlist ? {},
    index ? 0,
  }: let
    image = builtins.elemAt imgList index;
    catList = category: lib.splitString " " image.__metadata.${"tag_string_${category}"};
    imageCharList = catList "character";
    imageArtistList = catList "artist";
    imageCopyrightList = catList "copyright";

    mapElem = origlist: elem: {
      ${elem} = let
        oldList = lib.optionals (builtins.hasAttr elem origlist) origlist.${elem};
      in
        [image] ++ oldList;
    };

    getNewlist = origlist: list: lib.attrsets.mergeAttrsList (builtins.map (mapElem origlist) list);
    # prevents build failure when original characters have not character_tag
    charlist' = lib.optionalAttrs (imageCharList != [""]) (getNewlist charlist imageCharList);
    artistlist' = getNewlist artistlist imageArtistList;
    copyrightlist' = getNewlist copyrightlist imageCopyrightList;
  in
    if index < imgListLen
    then
      genList {
        charlist = charlist // charlist';
        artistlist = artistlist // artistlist';
        copyrightlist = copyrightlist // copyrightlist';
        index = index + 1;
      }
    else {inherit charlist artistlist copyrightlist;};

  finalList = genList {};
  farmMap = builtins.mapAttrs (key: value: {
    name = key;
    path = pkgs.linkFarm key value;
  });
  characterFolders = builtins.attrValues (farmMap finalList.charlist);
  artistFolders = builtins.attrValues (farmMap finalList.artistlist);
  copyrightFolders = builtins.attrValues (farmMap finalList.copyrightlist);

  favArtists = ["elodeas" "yoneyama_mai"];
  danbooru = {
    characters = characterFolders;
    artists = builtins.filter (artist: builtins.elem artist.name favArtists) artistFolders;
    copyrights = copyrightFolders;
  };
in
  pkgs.linkFarm "Danbooru" (builtins.attrValues (farmMap danbooru))
