{ home-manager, pkgs, username, stateVersion, ... } : {
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Automatically login zogstrip
  services.getty.autologinUser = username;

  # Enable TLP for better power/battery management
  services.tlp.enable = true;

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
    home.packages = with pkgs; [
      curl
      wget
      httpie
    ];

    # Programs that need configuration
    programs = {
      # Let home manager manage itself
      home-manager.enable = true;

      # source control
      git.enable = true;

      git = {
        userEmail = "regis@hanol.fr";
        userName = "zogstrip";
        difftastic.enable = true;
      };

      # system informations
      fastfetch.enable = true;

      # text editor
      vim.enable = true;

      # fuzzy finder
      fzf.enable = true;

      # json tooling
      jq.enable = true;

      # better shell history
      atuin.enable = true;

      # better `ls`
      eza.enable = true;

      # better `cd`
      zoxide.enable = true;

      # better `top`
      btop.enable = true;

      # better `cat`
      bat.enable = true;

      # better `grep`
      ripgrep.enable = true;
    };

    # river window manager - https://isaacfreund.com/software/river/
    # TODO: compare the following modules
    #   - https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/river.nix
    #   - https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/wayland/river.nix
    wayland.windowManager.river.enable = true;
  };
}
