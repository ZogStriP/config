{ username, stateVersion, ... } : {
  # Use the "systemd-boot" boot loader
  boot.loader.systemd-boot.enable = true;

  users = {
    # Ensure users can't be changed
    mutableUsers = false;

    # Disable root
    users.root.hashedPassword = "!";

    users.${username} = {
      # Just a regular user
      isNormalUser = true;
      # No need for a password
      hashedPassword = "";
      # Can `sudo` and manage network interfaces (LAN, WAN)
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };

  # NixOS version this flake was initially created on
  system.stateVersion = stateVersion;
}
