{ stateVersion, ... } : {
  # Use the "systemd-boot" boot loader
  boot.loader.systemd-boot.enable = true;

  # Ensure users can't be changed
  users.mutableUsers = false;

  # Disable root by setting an impossible password hash
  users.users.root.hashedPassword = "!";

  # NixOS version this flake was initially created on
  system.stateVersion = stateVersion;
}
