{
  self,
  pkgs,
}: let
  parser = {name, ...}: let
    package = self.packages.${pkgs.system}.${name};
  in {
    name = package.package.filename;
    path = package.image;
    __metadata = package.package.metadata;
  };
  mainlist = builtins.attrValues (import ./imgList.nix parser);
  kokomi = let
    filter = attrs: (attrs.__metadata.character == "sangonomiya_kokomi_genshin_impact");
  in
    pkgs.linkFarm "Kokomi" (builtins.filter filter mainlist);
in
  pkgs.linkFarm "Danbooru" [
    {
      name = "kokomi";
      path = kokomi;
    }
  ]
