# Simple auto categorizing image library
Booru-flake is a nixos module for declaratively storing and auto categorizing
your collection of danbooru images based on characters, copyrights, and artists.
Letting you reference images throughout your nixos configuration with ease

### Example configuration
```nix
programs.booru-flake = {
    enable = true;
    prefetcher.enable = true; # supporting script booru-prefetch for generating below structure
    imgList = [
        {
            id = "7452256";
            jsonHash = "sha256-T+NzB5md5SheEOQIFuth0AgMUhSK9kikneQkM6w4XhQ=";
            imgHash = "sha256-U18rCuKNSTKPLPl5tzDDhudJYWU2nVOgLRwTlDHCJJ4=";
        }
        {
            id = "5931821";
            jsonHash = "sha256-pBnBov+xukptTx0wYg5x4KfKAA9aTy3J7Kk6nZLuohM=";
            imgHash = "sha256-w1blRj2GXbl18eAgokb5o7NGbN7+mUSESOqGDud1ofc=";
        }
    ];
};

systemd.user.tmpfiles.users.your-username.rules = let
    home = config.users.users.your-username.home;
    image = config.programs.booru-flake.images."5931821"; # access a specific image
in [
    # creates a folder in your home directory called booru and plants the auto
    # categorized image folder there
    # NOTE you can use home manager or hjem to do this for you
    "L+ '${home}/booru' - - - - ${config.programs.booru-flake.imageFolder}"
    "L+ '${home}/${image.name}' - - - - ${image}" # links a specific image into your home directory
];
```
> for further documentation checkout the [nixosModule](nix/nixosModule.nix)'s descriptions

### Generating nix code for imgList using `booru-prefetch`
```sh
booru-prefetch 5931821 8086139
# will output the following to stdout [just pipe it to wl-copy or save to file]
# {
#   id = "5931821";
#   jsonHash = "sha256-OIkZVByQZucTjMDSsj9MNgAMsa1eF75+uPB1ELObK38=";
#   imgHash = "sha256-w1blRj2GXbl18eAgokb5o7NGbN7+mUSESOqGDud1ofc=";
# }
# {
#   id = "8086139";
#   jsonHash = "sha256-NVu4+qxgdu/YyuUkwHEj6gJJ0KW29UoiW+sUkWFIwqA=";
#   imgHash = "sha256-lZoNJPNqrl3PxYDl+anP2vYhCXYbRGGJi7zZxMwb490=";
# }
```

## Accessing the imgList of this repository
> previews are available in [preview.md](preview.md) inspired by [orangci/walls-catppuccin](https://github.com/orangci/walls-catppuccin-mocha)

> NOTE these are docs for when you expose the imageFolder in your own flake

### Accessing Folders
The default package will download every image listed in the imglist and auto
categorize them
```sh
nix build github:Rexcrazy804/booru-flake
```

You may additionally access specific character or copyright or artist folders
with the following syntax:
```sh
# Replace .# with github:Rexcrazy804/booru-flake#
# builds all images of void_0 into result/
nix build .#default.entries.Artists.entries.void_0

# builds all images of sangonomiya_kokomi
nix build .#default.entries.Characters.entries.sangonomiya_kokomi

# builds all images belonging to genshin_impact
nix build .#default.entries.Copyrights.entries.genshin_impact
```
additionally if you are unsure what is valid within each entry just place a `.` after the
entries attr like so to get a nix error spitting the whole list
```
nix build .#default.entries.Copyrights.entries.
```

### Accessing images by ID
Images available in the newImgList can be accessed with their corresponding
id's
```sh
nix build github:Rexcrazy804/booru-flake#"6073289"
```

Their metadata in the form of a nix Attrset following the danbooru api json
spec is passthru'd from the package and accessible with `"<imgid>".metadata`


## Credits
- [Danbooru](https://danbooru.donmai.us/) great image board if you can ignore
the nsfw
- [Myself](https://github.com/Rexcrazy804) for my need to have perfectly
categorized **home work** folders (and being hornie)
- [noogle.dev](https://noogle.dev/) absurdly great tool for documentation and
quickly finding source code for various functions
- Hyprland discord (I don't think I would have written this if it weren't for that discord channel)
