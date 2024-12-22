{ pkgs, config, lib, hostname, username, stateVersion, ... } : {
  imports = [ ./luciole.nix ];

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

    # More power savings
    # https://community.frame.work/t/tracking-linux-battery-life-tuning/6665/594
    # https://discourse.ubuntu.com/t/fine-tuning-the-ubuntu-24-04-kernel-for-low-latency-throughput-and-power-efficiency/44834
    kernelParams = [
      "rcu_nocbs=all"
      "rcutree.enable_rcu_lazy=1"
    ];

    # Disable loading these modules during boot (so they don't trigger errors)
    blacklistedKernelModules = [ 
      "cros-usbpd-charger" # not used by frame.work EC and causes boot time error log
      "hid-sensor-hub" # prevent interferences with fn/media keys - https://community.frame.work/t/20675/391
      "iTCO_wdt" # disable "Intel TCO Watchdog Timer"
      "mei_wdt" # disable "Intel Management Engine Interface Watchdog Timer"
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

  # Use systemd's networkd
  networking.useNetworkd = true;

  # Disable dhcpcd because we're using networkd instead
  networking.dhcpcd.enable = false;

  # Enable `iwd`
  networking.wireless.iwd.enable = true;

  # Reduce services kill timeout from 1m30s down to 15s
  systemd.extraConfig = "DefaultTimeoutStopSec=15s";

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

  # Extra hwdb udev rules
  services.udev.extraHwdb = ''
    # Remap CAPS lock to ESC
    evdev:atkbd:*
      KEYBOARD_KEY_3a=esc

    # Disable RFKILL key (airplane mode)
    evdev:input:b0018v32ACp0006*
      KEYBOARD_KEY_100c6=reserved
  '';

  # tailscale
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";
  networking.nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
  networking.search = [ "bicorn-duckbill.ts.net" ];
  # move the `tailscaled --cleanup` from "ExecStopPost" to "ExecStop" so it can stop _before_ network is down
  systemd.services.tailscaled.serviceConfig = {
    ExecStopPost = lib.mkForce null;
    ExecStop = lib.mkForce "${config.services.tailscale.package}/bin/tailscaled --cleanup";
  };

  # use `agetty` to autologin
  services.getty.autologinUser = username;
  # hide login prompt and welcome message (issue)
  services.getty.extraArgs = [ "--skip-login" "--noissue" "--nonewline" ];

  # firmware updates manager
  services.fwupd.enable = true;

  # Remove nano
  programs.nano.enable = false;

  # Enable default fonts
  # https://github.com/NixOS/nixpkgs/blob/12228ff1752d7b7624a54e9c1af4b222b3c1073b/nixos/modules/config/fonts/packages.nix#L35-L40
  fonts.enableDefaultPackages = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

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
    # Always show the trace message when there's an error
    show-trace = true;
  };

  # NixOS version this flake was initially created on
  system.stateVersion = stateVersion;
}
