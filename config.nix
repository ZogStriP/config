{ stateVersion, ... } : {
  # Update CPU's microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Use the "systemd-boot" boot loader
  boot.loader.systemd-boot.enable = true;

  # System's timezone
  time.timeZone = "Europe/Paris";

  # Ensures users can't be changed
  users.mutableUsers = false;

  # Disable root password
  user.users.root.hashedPassword = "!";

  # NixOS version this flake was initially created on
  system.stateVersion = stateVersion;
}
