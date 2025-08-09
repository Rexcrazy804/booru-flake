{
  writeText,
  lib,
  imgList,
  filters,
}: let
  inherit (lib) map pipe filter elem xor concatStringsSep length;
  inherit (lib.lists) take drop;
  inherit (filters) ratings ids;

  imgListToTable = {
    list,
    output ? [],
  }:
    if length list > 0
    then let
      firstFour = take 4 list;
      output' = pipe firstFour [
        (map (img: let met = img.metadata; in "[![${img.name}](${met.preview_file_url})](${met.file_url})"))
        (concatStringsSep " | ")
        (x: "| ${x} |")
      ];
    in
      imgListToTable {
        list = drop 4 list;
        output = output ++ [output'];
      }
    else (concatStringsSep "\n" output);

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
