{ pkgs, lib, hostname, username, stateVersion, ... } : {
  # Various open source drivers
  hardware.enableRedistributableFirmware = true;
  
  # Update CPU's microcode
  hardware.cpu.intel.updateMicrocode = true;
  
  # Enable hardware accelerated graphics drivers
  hardware.graphics.enable = true;

  # Allow brightness control via `xbacklight` for users in `video` group
  hardware.acpilight.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable `bredr` to pair with AirPods (only required to do the initial pairing)
  # hardware.bluetooth.settings.General.ControllerMode = "bredr";

  boot = {
    # Use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Disable loading these modules during boot (so they don't trigger errors)
    blacklistedKernelModules = [ 
      "cros_ec_lpcs" # TODO: figure out what they do
      "cros_ec_gpio" # TODO: figure out what they do
      "cros-usbpd-charger" # not used by frame.work EC and causes boot time error log
      "hid-sensor-hub" # prevent interferences with fn/media keys - https://community.frame.work/t/20675/391
    ];

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

  # Only members of `wheel` group can execute `sudo`
  security.sudo.execWheelOnly = true;

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

  # Enable ALSA support for audio
  services.pipewire.alsa.enable = true;

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

  # Use greetd login manager to autologin into `river`
  services.greetd.enable = true;
  services.greetd.settings.default_session.command = "${pkgs.greetd.greetd}/bin/agreety --cmd ${pkgs.bashInteractive}/bin/bash";
  services.greetd.settings.initial_session.user = username;
  services.greetd.settings.initial_session.command = "river > ~/.river.log 2>&1";

  # tailscale
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  networking.nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
  networking.search = [ "bicorn-duckbill.ts.net" ];

  # Remove nano
  programs.nano.enable = false;

  # Enable default fonts
  # https://github.com/NixOS/nixpkgs/blob/12228ff1752d7b7624a54e9c1af4b222b3c1073b/nixos/modules/config/fonts/packages.nix#L35-L40
  fonts.enableDefaultPackages = true;

  # Allow 1password "unfree" packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem(lib.getName pkg) [
    "1password-cli"
    "1password"
  ];

  # Disable nix channels
  nix.channel.enable = false;

  nix.settings = {
    # Allow "flakes" system-wide
    experimental-features = [ "nix-command" "flakes" ];
    # All members of wheel group are trusted
    trusted-users = [ "@wheel" ];
    # Remove all "dirty repository" warnings
    warn-dirty = false;
  };

  # NixOS version this flake was initially created on
  system.stateVersion = stateVersion;
}
