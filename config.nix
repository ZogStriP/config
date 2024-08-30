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

  # Enable network manager
  networking.networkmanager.enable = true;

  # Use `iwd` instead of `wpa_supplicant` for managing WiFi
  networking.networkmanager.wifi.backend = "iwd";

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

  # Enable TLP for better power management
  services.tlp.enable = true;

  # Enable pipewire for audio / video streams
  services.pipewire.enable = true;

  # Use dbus-broker, a better/faster dbus daemon (default in Arch)
  # https://archlinux.org/news/making-dbus-broker-our-default-d-bus-daemon/
  services.dbus.implementation = "broker";

  # Disable power button
  services.logind.powerKey = "ignore";

  # Enable natural scrolling on the touchpad
  services.libinput.touchpad.naturalScrolling = true;

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
