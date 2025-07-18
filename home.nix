{ home-manager, nixvim, dactylogramme, pkgs, lib, username, stateVersion, ... } : {
  imports = [ home-manager.nixosModules.home-manager ];

  # Use NixOS nixpkgs & configurations
  home-manager.useGlobalPkgs = true;
  # Install packages in /etc/profiles
  home-manager.useUserPackages = true;

  # zogstrip's group
  users.groups.${username} = {};

  # zogstrip's user account
  users.users.${username} = {
    # Just a regular user
    isNormalUser = true;
    # `mkpasswd -m yescrypt > /persist/passwd` to generate hash
    hashedPassword = "";
    # TODO: hashedPasswordFile = "/persist/passwd";
    # Set the `zogstrip` group
    group = username;
    # Other groups
    extraGroups = [ 
      "networkmanager" # wifi
      "video" # brightness
      "wheel" # sudo 
    ];
  };

  # Programs installed from NixOS rather than Home Manager

  # 1Password GUI & CLI
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ username ];

  # nh os switch (has much better output)
  programs.nh.enable = true;
  programs.nh.flake = "/persist/z/poetry/config";

  # disable command-not-found
  programs.command-not-found.enable = false;

  environment.systemPackages = [
    # https://github.com/ZogStriP/dactylogramme/
    dactylogramme.packages.${pkgs.system}.default
  ];

  # zogstrip's home configuration
  home-manager.users.${username} = {
    imports = [ nixvim.homeManagerModules.nixvim ];

    home.username = username;
    home.homeDirectory = "/home/${username}";

    # Sync home manager's version with NixOS'
    home.stateVersion = stateVersion;

    # Some shell aliases
    home.shellAliases = {
      ".."  = "cd ..";
      "..." = "cd ../..";
      ff    = "fastfetch";
    };

    home.sessionVariables = {
      # disable homebrew's hints
      HOMEBREW_NO_ENV_HINTS = 1;
      # use github's auth token to prevent rate limits
      NIX_CONFIG = "access-tokens = github.com=$(gh auth token)";
      # enable yjit
      RUBY_YJIT_ENABLE = 1;
    };

    # Programs that don't need configuration
    home.packages = with pkgs; [
      claude-code
      curl # making requests
      devenv # https://devenv.sh
      duf # better `df`
      dust # better `du`
      jless # JSON pager
      ncdu # interactive `du`
      python3
      wget # downloading stuff
      wl-clipboard # wl-copy / wl-paste
      zeal # offline doc
    ];

    # Configure dark mode for GTK3 applications
    gtk.enable = true;
    gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = true;

    # Configure dark mode for Qt applications
    qt.enable = true;
    qt.style.name = "adwaita-dark";

    # Programs that need configuration
    programs = {
      # Let home manager manage itself
      home-manager.enable = true;

      # enable bash (for TTYs)
      bash.enable = true;

      # automatically launch `river` on tty1
      bash.profileExtra = ''
        [[ -z "$DISPLAY" && $(tty) = "/dev/tty1" ]] && exec ${pkgs.river}/bin/river > ~/.river.log 2>&1
      '';

      # chrome
      chromium.enable = true;

      # enable fish (used in `foot`)
      fish.enable = true;

      # configure fish
      fish.interactiveShellInit = ''
        # disable greeting
        set fish_greeting

        # run on each prompt
        function on_prompt --on-event fish_prompt
          # marker to allow jumping between prompt (ctrl+shift+y / ctrl+shift+x)
          echo -en "\e]133;A\e\\"

          # save last dir
          echo $PWD > ~/.last
        end

        # cd into last dir
        if test -f ~/.last
          cd (cat ~/.last)
        end
      '';

      # enable starship prompt
      starship.enable = true;

      # enable direnv
      direnv.enable = true;
      # silence direnv
      direnv.silent = true;

      # ssh
      ssh.enable = true;
      # use compression
      ssh.compression = true;
      # use 1password SSH agent
      ssh.matchBlocks."*".extraOptions.IdentityAgent = "~/.1password/agent.sock";

      # source control
      git = {
        enable = true;
        # use difftastic for better diffing
        difftastic.enable = true;
        # git aliases
        aliases = {
          b = "branch";
          br = "branch";
          co = "checkout";
          st = "status";
          wip = "!f() { git add .; git commit --no-verify -m 'wip'; }; f";
          undo = "reset HEAD~1 --mixed";
        };
        # global ignores - cf. https://github.com/github/gitignore
        ignores = [
          # https://direnv.net
          ".direnv"

          # https://devenv.sh
          ".devenv*"

          # node
          "/node_modules/"

          # tmp
          "/tmp/"

          # vim
          "*.swp"

          # macOS
          ".DS_Store"
        ]; 
        # commit signing
        signing = {
          format = "ssh";
          signer = lib.getExe' pkgs._1password-gui "op-ssh-sign";
          signByDefault = true;
        };
        # global git config
        extraConfig = {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          # always use SSH - https://www.jvt.me/posts/2019/03/20/git-rewrite-url-https-ssh/
          url."ssh://git@github.com/".InsteadOf = "https://github.com/";
          # user settings
          user = {
            name = username;
            email = "regis@hanol.fr";
            signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3naLkQYJ4SP6pk/ZoPWJcUW4hoOoBzy1JoO8I5lpze";
          };
        };
      };

      # github cli
      gh.enable = true;
      gh.settings.git_protocol = "ssh";

      # (wayland) terminal emulator
      # https://codeberg.org/dnkl/foot
      foot.enable = true;
      foot.settings = {
        # black background
        colors.background = "000000";
        # bigger font
        main.font = "monospace:size=12";
        # default shell
        main.shell = "fish";
        # hide mouse when typing
        mouse.hide-when-typing = true;
        # lots of scrollback (default is 1k)
        scrollback.lines = 65536;
      };

      # system informations (better `neofetch`)
      fastfetch.enable = true;

      helix.enable = true;

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
          # case insensitive search by default
          ignorecase = true;
          # case sensitive search only when there's an uppercase character
          smartcase = true;
          # disable wrapping by default
          wrap = false;
          # merge both * and + registers to allow system-wide copy/paste
          clipboard = "unnamedplus";
        };
      };

      # json tooling
      jq.enable = true;

      # web browser
      firefox.enable = true;
      firefox.policies = {
        DisableAccounts = true;
        ExtensionSettings = {
          # 1Password:
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          # uBlock Origin:
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
      firefox.profiles.${username} = {
        id = 0;
        name = username;
        settings = {
          "app.normandy.api_url" = "";
          "app.normandy.enabled" = false;
          "app.shield.optoutstudies.enabled" = true;
          "apz.gtk.kinetic_scroll.enabled" = false;
          "browser.aboutConfig.showWarning" = false;
          "browser.discovery.enabled" = false;
          "browser.newtabpage.activity-stream.discoverystream.enabled" = false;
          "browser.newtabpage.enabled" = false;
          "browser.region.network.url" = "";
          "browser.region.update.enabled" = false;
          "browser.startup.blankWindow" = true;
          "browser.startup.firstrunSkipsHomepage" = true;
          "browser.startup.homepage" = "about:blank";
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.topsites.contile.enabled" = false;
          "browser.topsites.contile.endpoint" = "";
          "browser.translations.automaticallyPopup" = false;
          "browser.urlbar.suggest.searches" = false;
          "browser.urlbar.suggest.topsites" = false;
          "browser.urlbar.suggest.trending" = false;
          "browser.urlbar.suggest.weather" = false;
          "browser.urlbar.suggest.yelp" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.policy.firstRunURL" = "";
          "dom.push.connection.enabled" = false;
          "extensions.pocket.enabled" = false;
          "privacy.donottrackheader.enabled" = true;
          "privacy.globalprivacycontrol.enabled" = true;
          "startup.homepage_welcome_url" = "about:blank";
        };
      };

      # better `ls`
      eza.enable = true;
      # display icons
      eza.icons = "auto";

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

      # spotify player
      spotify-player.enable = true;

      # fast python package manager
      uv.enable = true;

      # terminal-based file manager
      yazi.enable = true;
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
        # define Right-Alt to be Compose key
        keyboard-layout."-variant".altgr-intl."-options"."compose:rwin" = "us";
        # faster keyboard repeat <rate> (25/s) <delay> (600ms)
        set-repeat = "20 150";
        # enable natural scrolling on touchpad
        input."*_Touchpad".natural-scroll = true;
        # remove borders
        border-width = 0;
        # keyboard shortcuts
        map.normal = {
          ###
          ### Function keys
          ###
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
          # (F7) Brightness down
          "None XF86MonBrightnessDown" = "spawn 'xbacklight -2 -perceived'";
          # (F8) Brightness up
          "None XF86MonBrightnessUp" = "spawn 'xbacklight +2 -perceived'";
          # (F9) <not used>
          # (F10) Plane mode
          # "None XF86RFKill" = "spawn 'rfkill toggle wlan'";
          # (F11) TODO: <print screen>
          # (F12) <not used>
          ###
          ### Regular shortcuts
          ###
          # open new terminal
          "Super Return" = "spawn foot";
          # open chromium
          "Super C" = "spawn chromium";
          # open firefox
          "Super F" = "spawn firefox";
          # open 1Password's quick access
          "Super P" = "spawn '1password --quick-access'";
          # open 1Password
          "Super+Shift P" = "spawn '1password --toggle'";
          # open zeal
          "Super Z" = "spawn zeal";
          # close focused view
          "Super Q" = "close";
          # disable Ctrl+Q shortcut
          "Control Q" = "none";
          # exit `river`
          "Super+Shift E" = "exit";
          ###
          ### Tag management
          ###
          # show 'workspace' X
          "Super 1" = "set-focused-tags 1";
          "Super 2" = "set-focused-tags 2";
          "Super 3" = "set-focused-tags 4";
          "Super 4" = "set-focused-tags 8";
          # send <focused view> to 'workspace' X
          "Super+Shift 1" = "set-view-tags 1";
          "Super+Shift 2" = "set-view-tags 2";
          "Super+Shift 3" = "set-view-tags 4";
          "Super+Shift 4" = "set-view-tags 8";
          # bring 'workspace' X into view
          "Super+Alt 1" = "toggle-focused-tags 1";
          "Super+Alt 2" = "toggle-focused-tags 2";
          "Super+Alt 3" = "toggle-focused-tags 4";
          "Super+Alt 4" = "toggle-focused-tags 8";
          ###
          ### Window management
          ###
          # focus views
          "Super H" = "focus-view left";
          "Super J" = "focus-view down";
          "Super K" = "focus-view up";
          "Super L" = "focus-view right";
          "Super BracketLeft" = "focus-view previous";
          "Super BracketRight" = "focus-view next";
          # Toggle float (on focused view)
          "Super+Shift F" = "toggle-float";
          # swap focus
          "Super+Shift H" = "swap left";
          "Super+Shift J" = "swap down";
          "Super+Shift K" = "swap up";
          "Super+Shift L" = "swap right";
          "Super+Shift BracketLeft" = "swap previous";
          "Super+Shift BracketRight" = "swap next";
          # move floating views
          "Super+Alt H" = "move left 50";
          "Super+Alt J" = "move down 50";
          "Super+Alt K" = "move up 50";
          "Super+Alt L" = "move right 50";
          # snap floating views
          "Super+Alt+Control H" = "snap left";
          "Super+Alt+Control J" = "snap down";
          "Super+Alt+Control K" = "snap up";
          "Super+Alt+Control L" = "snap right";
          # resize floating views
          "Super+Alt+Shift H" = "resize horizontal -50";
          "Super+Alt+Shift J" = "resize vertical 50";
          "Super+Alt+Shift K" = "resize vertical -50";
          "Super+Alt+Shift L" = "resize horizontal 50";
          ###
          ### Layout management
          ###
          "Super Left" = "send-layout-cmd rivertile 'main-ratio -0.05'";
          "Super Right" = "send-layout-cmd rivertile 'main-ratio +0.05'";
        };
        # Add some rules based on "app-id"
        rule-add."-app-id" = {
          # ensures 1password is always floating
          "1Password" = "float";
        };
        # launch some apps when starting
        spawn = [
          # layout manager
          "'rivertile -view-padding 0 -outer-padding 0'"
          # terminal emulator
          "foot"
          # 1password (background)
          "'1password --silent'"
          # polkit authentication agent
          "dactylogramme"
        ];
      };
    };
  };
}
