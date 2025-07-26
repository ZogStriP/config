{ pkgs, hm, lib, ... }: let
  username        = "zogstrip";
  email           = "regis@hanol.fr";
  home            = "/Users/${username}";
  ops             = "${home}/Poetry/ops";
  ssh-signing-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3naLkQYJ4SP6pk/ZoPWJcUW4hoOoBzy1JoO8I5lpze";
  aws-mfa-serial  = "arn:aws:iam::829212916754:mfa/zogstrip-1password";
in {
  imports = [ hm.darwinModules.home-manager ];

  # TODO: find a way to send the proper OSC sequences to
  #       - change background color when sudo & ssh
  # TODO: extract Terminal.app's configuration from `defaults read com.apple.Terminal` and apply it here
  # TODO: find a way to install Kolide with nix ? https://github.com/kolide/nix-agent ?
  # TODO: find a way to set the screen resolution
  # TODO: find a way to make app installed by home-manager appear in the dock & spotlight
  # TODO: find a way to import the `discourse-org/ops` repository from the flake (and run `write-ssh-config` ??)
  #       => https://gist.github.com/arianvp/8f80c23a3410d27746fb97a6563d9677
  #       => https://discourse.nixos.org/t/43218
  # TODO: is it better to define the `SSH_AUTH_SOCK` env variable instead of using "IdentityAgent" in the SSH config?
  # TODO: investigate why `LSQuarantine` isn't working
  # TODO: figure out why it's asking for sudo password twice when running `darwin-rebuild switch`

  # Prevent power button from putting the computer to sleep
  power.sleep.allowSleepByPowerButton = false;

  system = {
    primaryUser = username;

    keyboard = {
      # Enable keyboard mapping
      enableKeyMapping = true;
      # Remap Caps Lock key to Escape
      remapCapsLockToEscape = true;
    };

    # Disable startup sound
    startup.chime = false;

    # Used for backwards compatibility, please read the changelog before changing.
    stateVersion = 5;
  };

  # Enable Touch ID authentication for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Configure Nix package manager
  nix.settings = {
    # Enable flakes and nix command
    experimental-features = ["nix-command" "flakes"];
    # Disable warning about dirty git state
    warn-dirty = false;
    # Always show error traces
    show-trace = true;
    # Add user to trusted users list
    trusted-users = [ username ];
  };

  # ARM-based Apple Silicon
  nixpkgs.hostPlatform = "aarch64-darwin";

  # macOS System Preferences
  system.defaults = {
    # user preferences
    CustomUserPreferences = {
      # Set accent color to orange
      ".GlobalPreferences".AppleAccentColor = 1;
      # Set highlight color to orange
      ".GlobalPreferences".AppleHighlightColor = "1.000000 0.874510 0.701961 Orange";
      # Enable key repeat in VSCode
      "com.microsoft.VSCode".ApplePressAndHoldEnabled = false;
      # Disable Siri
      "com.apple.assistant.support".AssistantEnabled = false;
      # Avoid creating .DS_Store files on network or USB volumes
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      # Finder settings
      "com.apple.Finder" = {
        # Don't warn when emptying the trash
        WarnOnEmptyTrash = false;
        # Empty Trash securely
        EmptyTrashSecurely = true;
      };
      # Safari settings
      # NOTE: this requires the program you run the `darwin-rebuild switch` command in
      # to have the necessary permissions in System Preferences -> Privacy -> Full Disk Access
      "com.apple.Safari" = {
        # Disable auto-fill passwords (use 1password instead)
        AutoFillPasswords = false;
        # Disable auto-opening safe downloads
        AutoOpenSafeDownloads = false;
        # Show full URL in address bar
        ShowFullURLInSmartSearchField = true;
        # Hide bookmarks bar
        ShowFavoritesBar = false;
        # Hide sidebar in top sites
        ShowSidebarInTopSites = false;
        # Suppress search suggestions
        SuppressSearchSuggestions = true;
        # Enable developer menu
        IncludeDevelopMenu = true;
        # Enable Web Inspector
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        # Enable narrow tabs
        EnableNarrowTabs = true;
      };
      # Spotlight settings
      "com.apple.Spotlight" = {
        orderedItems = [
          { enabled = 1; name = "APPLICATIONS"; }
          { enabled = 1; name = "MENU_EXPRESSION"; } # Calulator
          { enabled = 0; name = "CONTACT"; }
          { enabled = 0; name = "MENU_CONVERSION"; }
          { enabled = 0; name = "MENU_DEFINITION"; }
          { enabled = 0; name = "DOCUMENTS"; }
          { enabled = 0; name = "EVENT_TODO"; }
          { enabled = 0; name = "DIRECTORIES"; }
          { enabled = 0; name = "FONTS"; }
          { enabled = 0; name = "IMAGES"; }
          { enabled = 0; name = "MESSAGES"; }
          { enabled = 0; name = "MOVIES"; }
          { enabled = 0; name = "MUSIC"; }
          { enabled = 0; name = "MENU_OTHER"; }
          { enabled = 0; name = "PDF"; }
          { enabled = 0; name = "PRESENTATIONS"; }
          { enabled = 0; name = "MENU_SPOTLIGHT_SUGGESTIONS"; }
          { enabled = 0; name = "SPREADSHEETS"; }
          { enabled = 1; name = "SYSTEM_PREFS"; }
          { enabled = 0; name = "TIPS"; }
          { enabled = 0; name = "BOOKMARKS"; }
        ];
      };
    };

    # Dock settings
    dock = {
      # Auto-hide dock
      autohide = true;
      # Disable launch animation
      launchanim = false;
      # Hide recent apps
      show-recents = false;
      # Set dock icon size
      tilesize = 48;
      # Apps in dock (use spotlight for others)
      persistent-apps = [
        "/System/Cryptexes/App/System/Applications/Safari.app" # to avoid the "shortcut" icon
        "/Applications/Google Chrome.app"
        "/Applications/Firefox.app"
        "/Applications/Visual Studio Code.app"
        "/Applications/Spotify.app"
        "/Applications/Zed.app"
        "/Applications/Ghostty.app"
      ];
      # No folders in dock
      persistent-others = [];
      # Set (b)ottom (r)ight corner action to show desktop
      wvous-br-corner = 4;
    };

    # Control Center settings
    controlcenter = {
      # Show battery percentage
      BatteryShowPercentage = true;
      # Show Bluetooth menu
      Bluetooth = true;
      # Show sound controls
      Sound = true;
    };

    # Set trackpad to silent click
    trackpad.ActuationStrength = 0;

    # Disable showing desktop when clicking wallpaper
    WindowManager.EnableStandardClickToShowDesktop = false;

    # Disable "Are you sure you want to open this application?" dialog
    LaunchServices.LSQuarantine = false;

    # Global system settings
    NSGlobalDomain = {
      # Use 24-hour time format
      AppleICUForce24HourTime = true;
      # Dark mode
      AppleInterfaceStyle = "Dark";
      # Jump to the spot that's clicked on the scrollbar
      AppleScrollerPagingBehavior = true;
      # Always show scrollbars
      AppleShowScrollBars = "Always";
      # Short initial key repeat delay
      InitialKeyRepeat = 10;
      # Fast key repeat rate
      KeyRepeat = 1;
      # Enable full keyboard access for UI controls
      AppleKeyboardUIMode = 3;
      # Disable automatic smart dashes
      NSAutomaticDashSubstitutionEnabled = false;
      # Disable automatic smart periods
      NSAutomaticPeriodSubstitutionEnabled = false;
      # Disable automatic smart quotes
      NSAutomaticQuoteSubstitutionEnabled = false;
      # Disable window animations
      NSAutomaticWindowAnimationsEnabled = false;
      # Fast spring loading for directories
      "com.apple.springing.delay" = 0.0;
    };

    # Disable Fn key
    hitoolbox.AppleFnUsageType = "Do Nothing";

    # Finder preferences
    finder = {
      # Show all file extensions
      AppleShowAllExtensions = true;
      # Show hidden files
      AppleShowAllFiles = true;
      # Search in current folder by default
      FXDefaultSearchScope = "SCcf";
      # Disable extension change warning
      FXEnableExtensionChangeWarning = false;
      # Use list view by default
      FXPreferredViewStyle = "Nlsv";
      # Auto-remove old trash items
      FXRemoveOldTrashItems = true;
    };
  };

  system.activationScripts.extraActivation.text = lib.mkAfter ''
    # Exclude directories from Spotlight
    if [[ -d "/System/Volumes/Data/.Spotlight-V100" ]]; then
      echo 2>&1 "excluding directories from 🔍 spotlight..."

      # Find all `node_modules` directories in Dropbox
      readarray -t node_modules < <(find "${home}/Dropbox" -type d -name "node_modules" -prune)

      excluded=(
        "/Library"
        "${home}/Library"
        "${home}/Poetry"
        "''${node_modules[@]}"
      )

      sudo plutil \
        -replace Exclusions \
        -json "$(printf '%s\n' "''${excluded[@]}" | sort -u | jq -R . | jq -s .)" \
        "/System/Volumes/Data/.Spotlight-V100/VolumeConfiguration.plist"
    fi

    # Activate firewall
    echo 2>&1 "activating 🧱 firewall..."
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on --setstealthmode on
  '';

  # Homebrew package manager configuration
  homebrew = {
    # Enable homebrew
    enable = true;
    # Automatically update homebrew
    onActivation.autoUpdate = true;
    # Automatically upgrade homebrew
    onActivation.upgrade = true;
    # Automatically remove unmanaged formulae
    onActivation.cleanup = "zap";

    # CLIs
    brews = [
      "imagemagick"
      "mactop"
    ];

    # GUIs
    casks = [
      "1password"
      "1password-cli"
      "dropbox"
      "firefox"
      "ghostty"
      "google-chrome"
      "spotify"
      "tailscale"
      "visual-studio-code"
      "vlc"
      "zed"
    ];
  };

  # Define user's home directory
  users.users.${username}.home = home;

  # Home Manager Configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # User-specific configuration
    users.${username} = {
      # Enable font configuration
      fonts.fontconfig.enable = true;

      # Home configuration
      home = {
        # Set home-manager version
        stateVersion = "24.11";
        # Set username
        username = username;
        # Set home directory
        homeDirectory = home;

        # Shell aliases
        shellAliases = {
          ".."   = "cd ..";
          "..."  = "cd ../..";
          ff     = "fastfetch";
          python = "python3";
          zed    = "zeditor";
          update = "nix flake update";
          switch = "darwin-rebuild switch --flake .";
        };

        # Environment variables
        sessionVariables = {
          # Use 1Password's SSH agent
          SSH_AUTH_SOCK = "${home}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          # Disable Homebrew's hints
          HOMEBREW_NO_ENV_HINTS = 1;
          # Use GitHub's authentication token to prevent rate limiting
          NIX_CONFIG = "access-tokens = github.com=$(gh auth token)";
        };

        # Add directories to PATH
        sessionPath = [
          "/opt/homebrew/bin" # Homebrew binaries
          "${ops}/bin"        # `mothership` & `dssh`
        ];

        file = {
          # disable "Last login" message in Terminal.app
          ".hushlogin".text = "";

          # Discourse SSH config
          ".discourse/ssh_config.yml".text = ''
            username: ${username}
          '';

          # AWS config
          ".aws/config-cdck.head".text = ''
            [default]
            region=us-east-1
            mfa_serial=${aws-mfa-serial}
            mfa_process=op --account discourse item get aws --otp
            s3 =
              max_concurrent_requests = 100

            [profile discourse-sts]
          '';

          # zed's configuration
          ".config/zed/settings.json".text = ''
            {
              "auto_install_extensions": {
                "csv": true,
                "html": true,
                "nix": true,
                "ruby": true,
                "sql": true
              },
              "buffer_font_size": 14,
              "tab_size": 2,
              "terminal": {
                "font_family": "FiraCode Nerd Font"
              },
              "theme": {
                "dark": "One Dark",
                "light": "One Light",
                "mode": "system"
              },
              "ui_font_family": "FiraCode Nerd Font",
              "ui_font_size": 14,
              "vim_mode": true
            }
          '';
        };

        packages = with pkgs; [
          # HTTP client
          curl
          # https://devenv.sh
          devenv
          # better `df`
          duf
          # better `du`
          dust
          # File downloaded
          wget

          # FiraCode's Nerd Font variant
          nerd-fonts.fira-code
        ];
      };

      programs = {
        # Let Home Manager manage itself
        home-manager.enable = true;

        # Manage zsh configuration
        zsh.enable = true;
        zsh.initContent = ''
          # Lifted from /etc/zshrc_Apple_Terminal
          function update_terminal_cwd() {
            local url_path=""
            {
              local i ch hexch LC_CTYPE=C LC_COLLATE=C LC_ALL= LANG=
              for ((i = 1; i <= ''${#PWD}; ++i)); do
                ch="$PWD[i]"
                if [[ "$ch" =~ [/._~A-Za-z0-9-] ]]; then
                  url_path+="$ch"
                else
                  printf -v hexch "%02X" "'$ch"
                  url_path+="%$hexch"
                fi
              done
            }
            printf '\e]7;%s\a' "file://$HOST$url_path"
          }

          if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
            autoload -Uz add-zsh-hook
            add-zsh-hook precmd update_terminal_cwd
          fi

          # Display a warning if the terminal program needs Full Disk Access
          if [[ -n "$TERM_PROGRAM" ]] && [[ -o interactive ]] && ! [[ -r ~/Library/Application\ Support/com.apple.TCC/TCC.db ]]; then
            echo
            print -P "%F{red}%B$TERM_PROGRAM%b needs Full Disk Access for best terminal experience%f"
            print -P "👉 %F{blue}System Settings → Privacy & Security → Full Disk Access%f"
            echo
          fi
        '';

        # SSH configuration
        ssh.enable = true;
        # Compress all the things (CPU is faster than network)
        ssh.compression = true;

        # https://direnv.net
        direnv.enable = true;
        direnv.silent = true;

        # better `find` (fd)
        fd.enable = true;
        fd.ignores = [ ".git" "node_modules" "target" "vendor" ];

        # Git configuration
        git.enable = true;
        # Use `difftastic` for better diffs
        git.difftastic.enable = true;
        # Git aliases
        git.aliases = {
          b    = "branch";
          br   = "branch";
          co   = "checkout";
          st   = "status";
          wip  = "!f() { git add .; LEFTHOOK=0 git commit -n -m 'wip'; }; f";
          undo = "reset HEAD~1 --mixed";
        };
        # Global ignores - cf. https://github.com/github/gitignore
        git.ignores = [
          # https://direnv.net
          ".direnv"
          ".envrc"

          # https://devenv.sh
          ".devenv*"
          "devenv.*"

          # node
          "/node_modules/"

          # tmp
          "/tmp/"

          # vim
          "*.swp"

          # macOS
          ".DS_Store"
        ];
        # Additional git config
        git.extraConfig = {
          # Set default branch to `main`
          init.defaultBranch = "main";
          # Auto-setup remote tracking branches
          push.autoSetupRemote = true;
          # Always use SSH for GitHub
          url."ssh://git@github.com/".insteadOf = "https://github.com/";
          # Use `op-ssh-sign` for commit signing
          commit.gpgsign = true;
          gpg.format = "ssh";
          gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          # User configuration
          user = {
            name = username;
            email = email;
            signingKey = ssh-signing-key;
          };
        };

        # github CLI (gh)
        gh.enable = true;
        gh.settings = {
          git_protocol = "ssh";
          aliases = {
            co = "pr checkout";
          };
        };

        # better `cat` (bat)
        bat.enable = true;

        # better `top` (btop)
        btop.enable = true;
        btop.settings = {
          # 1s refresh rate
          update_ms = 1000;
          # navigate using hjkl
          vim_keys = true;
          # show tree view
          proc_tree = true;
          # show these disks only
          disks_filter = "/ /System/Volumes/Hardware";
        };

        # better `ls` (eza)
        eza.enable = true;
        eza.icons = "auto";

        # system info (fastfetch / ff)
        fastfetch.enable = true;

        # fuzzy finder
        fzf.enable = true;

        # JSON processor (jq)
        jq.enable = true;

        # terminal text editor (better `nano`)
        neovim.enable = true;
        neovim.defaultEditor = true;
        neovim.viAlias = true;
        neovim.vimAlias = true;

        # nix CLI helper (`nh darwin switch`)
        nh.enable = true;

        # better `grep` (rg)
        ripgrep.enable = true;

        # better `cd` (z)
        zoxide.enable = true;
      };
    };
  };
}
