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
        helper = import ./helper.nix pkgs;
      in
        pkgs.lib.recursiveUpdate (import ./imgList.nix helper) {
          default = import ./all.nix {
              inherit self pkgs;
          };

          getAttrsScript = pkgs.writers.writeNuBin "get_image_expression" /*nu*/ ''
          # A nushell script for automating the required attrset format in
          # imgList.nix from any given number of urls
          def main [...urls: string] {
            for $url in $urls {
              let meta = $url | parse --regex '__(.*)_drawn_by_(.*)__(.*)\.(.*)'
              print $'"($meta.capture2.0)" = helper {'
              print $'  name = "($meta.capture2.0)";'
              print $'  url = "($url)";'
              print $'  hash = "";'
              print $'};' # just for the sake of it lol
            }
          }
          '';
        }
    );
  };
}
