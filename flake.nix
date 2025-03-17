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
    packages = forAllSystems (pkgs: let
      helper = import ./helper.nix pkgs;
    in {
      kokomi_kuqfh = helper {
        name = "kokomi_kuqfh";
        url = "https://cdn.donmai.us/original/63/08/__sangonomiya_kokomi_genshin_impact_drawn_by_kuqfh__63081368093489e52faa973b6384a125.jpg";
        hash = "sha256-U18rCuKNSTKPLPl5tzDDhudJYWU2nVOgLRwTlDHCJJ4=";
        cropString = "1920x1080+300+300";
      };
    });
  };
}

# ORIGINAL STRING
# __sangonomiya_kokomi_genshin_impact_drawn_by_kuqfh__63081368093489e52faa973b6384a125.jpg
# REGEXED String
# character = sangonomiya_kokomi_genshin_impact
# artist = kuqfh
# id = 63081368093489e52faa973b6384a125
# filetype = jpg
# REGEX
# s/__\(.\{-}\)_drawn_by_\(.\{-}\)__\(.\{-}\)\.\(.*\)/character = \1\r# artist = \2\r# id = \3\r# filetype = \4
