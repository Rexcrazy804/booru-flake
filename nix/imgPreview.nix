{
  writeText,
  lib,
  imgList,
  filters,
}: let
  inherit (lib) pipe filter elem xor;
  inherit (filters) ratings ids;

  imgListToTable = {
    list,
    output ? [],
  }:
    if builtins.length list > 0
    then let
      firstFour = lib.lists.take 4 list;
      output' = lib.pipe firstFour [
        (builtins.map (img: let met = img.metadata; in "[![${img.name}](${met.preview_file_url})](${met.file_url})"))
        (builtins.concatStringsSep " | ")
        (x: "| ${x} |")
      ];
    in
      imgListToTable {
        list = lib.lists.drop 4 list;
        output = output ++ [output'];
      }
    else (builtins.concatStringsSep "\n" output);

  # list of images that are too sus for the previews
  filteredImgs = pipe imgList [
    (filter (list: xor (!ratings.invert) (elem list.metadata.rating ratings.list)))
    (filter (list: xor (!ids.invert) (elem list.metadata.id ids.list)))
  ];
in
  writeText "preview.md"
  /*
  markdown
  */
  ''
    # Image previews
    | Column 1 | Column 2 | Column 3 | Column 4 |
    |----------|----------|----------|----------|
    ${imgListToTable {list = filteredImgs;}}
  ''
