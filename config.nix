{ pkgs, hostname, stateVersion, ... } : {
  # Various open source drivers
  hardware.enableRedistributableFirmware = true;
  
  # Update CPU's microcode
  hardware.cpu.intel.updateMicrocode = true;
  
  # Enable hardware accelerated graphics drivers
  hardware.graphics.enable = true;

  boot = {
    # Use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Disable bcache support in initrd
    bcache.enable = false;

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

  # Machine's timezone
  time.timeZone = "Europe/Paris";

  # Ensure users can't be changed
  users.mutableUsers = false;

  # Disable root login by setting an impossible password hash
  users.users.root.hashedPassword = "!";

  # Don't ask for password when `sudo`-ing
  security.sudo.wheelNeedsPassword = false;

  # Enable PolKit (required for wayland / river)
  security.polkit.enable = true;

  # Enable TLP for better power management
  services.tlp.enable = true;

  # Enable pipewire for audio / video streams
  services.pipewire.enable = true;

  # Disable power button
  services.logind.powerKey = "ignore";

  # Remap CAPS lock to ESC
  services.udev.extraHwdb = ''
    evdev:atkbd:*
      KEYBOARD_KEY_3a=esc
  '';

  # Remove nano
  programs.nano.enable = false;

  # Disable nix channels
  nix.channel.enable = false;

  # Allow "flakes" system-wide
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # NixOS version this flake was initially created on
  system.stateVersion = stateVersion;
}
