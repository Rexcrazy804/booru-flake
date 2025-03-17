{
  self,
  pkgs,
}: let 
  parser = {name, ...}: let 
    package = self.packages.${pkgs.system}.${name};
  in {
    name = package.package.filename;
    path = package.image;
  };
  mainlist = builtins.attrValues (import ./imgList.nix parser);
  kokomi = let 
    filter = attrs: null != (builtins.match ".*\(kokomi\).*" attrs.name);
  in pkgs.linkFarm "Kokomi" (builtins.filter filter mainlist);
in pkgs.linkFarm "Danbooru" [
    {
      name = "kokomi";
      path = kokomi;
    }
]
