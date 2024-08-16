{ pkgs, hostname, stateVersion, ... } : {
  # Update CPU's microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Enable all firmware
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  boot = {
    # Use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      # Don't display the boot loader (press <space> to show it if needed)
      timeout = 0;

      systemd-boot = {
        # Enable "systemd-boot" boot loader
        enable = true;
        # Disable editing the boot menu
        editor = false;
        # Keep a maximum of 5 generations
        configurationLimit = 5;
      };

      # Allow NixOS to modify EFI variables
      efi.canTouchEfiVariables = true;
    };
  };

  # Machine's name
  networking.hostName = hostname;

  # Ensure users can't be changed
  users.mutableUsers = false;

  # Disable root by setting an impossible password hash
  users.users.root.hashedPassword = "!";

  # Don't ask for password when `sudo`-ing
  security.sudo.wheelNeedsPassword = false;

  # Disable documentations for leaner/faster install
  documentation.enable = false;
  documentation.doc.enable = false;
  documentation.nixos.enable = false;

  # Allow "flakes" system-wide
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # NixOS version this flake was initially created on
  system.stateVersion = stateVersion;
}
