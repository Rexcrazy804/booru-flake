{
  lib,
  fetchurl,
  id ? throw "Image id is required",
  jsonHash ? "",
  imgHash ? "",
}: let
  # some attributes of the full json change
  # so this selects only that which do not change
  filter = builtins.concatStringsSep "," [
    "id"
    "created_at"
    "uploader_id"
    "source"
    "md5"
    "image_width"
    "image_height"
    "tag_string"
    "file_ext"
    "file_size"
    "pixiv_id"
    "tag_string_general"
    "tag_string_character"
    "tag_string_copyright"
    "tag_string_artist"
    "tag_string_meta"
    "file_url"
    "large_file_url"
    "preview_file_url"
  ];
  rawjsonResponse = fetchurl {
    name = "${id}.json";
    url = "https://danbooru.donmai.us/posts/${id}.json?only=${filter}";
    hash = jsonHash;
  };
  jsonResponse = lib.importJSON rawjsonResponse;
in
  fetchurl {
    name = "${builtins.toString jsonResponse.id}.${jsonResponse.file_ext}";
    url = jsonResponse.file_url;
    hash = imgHash;

    passthru = {
      # refer to danbooru's api for json spec
      metadata = jsonResponse;
      raw_metadata = rawjsonResponse;
    };
  }
