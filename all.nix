{
  pkgs,
  lib,
  fetchBooruImage,
}: let
  imgList = builtins.map (x: fetchBooruImage x) (import ./newImgList.nix);
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

  writePreview = let
    listfn = {
      list,
      takeCount ? 4,
      output ? [],
    }:
      if builtins.length list > 0
      then let
        firstFour = lib.lists.take takeCount list;
        output' = lib.pipe firstFour [
          (builtins.map (img: let
            met = img.metadata;
          in "![${img.name}](${met.preview_file_url})<br>[${img.name}](${met.file_url})"))
          (builtins.concatStringsSep " | ")
          (x: "| ${x} |")
        ];
      in
        listfn {
          list = lib.lists.drop takeCount list;
          output = output ++ [output'];
        }
      else (builtins.concatStringsSep "\n" output);
  in
    pkgs.writeText "preview.md" ''
      # Preview of all images per character
      | Column 1 | Column 2 | Column 3 | Column 4 |
      |---------|---------|---------|---------|
      ${listfn {list = imgList;}}
    '';

  copyrightFolders = builtins.attrValues (farmMap categoryMaps.copyrightMap);
  characterFolders = builtins.attrValues (farmMap categoryMaps.characterMap);
  artistFolders = let
    favArtists = ["elodeas" "yoneyama_mai" "void_0"];
    filter' = list: builtins.filter (set: builtins.elem set.name favArtists) list;
  in
    filter' (builtins.attrValues (farmMap categoryMaps.artistMap));
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
