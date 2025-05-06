{
  pkgs,
  modulesPath,
  config,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  networking.hostName = "booru";
  system.stateVersion = "25.05";
  virtualisation = {
    graphics = false;
    diskSize = 2 * 1024;
    memorySize = 512;
    cores = 1;
  };

  users = {
    users.sango = {
      enable = true;
      initialPassword = "koko";
      createHome = true;
      isNormalUser = true;
      extraGroups = ["wheel"];
      packages = [pkgs.yazi];
    };
  };

  security.sudo.wheelNeedsPassword = false;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  booru = {
    enable = true;
    imgList = import ./imgList.nix;
    filters.artists = {
      list = ["elodeas" "yoneyama_mai" "void_0" "morncolour"];
      invert = true;
    };
  };

  systemd.user.tmpfiles.users.sango.rules = let
    home = config.users.users.sango.home;
    image = config.booru.images."5931821";
  in [
    "L+ '${home}/booru' - - - - ${config.booru.imageFolder}"
    "L+ '${home}/${builtins.toString image.metadata.id}.${image.metadata.file_ext}' - - - - ${image}"
  ];
}
