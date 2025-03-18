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

                let jsonHash = nix hash convert --hash-algo sha256 --to sri (nix-prefetch-url $jsonUrl)
                let imgHash = nix hash convert --hash-algo sha256 --to sri (nix-prefetch-url $imgUrl)

                print $'"($id)" = helper {'
                print $'  id = "($id)";'
                print $'  jsonHash = "($jsonHash)";'
                print $'  imgHash = "($imgHash)";'
                print $'};' # just for the sake of it lol
              }
            }
          '';

          # you have to override this package with id, jsonHash, and imgHash
          fetchBooruImage = new_helper {};
        }
    );
  };
}
