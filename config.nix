{
  # Update CPU's microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Use the "systemd-boot" boot loader
  boot.loader.systemd-boot.enable = true;

  # System's timezone
  time.timeZone = "Europe/Paris";

  # NixOS version this flake was initially created on
  system.stateVersion = "24.05";
}
