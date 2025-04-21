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
        imgBuilder = pkgs.callPackage ./nix/imgBuilder.nix;
        images = pkgs.lib.attrsets.mergeAttrsList (
          builtins.map (x: {${x.id} = imgBuilder x;}) (import ./nix/imgList.nix)
        );
      in
        pkgs.lib.recursiveUpdate images {
          # ^ recursive update to let us call .#"<imgID>" directly
          default = pkgs.callPackage ./nix/all.nix {inherit imgBuilder;};
          getAttrsScript = pkgs.callPackage ./nix/getAttrsScript.nix {};

          # illustrates how you can crop images (maybe make this a function?)
          cropper = let 
              image = images."7472531";
            in pkgs.runCommandLocal "croped-${image.name}" {} ''
            ${pkgs.imagemagick}/bin/magick ${image} -crop 3280x1845+0+1800 - > $out
          '';
        }
    );
  };
}
