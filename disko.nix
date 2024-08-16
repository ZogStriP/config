{ disko, ... } : {
  imports = [ disko.nixosModules.disko ];

  # Enable periodic SSD TRIM
  services.fstrim.enable = true;

  # Ensure /home is mounted in initrd
  fileSystems."/home".neededForBoot = true;

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "luks";
              settings.allowDiscards = true;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [ "size=128M" "defaults" "mode=755" ];
      };
      "/home" = {
        fsType = "tmpfs";
        mountOptions = [ "size=128M" "defaults" "mode=0755" ];
      };
      "/tmp" = {
        fsType = "tmpfs";
        mountOptions = [ "size=2G" "defaults" ];
      };
    };
  };
}
