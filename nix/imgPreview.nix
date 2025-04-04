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
in
  writeText "preview.md" /*markdown*/ ''
    # Preview of all images
    | Column 1 | Column 2 | Column 3 | Column 4 |
    |---------|---------|---------|---------|
    ${imgListToTable {list = imgList;}}
  ''
