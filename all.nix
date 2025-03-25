{
  self,
  pkgs,
}: let
  inherit (pkgs) lib system;
  parser = {id, ...}: self.packages.${system}.${id};
  # A list of all images
  imgList = builtins.attrValues (import ./newImgList.nix parser);
  imgListLen = lib.lists.length imgList;

  # CharacterMap (and others) follow the following format
  # "<characterName>" = [<list of imgs containing $characterName>]
  generateMaps = {
    characterMap ? {},
    artistMap ? {},
    copyrightMap ? {},
    index ? 0,
  } @ maps: let
    inherit (lib) splitString;
    inherit (lib.attrsets) foldAttrs;
    image = let
      package = builtins.elemAt imgList index;
      # takes say a list of characters and returns a list of AttrSets like so:
      # [{<character1>=[package];} {<character2>=[package];}]
      makeMap = list: (builtins.map (elem: {${elem} = [package];}) list);
    in {
      characters = makeMap (splitString " " package.metadata.tag_string_character);
      artists = makeMap (splitString " " package.metadata.tag_string_artist);
      copyrights = makeMap (splitString " " package.metadata.tag_string_copyright);
    };

    fold' = foldAttrs (item: acc: item ++ acc) [];
  in
    if index < imgListLen
    then
      generateMaps {
        characterMap = fold' (image.characters ++ [characterMap]);
        artistMap = fold' (image.artists ++ [artistMap]);
        copyrightMap = fold' (image.copyrights ++ [copyrightMap]);
        index = index + 1;
      }
    else maps;

  categoryMaps = generateMaps {};
  farmMap = builtins.mapAttrs (key: value: {
    name = if key == "" then "unknown" else key;
    path = pkgs.linkFarmFromDrvs key value;
  });

  copyrightFolders = builtins.attrValues (farmMap categoryMaps.copyrightMap);
  characterFolders = builtins.attrValues (farmMap categoryMaps.characterMap);
  artistFolders = let
    favArtists = ["elodeas" "yoneyama_mai"];
    filter = list: builtins.filter (set: builtins.elem set.name favArtists) list;
  in
    filter (builtins.attrValues (farmMap categoryMaps.artistMap));
  # needa link this inplace to avoid getting gc'd and rebuilding everything
  JsonFolder = pkgs.linkFarmFromDrvs "jsons" (builtins.map (img: img.raw_metadata) imgList);
in
  pkgs.linkFarm "Danbooru" [
    {
      name = "Artists";
      path = pkgs.linkFarm "Artists" artistFolders;
    }
    {
      name = "Characters";
      path = pkgs.linkFarm "Characters" characterFolders;
    }
    {
      name = "Copyrights";
      path = pkgs.linkFarm "Copyrights" copyrightFolders;
    }
    {
      name = "Jsons";
      path = JsonFolder;
    }
  ]
