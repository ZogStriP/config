# How to install

- Disable secure boot
- Boot the latest NixOS ISO image
- Type

```plain
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko#disko-install -- \
  --flake github:zogstrip/config#framezork \
  --write-efi-boot-entries \
  --disk main /dev/nvme0n1
```

> ⚠️ Will ask for LUKS password
