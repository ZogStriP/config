{ home-manager, pkgs, lib, username, stateVersion, ... } : {
  imports = [ home-manager.nixosModules.home-manager ];

  # Use NixOS nixpkgs & configurations
  home-manager.useGlobalPkgs = true;
  # Install packages in /etc/profiles
  home-manager.useUserPackages = true;

  # Automatically login zogstrip
  services.getty.autologinUser = username;

  # Create a zogstrip group
  users.groups.${username} = {};

  # zogstrip's user account
  users.users.${username} = {
    # Just a regular user
    isNormalUser = true;
    # `mkpasswd -m yescrypt > /persist/passwd` to generate hash
    hashedPassword = "";
    # hashedPasswordFile = "/persist/passwd";
    # Set the `zogstrip` group
    group = username;
    # Can `sudo` and manage network interfaces (LAN, WAN)
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Install 1password CLI & GUI from NixOS instead of Home-Manager
  # NOTE: otherwise `op` wasn't connecting with 1password
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ username ];

  # zogstrip's home configuration
  home-manager.users.${username} = {
    home.username = username;
    home.homeDirectory = "/home/${username}";

    # Sync home manager's version with NixOS'
    home.stateVersion = stateVersion;

    # Some shell aliases
    home.shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    # Programs that don't need configuration
    home.packages = with pkgs; [
      curl
      dust # better `du`
      ncdu # interactive `du`
      duf # better `df`
      hexyl # better `xxd`
    ];

    # Programs that need configuration
    programs = {
      # Let home manager manage itself
      home-manager.enable = true;

      # enable `bash`
      bash.enable = true;

      # setup ssh to use 1password SSH agent
      ssh.enable = true;
      ssh.matchBlocks."*".extraOptions.IdentityAgent = "~/.1password/agent.sock";

      # source control
      git = {
        enable = true;
        # use difftastic for better diffing
        difftastic.enable = true;
        # git aliases
        aliases = {
          b = "branch";
          co = "checkout";
          d = "diff";
          l = "log";
          p = "push";
          st = "status";
          wip = "!f() { git add .; git commit --no-verify -m 'wip'; }; f";
          undo = "reset HEAD~1 --mixed";
        };
        # global git config
        extraConfig = {
          commit.gpgsign = true;
          gpg.format = "ssh";
          gpg.ssh.program = (lib.getExe' pkgs._1password-gui "op-ssh-sign");
          push.autoSetupRemote = true;
          user = {
            name = username;
            email = "regis@hanol.fr";
            signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3naLkQYJ4SP6pk/ZoPWJcUW4hoOoBzy1JoO8I5lpze";
          };
        };
      };

      # (wayland) status bar
      # https://codeberg.org/dnkl/yambar
      yambar.enable = true;
      yambar.settings.bar = {
        height = 26;
        location = "bottom";
        background = "000000FF";
      };

      # (wayland) terminal emulator
      # https://codeberg.org/dnkl/foot
      foot.enable = true;

      # system informations (better `neofetch`)
      fastfetch.enable = true;

      # text editor
      neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        extraConfig = ''
          " monochrome theme from https://wickstrom.tech/2024-08-12-a-flexible-minimalist-neovim.html
          set termguicolors
          set bg=dark
          colorscheme quiet
          highlight Keyword gui=bold
          highlight Comment gui=italic
          highlight Constant guifg=#999999
          highlight NormalFloat guibg=#333333
        '';
      };

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
      # don't show atuin when pressing the ⬆️ key
      atuin.flags = [ "--disable-up-arrow" ];

      # better `ls`
      eza.enable = true;

      # better `cd`
      zoxide.enable = true;

      # better `top`
      btop.enable = true;
      btop.settings = {
        # set refresh rate to 1s
        update_ms = 1000;
        # show processes as a tree
        proc_tree = true;
        # only show these "disks"
        disks_filter = "/ /boot /nix /tmp /swap";
      };

      # better `cat`
      bat.enable = true;

      # better `grep`
      ripgrep.enable = true;

      # better `find`
      fd.enable = true;
    };

    # (wayland) window manager
    # https://isaacfreund.com/software/river/
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
        # use `rivertile` for layout
        default-layout = "rivertile";
        # enable natural scrolling on touchpad
        input."*_Touchpad".natural-scroll = true;
        # keyboard shortcuts
        map.normal = {
          # open new terminal
          "Super Return" = "spawn foot";
          # open firefox
          "Super F" = "spawn firefox";
          # close focused view
          "Super Q" = "close";
          # exit `river`
          "Super+Shift E" = "exit";
        };
        # launch some apps when starting
        spawn = [
          # status bar
          "yambar"
          # layout manager
          "'rivertile -view-padding 0 -outer-padding 0'"
          # terminal emulator
          "foot"
          # 1password (background)
          "'1password --silent'"
        ];
      };
    };
  };
}
