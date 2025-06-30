{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf;
  inherit (lib.types) listOf submodule strMatching package nullOr attrsOf str;

  imgBuilder = pkgs.callPackage ./imgBuilder.nix;
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
  filtterAttr = {
    list = mkOption {
      type = listOf str;
      default = [];
      description = "list of tags to filter in the final imageFolder";
    };
    invert = mkEnableOption "inverts the behavior of the filter";
  };
  cfg = config.programs.booru-flake;
in {
  options.programs.booru-flake = {
    enable = mkEnableOption "Enable booru-flake";
    prefetcher.enable = mkEnableOption "Enable booru-flake prefetch script";

    # leaving this as img to empahsis that this is not a readOnly
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

    filters = {
      characters = filtterAttr;
      artists = filtterAttr;
      copyrights = filtterAttr;
      # see all.nix for valid ratings
      previews.ratings = filtterAttr;
    };

    images = mkOption {
      readOnly = true;
      type = nullOr (attrsOf package);
      default =
        if cfg.enable
        then
          pkgs.lib.attrsets.mergeAttrsList (
            builtins.map (x: {${x.id} = imgBuilder x;}) cfg.imgList
          )
        else null;
      description = "Attrset containing id as attrName and imgPackage as attrValue ideal for selecting individual images by id";
    };

    imageFolder = mkOption {
      type = nullOr package;
      readOnly = true;
      default =
        if cfg.enable
        then
          pkgs.callPackage ./all.nix {
            inherit imgBuilder;
            imgList' = cfg.imgList;
            filters = cfg.filters;
          }
        else null;
      description = "The folder containing all the images categorized neatly";
    };
  };

  config = mkIf cfg.prefetcher.enable {
    environment.systemPackages = [
      (pkgs.callPackage ./getAttrsScript.nix {})
    ];
  };
}
