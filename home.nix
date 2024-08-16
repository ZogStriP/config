{ home-manager, username, stateVersion, ... } : {
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # zogstrip's user account
  users.users.${username} = {
    # Just a regular user
    isNormalUser = true;
    # No need for a password
    hashedPassword = "";
    # Can `sudo` and manage network interfaces (LAN, WAN)
    extraGroups = [ "wheel" "networkmanager" ];
  };

  home-manager.users.${username} = {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = stateVersion;
    programs.home-manager.enable = true;
  };
}
