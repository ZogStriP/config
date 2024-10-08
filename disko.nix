{ disko, ... } : {
  imports = [ disko.nixosModules.disko ];

  # Enable periodic SSD TRIM
  services.fstrim.enable = true;

  # Enable automatic BTRFS scrubbing
  services.btrfs.autoScrub.enable = true;

  # Ensure filesystems are mounted in initrd
  # Note: "/", "/nix", and "/var/log" are always `neededForBoot`
  fileSystems."/persist".neededForBoot = true;

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
              # Ensure the /boot partition isn't world-readable
              # https://github.com/NixOS/nixpkgs/pull/300673
              # https://github.com/nix-community/disko/issues/527
              mountOptions = [ "umask=077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "luks";
              # Allow SSD TRIM
              settings.allowDiscards = true;
              # SDD Perf - https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
              settings.bypassWorkqueues = true;
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "16G";
                  };
                };
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
      "/tmp" = {
        fsType = "tmpfs";
        mountOptions = [ "size=2G" "defaults" ];
      };
    };
  };
}
