{ home-manager, username, stateVersion, ... } : {
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  users.users.${username} = {
    isNormalUser = true;
    hashedPassword = "!";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  home-manager.users.${username} = {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = stateVersion;
    programs.home-manager.enable = true;
  };
}
