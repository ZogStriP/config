{ stateVersion, ... } : {
  # Use the "systemd-boot" boot loader
  boot.loader.systemd-boot.enable = true;

  # NixOS version this flake was initially created on
  system.stateVersion = stateVersion;
}
