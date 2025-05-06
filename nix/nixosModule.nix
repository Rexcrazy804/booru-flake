{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption;
  inherit (lib.types) listOf submodule strMatching package nullOr;

  imgAttr = submodule {
    options = {
      id = mkOption {
        type = strMatching "[0-9]+";
        default = "";
        description = "The id of the image passed to the api";
      };
      jsonHash = mkOption {
        type = strMatching "sha256-.*=";
        default = "";
        description = "The hash of the json response from the api";
      };
      imgHash = mkOption {
        type = strMatching "sha256-.*=";
        default = "";
        description = "The hash of the image fetched from the api";
      };
    };
  };
  cfg = config.booru;
in {
  options.booru = {
    enable = mkEnableOption "Enable booru-flake";
    prefetcher.enable = mkEnableOption "Enable booru-flake prefetch script";

    imgList = mkOption {
      type = listOf imgAttr;
      default = [];
      example = [
        {
          id = "7452256";
          jsonHash = "sha256-T+NzB5md5SheEOQIFuth0AgMUhSK9kikneQkM6w4XhQ=";
          imgHash = "sha256-U18rCuKNSTKPLPl5tzDDhudJYWU2nVOgLRwTlDHCJJ4=";
        }
      ];
      description = "A list of imgIds with their hashes";
    };

    allFolder = mkOption {
      type = nullOr package;
      readOnly = true;
      default =
        if cfg.enable
        then
          pkgs.callPackage ./all.nix {
            imgBuilder = pkgs.callPackage ./imgBuilder.nix;
            imgList' = cfg.imgList;
          }
        else null;
    };
  };
}
