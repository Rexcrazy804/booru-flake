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

  getCategoryList = category: let
    # this basically takes an image and returns a list of its tag_string_{$category} metadata
    # i.e say you have image.metadata.tag_string_character = "lisa_(genshin_impact) barbara_(genshin_impact)"
    # this function will convert it into ["lisa_(genshin_impact)" "barbara_(genshin_impact)"]
    imgCategories = img: lib.splitString " " img.__metadata.${"tag_string_${category}"};
  in
    lib.pipe imgList [
      (builtins.map imgCategories)
      (lib.lists.flatten)
      (lib.lists.unique)
    ];

  # to explain this fuckery to myself in the future first the final output of
  # this is list of character folders with links to each img from the img list
  # that contains any character from the characterList where characterList is
  # is an overall flattened list of every character found in the imgList honest
  # this would have been so much easier to understand if we had pipe operator
  # out of experimental
  # could make this a function but fuck it
  getCategoryFolders = category:
    builtins.map (element: rec {
      name = element;
      path = let
        filter = img: builtins.elem element (lib.splitString " " img.__metadata.${"tag_string_${category}"});
      in
        pkgs.linkFarm name (builtins.filter filter imgList);
    }) (getCategoryList category);
in
  pkgs.linkFarm "Danbooru" (builtins.map (category: rec {
    name = "${category}s";
    path = pkgs.linkFarm name (getCategoryFolders category);
  }) ["artist" "character" "copyright"])
