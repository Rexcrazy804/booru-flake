# Degeneracy at its finest xD
A nixos flake that automatically downloads, and categorizes images from
danbooru given a list of img id (and two hashes) (refer to the newImgList.nix).

This is primarily just a flake that I created to put my own nix os skill to
test Making a module out of this will be pretty easy. Maybe I will do that next
:)

the default package will download every image listed in the imglist and auto
categorize them
```sh
nix build github:Rexcrazy804/booru-flake
```

images available in the newImgList can be accessed with their corresponding
id's
```sh
nix build github:Rexcrazy804/booru-flake#"6073289"
```

their metadata in the form of a nix Attrset following the danbooru api json
spec is passthru'd from the package and accessible with `"<imgid>".metadata`

additionally a `fetchBooruImg` package is provided by the flake for overriding
with custom id and corresponding hashes

## Credits
- [Danbooru](https://danbooru.donmai.us/) great image board if you can ignore
the nsfw
- [Myself](https://github.com/Rexcrazy804) for my need to have perfectly
categroized **home work** folders
- [noogle.dev](https://noogle.dev/) absurdly great tool for documentation and
quickly finding source code for various functions
- Hyprland discord (I don't think I would have written this if it weren't for that discord channel)
