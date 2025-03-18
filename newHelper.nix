{
  lib,
  fetchurl,
  id ? throw "Image id is required",
  jsonHash ? "",
  imgHash ? "",
}: let
  jsonResponse = lib.importJSON (fetchurl {
    url = "https://danbooru.donmai.us/posts/${id}.json";
    hash = jsonHash;
  });
in
  fetchurl {
    url = jsonResponse.file_url;
    hash = imgHash;

    passthru = {
      # refer to danbooru's api for json spec
      metadata = jsonResponse;
    };
  }
