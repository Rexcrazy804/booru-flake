{
  pkgs,
  lib,
  imgBuilder,
  imgList',
  filters ? {
    characters = {
      list = [];
      invert = false;
    };
    copyrights = {
      list = [];
      invert = false;
    };
    artists.list = ["elodeas" "yoneyama_mai" "void_0" "morncolour"];
    artists.invert = true;

    # valid ratings are "e"xplicit, "q"uestionable, "s"ensitive, "g"eneral
    previews.ratings = {
      list = ["g"];
      invert = true;
    };
  },
}: let
  imgList = builtins.map (x: imgBuilder x) imgList';
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
    package = builtins.elemAt imgList index;

    # takes say a list of characters and returns a list of AttrSets like so:
    # [{<character1>=[package];} {<character2>=[package];}]
    map' = list: (builtins.map (elem: {${elem} = [package];}) list);
    fold' = foldAttrs (item: acc: item ++ acc) [];

    image = {
      characters = map' (splitString " " package.metadata.tag_string_character);
      artists = map' (splitString " " package.metadata.tag_string_artist);
      copyrights = map' (splitString " " package.metadata.tag_string_copyright);
    };
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
    name =
      if key == ""
      then "unknown"
      else key;
    path = pkgs.linkFarmFromDrvs key value;
  });

  writePreview = pkgs.callPackage ./imgPreview.nix {
    inherit imgList;
    inherit (filters.previews) ratings;
  };

  characterFolders = let
    # conditionally inverts the filter functionality based on filter.*.invert
    # if you want more info fucking learn A xor B truth table
    filter' = builtins.filter (set: lib.xor (!filters.characters.invert) (builtins.elem set.name filters.characters.list));
    list = builtins.attrValues (farmMap categoryMaps.characterMap);
  in
    filter' list;
  copyrightFolders = let
    filter' = builtins.filter (set: lib.xor (!filters.copyrights.invert) (builtins.elem set.name filters.copyrights.list));
    list = builtins.attrValues (farmMap categoryMaps.copyrightMap);
  in
    filter' list;
  artistFolders = let
    filter' = builtins.filter (set: lib.xor (!filters.artists.invert) (builtins.elem set.name filters.artists.list));
    list = builtins.attrValues (farmMap categoryMaps.artistMap);
  in
    filter' list;

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
    {
      name = "preview.md";
      path = writePreview;
    }
  ]
