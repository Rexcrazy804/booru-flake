{
  description = "Rexiel Scarlet's collection of Images from danbooru";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (
        system:
          f (import nixpkgs {inherit system;})
      );
  in {
    # NOTE
    # you can refer to the images using packages.${system}."<image id>"
    # you can also get its metadata with packages.${system}."<image id>".metadata
    # it follows the danbooru api json spec
    packages = forAllSystems (
      pkgs: let
        new_helper = pkgs.callPackage ./newHelper.nix;
        images = pkgs.lib.attrsets.mergeAttrsList (
          builtins.map (x: {${x.id} = new_helper x;}) (import ./newImgList.nix)
        );
      in
        pkgs.lib.recursiveUpdate images ({
          default = pkgs.callPackage ./all.nix {
            fetchBooruImage = new_helper;
          };

          getAttrsScript = pkgs.writers.writeNuBin "get_image_expression" /* nu */ ''
            # A nushell script for automating the required attrset format in
            # imgList.nix from any given number of ids (easily pipe to wl-copy :)
            def main [...ids: string] {
              for $id in $ids {
                # we can't have the hash changing due to one comment being added now can we
                let only = "?only=id,created_at,uploader_id,source,md5,image_width,image_height,tag_string,file_ext,file_size,pixiv_id,tag_string_general,tag_string_character,tag_string_copyright,tag_string_artist,tag_string_meta,file_url,large_file_url,preview_file_url"
                let jsonUrl = $"https://danbooru.donmai.us/posts/($id).json($only)"
                let imgUrl = curl $jsonUrl | from json | get file_url

                let jsonHash = nix hash convert --hash-algo sha256 --to sri (nix-prefetch-url --name $"($id).json" $jsonUrl)
                let imgHash = nix hash convert --hash-algo sha256 --to sri (nix-prefetch-url  $imgUrl)

                print $'{'
                print $'  id = "($id)";'
                print $'  jsonHash = "($jsonHash)";'
                print $'  imgHash = "($imgHash)";'
                print $'}'
              }
            }
          '';
        })
    );
  };
}
