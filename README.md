# Degeneracy at its finest xD
A nixos flake that automatically downloads, and categorizes images from
danbooru given a list of img id (and two hashes) (refer to the newImgList.nix).

This is primarily just a flake that I created to put my own nix skills to the
test. Making a module out of this will be pretty easy. Maybe I will do that
next. If anyone is interested in doing it feel very welcome to do so :D
> previews are available in [preview.md](preview.md) inspired by [orangci/walls-catppuccin](https://github.com/orangci/walls-catppuccin-mocha)
## Accessing Folders
The default package will download every image listed in the imglist and auto
categorize them 
```sh
nix build github:Rexcrazy804/booru-flake
```
> **I can guarantee that there is nothing NSFW**
at worst there is **one** mildly suggestive kokomi picture

You may additionally access specific character or copyright or artist folders
with the following syntax
```sh
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

## Accessing images by ID
Images available in the newImgList can be accessed with their corresponding
id's
```sh
nix build github:Rexcrazy804/booru-flake#"6073289"
```

Their metadata in the form of a nix Attrset following the danbooru api json
spec is passthru'd from the package and accessible with `"<imgid>".metadata`

## Generating nix code for imgList using `getAttrsScript`
Additionally a `fetchBooruImg` package is provided by the flake for overriding
with custom id and corresponding hashes for instance
```sh
nix run github:Rexcrazy804/booru-flake#getAttrsScript -- 5931821 8086139
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

## Credits
- [Danbooru](https://danbooru.donmai.us/) great image board if you can ignore
the nsfw
- [Myself](https://github.com/Rexcrazy804) for my need to have perfectly
categorized **home work** folders (and being hornie)
- [noogle.dev](https://noogle.dev/) absurdly great tool for documentation and
quickly finding source code for various functions
- Hyprland discord (I don't think I would have written this if it weren't for that discord channel)
