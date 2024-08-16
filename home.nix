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

  # zogstrip's home configuration
  home-manager.users.${username} = {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = stateVersion;

    programs = {
      home-manager.enable = true;
      btop.enable = true;
      fastfetch.enable = true;
      vim.enable = true;
      git = {
        enable = true;
        userEmail = "regis@hanol.fr";
        userName = "zogstrip";
      };
    };
  };
}
