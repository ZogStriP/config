{ home-manager, pkgs, username, stateVersion, ... } : {
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

    # Sync home manager's version with NixOS'
    home.stateVersion = stateVersion;

    # Programs that don't need configuration
    home.packages = with pkgs [
      fastfetch
      curl
      vim
      fzf # fuzzy finder
      tlp # power manager
      jq # json tooling
      btop # better `top`
      bat # better `cat`
      ripgrep # better `grep`
    ];

    programs = {
      # Let home manager manage itself
      home-manager.enable = true;

      #
      git = {
        enable = true;
        userEmail = "regis@hanol.fr";
        userName = "zogstrip";
        diffstatic.enable = true;
      };

      # better `ls`
      eza = {
        enable = true;
        git = true;
        icons = true;
      };

      # river window manager
      wayland.windowManager.river.enable = true;
    };
  };
}
