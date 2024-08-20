{ home-manager, pkgs, username, stateVersion, ... } : {
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Automatically login zogstrip
  services.getty.autologinUser = username;

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
      dust # better `du`
      duf # better `df`
      hexyl # better `xxd`
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

      # (wayland) terminal emulator
      foot.enable = true;

      # system informations (better `neofetch`)
      fastfetch.enable = true;

      # text editor
      vim.enable = true;

      # fuzzy finder
      fzf.enable = true;

      # json tooling
      jq.enable = true;

      # web browser
      firefox.enable = true;

      # media player
      mpv.enable = true;

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

      # better `find`
      fd.enable = true;
    };

    # river window manager - https://isaacfreund.com/software/river/
    # TODO: disable xwayland?
    # TODO: compare the following modules
    #   - https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/river.nix
    #   - https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/wayland/river.nix
    wayland.windowManager.river = {
      # enable `river` wm
      enable = true;
      # DOC: https://codeberg.org/river/river/src/branch/master/doc/riverctl.1.scd
      # EXAMPLE: https://codeberg.org/river/river/src/branch/master/example/init
      settings = {
        # black background
        background-color = "0x000000";
        # faster keyboard repeat rate
        set-repeat = "50 150";
        # use `rivertile` for layout
        default-layout = "rivertile";
        # keyboard shortcuts
        map.normal = {
          # open new terminal
          "Super Return" = "spawn foot";
          # close focused view
          "Super Q" = "close";
          # exit `river`
          "Super+Shift E" = "exit";
        };
        # launch some apps when starting
        spawn = [
          "rivertile" # the layout manager
          "foot" # terminal emulator
        ];
      };
    };
  };
}
