{ username, stateVersion, ... } : {
  # Update CPU's microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Use the "systemd-boot" boot loader
  boot.loader.systemd-boot.enable = true;

  # System's timezone
  time.timeZone = "Europe/Paris";

  users = {
    # Ensure users can't be changed
    mutableUsers = false;

    # Disable root password
    users.root.hashedPassword = "!";

    # zogstrip's user account
    users.${username} = {
      isNormalUser = true;
      hashedPassword = "!";
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };

  # NixOS version this flake was initially created on
  system.stateVersion = stateVersion;
}
