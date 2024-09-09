{ home-manager, nixvim, pkgs, lib, username, stateVersion, ... } : {
  imports = [ home-manager.nixosModules.home-manager ];

  # Use NixOS nixpkgs & configurations
  home-manager.useGlobalPkgs = true;
  # Install packages in /etc/profiles
  home-manager.useUserPackages = true;

  # Automatically login zogstrip
  services.getty.autologinUser = username;

  # zogstrip's group
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
    # Can `sudo`
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Install 1password CLI & GUI from NixOS instead of Home-Manager
  # NOTE: otherwise `op` wasn't connecting with 1password
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ username ];

  # zogstrip's home configuration
  home-manager.users.${username} = {
    imports = [ nixvim.homeManagerModules.nixvim ];

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

    # Configure dark mode for GTK3 applications
    gtk.enable = true;
    gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = true;

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
          gpg.ssh.program = lib.getExe' pkgs._1password-gui "op-ssh-sign";
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
      foot.settings = {
        # black background
        colors.background = "000000";
      };

      # system informations (better `neofetch`)
      fastfetch.enable = true;

      # text editor
      # monochrome theme from https://wickstrom.tech/2024-08-12-a-flexible-minimalist-neovim.html
      nixvim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        colorscheme = "quiet";
        # TODO: find a way to use 'nix' to configure these?
        extraConfigVim = ''
          highlight Keyword gui=bold
          highlight Comment gui=italic
          highlight Constant guifg=#999999
          highlight NormalFloat guibg=#333333
        '';
        opts = {
          # show current line number
          number = true;
          # show relative numbers
          relativenumber = true;
          # convert spaces to tabs
          expandtab = true;
          # 2 spaces for each "indent"
          shiftwidth = 2;
          # 2 spaces for <tab> or <del>
          softtabstop = 2;
        };
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
        # use hjkl to navigate
        vim_keys = true;
        # square corners look better
        rounded_corners = false;
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
    # TODO: compare the following modules
    #   - https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/river.nix
    #   - https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/wayland/river.nix
    wayland.windowManager.river = {
      # enable `river` wm
      enable = true;
      # DOC: https://codeberg.org/river/river/src/branch/master/doc/riverctl.1.scd
      # TUTO: https://leon_plickat.srht.site/writing/river-setup-guide/article.html
      # EXAMPLE: https://codeberg.org/river/river/src/branch/master/example/init
      settings = {
        # black background
        background-color = "0x000000";
        # use `rivertile` for layout
        default-layout = "rivertile";
        # enable natural scrolling on touchpad
        input."*_Touchpad".natural-scroll = true;
        # remove borders
        border-width = 0;
        # keyboard shortcuts
        map.normal = {
          ### Function keys
          # (F1) Mute
          "None XF86AudioMute" = "spawn 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'";
          # (F2) Lower volume
          "None XF86AudioLowerVolume" = "spawn 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-'";
          # (F3) Raise volume (maximum 100%)
          "None XF86AudioRaiseVolume" = "spawn 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+ --limit 1'";
          # (F4) TODO: Previous
          # "None XF86AudioPrev" = "spawn ''";
          # (F5) TODO: Play/Pause
          # "None XF86AudioPlay" = "spawn ''";
          # (F6) TODO: Next
          # "None XF86AudioNext" = "spawn ''";
          # (F7) TODO: Brightness down
          # "None XF86MonBrightnessDown" = "spawn ''";
          # (F8) TODO: Brightness up
          # "None XF86MonBrightnessUp" = "spawn ''";
          # (F9) <not used>
          # (F10) Plane mode
          "None XF86RFKill" = "spawn 'rfkill toggle wlan'";
          # (F11) TODO: <print screen>
          # (F12) <not used>
          ### Regular shortcuts
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
