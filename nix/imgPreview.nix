{
  writeText,
  lib,
  imgList,
  sfwonly ? true,
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
  filteredImgs = if sfwonly then builtins.filter (img: img.metadata.rating == "g") imgList else imgList;
in
  writeText "preview.md" /*markdown*/ ''
    # Image previews
    | Column 1 | Column 2 | Column 3 | Column 4 |
    |----------|----------|----------|----------|
    ${imgListToTable {list = filteredImgs;}}
  ''
