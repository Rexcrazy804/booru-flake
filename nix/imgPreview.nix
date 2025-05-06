{
  writeText,
  lib,
  imgList,
}: let
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
  filteredIds = [ 6351551  6983927 9044041];
  filteredImgs = builtins.filter (img: !(builtins.elem img.metadata.id filteredIds)) imgList;
in
  writeText "preview.md" /*markdown*/ ''
    # Image previews by [booru-flake](github.com/Rexcrazy804/booru-flake)
    | Column 1 | Column 2 | Column 3 | Column 4 |
    |----------|----------|----------|----------|
    ${imgListToTable {list = filteredImgs;}}
  ''
