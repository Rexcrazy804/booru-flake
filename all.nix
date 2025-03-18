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

  # what is driving me to do this? no clue
  ListFlattener = category: let 
    fullcat = "tag_string_${category}";
  in lib.lists.flatten (builtins.map (img: lib.splitString " " img.__metadata.${fullcat}) imgList);

  characterList = ListFlattener "character";
  artistList = ListFlattener "artist";
  copyrightList = ListFlattener "copyright";

  # to explain this fuckery to myself in the future first the final output of
  # this is list of character folders with links to each img from the img list
  # that contains any character from the characterList where characterList is
  # is an overall flattened list of every character found in the imgList honest
  # this would have been so much easier to understand if we had pipe operator
  # out of experimental
  # could make this a function but fuck it
  characterFolders =
    builtins.map (character: rec {
      name = character;
      path = let
        filter = img: builtins.elem character (lib.splitString " " img.__metadata.tag_string_character);
      in
        pkgs.linkFarm name (builtins.filter filter imgList);
    })
    characterList;
  artistFolders =
    builtins.map (artist: rec {
      name = artist;
      path = let
        filter = img: builtins.elem artist (lib.splitString " " img.__metadata.tag_string_artist);
      in
        pkgs.linkFarm name (builtins.filter filter imgList);
    })
    artistList;
  copyrightFolders =
    builtins.map (copyright: rec {
      name = copyright;
      path = let
        filter = img: builtins.elem copyright (lib.splitString " " img.__metadata.tag_string_copyright);
      in
        pkgs.linkFarm name (builtins.filter filter imgList);
    })
    copyrightList;
in
  pkgs.linkFarm "Danbooru" [
    {
      name = "artists";
      path = pkgs.linkFarm "artists" artistFolders;
    }
    {
      name = "characters";
      path = pkgs.linkFarm "characters" characterFolders;
    }
    {
      name = "copyrights";
      path = pkgs.linkFarm "characters" copyrightFolders;
    }
  ]
