{ pkgs, lib, hostname, stateVersion, ... } : {
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

    # Enable systemd in initrd
    initrd.systemd.enable = true;

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

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Use `iwd` for WiFi
  networking.networkmanager.wifi.backend = "iwd";

  # Disable wait-online target for faster boot
  systemd.network.wait-online.enable = false;

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

  # Enable RealtimeKit (required for pipewire / pulse)
  security.rtkit.enable = true;

  # Enable fingerprint reader
  # Enroll with `sudo fprintd-enroll zogstrip`
  # Verify with `fprintd-verify`
  services.fprintd.enable = true;

  # Enable TLP for better power management
  services.tlp.enable = true;

  # Enable pipewire for audio / video streams
  services.pipewire.enable = true;

  # Use dbus-broker, a better/faster dbus daemon (default in Arch)
  # https://archlinux.org/news/making-dbus-broker-our-default-d-bus-daemon/
  services.dbus.implementation = "broker";

  # Disable power button
  services.logind.powerKey = "ignore";

  # Remap CAPS lock to ESC
  services.udev.extraHwdb = ''
    evdev:atkbd:*
      KEYBOARD_KEY_3a=esc
  '';

  # Remove nano
  programs.nano.enable = false;

  # Enable default fonts
  # cf. https://github.com/NixOS/nixpkgs/blob/12228ff1752d7b7624a54e9c1af4b222b3c1073b/nixos/modules/config/fonts/packages.nix#L35-L40
  fonts.enableDefaultPackages = true;

  # Allow 1password "unfree" packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem(lib.getName pkg) [
    "1password-cli"
    "1password"
  ];

  # Disable nix channels
  nix.channel.enable = false;

  # Allow "flakes" system-wide
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Remove all "dirty repository" warnings
  nix.settings.warn-dirty = false;

  # NixOS version this flake was initially created on
  system.stateVersion = stateVersion;
}
