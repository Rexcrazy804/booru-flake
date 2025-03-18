{
  description = "A collection of Images from danbooru";

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
    # WARNING
    # you need to call {packagename}.package for building
    # otherwise you can just refer to package.image
    # or package.croppedImage for the paths

    packages = forAllSystems (
      pkgs: let
        new_helper = pkgs.callPackage ./newHelper.nix;
      in
        pkgs.lib.recursiveUpdate (import ./newImgList.nix new_helper) {
          default = import ./all.nix {
            inherit self pkgs;
          };

          getAttrsScript = pkgs.writers.writeNuBin "get_image_expression" /*nu*/ ''
            # A nushell script for automating the required attrset format in
            # imgList.nix from any given number of ids (easily pipe to wl-copy :)
            def main [...ids: string] {
              for $id in $ids {
                let jsonUrl = $"https://danbooru.donmai.us/posts/($id).json"
                let imgUrl = curl $jsonUrl | from json | get file_url

                let jsonHash = nix hash to-sri --type sha256 (nix-prefetch-url $jsonUrl)
                let imgHash = nix hash to-sri --type sha256 (nix-prefetch-url $imgUrl)

                print $'"($id)" = helper {'
                print $'  id = "($id)";'
                print $'  jsonHash = "($jsonHash)";'
                print $'  imgHash = "($imgHash)";'
                print $'};' # just for the sake of it lol
              }
            }
          '';
          # you have to override this package with id, jsonHash, and imgHash
          # passthru's metadata imported from the API response URL
          fetchBooruImage = new_helper {};
        }
    );
  };
}
