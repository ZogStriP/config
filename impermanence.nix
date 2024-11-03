{ impermanence, username, ... } : {
  imports = [ impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    hideMounts = true;

    # required system directories
    directories = [
      "/var/lib/bluetooth" # bluetooth pairings
      "/var/lib/fprint/${username}" # fingerprints
      "/var/lib/iwd" # WiFi connections
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/tailscale" # tailscale
    ];

    # required system files
    files = [
      # "/etc/machine-id"
    ];

    users.${username} = {
      # required user directories
      directories = [
        ".cache/Zeal" # Zeal's tmp files
        ".cache/direnv"
        ".cache/nix" # Nix's tmp files
        ".cargo"
        ".config/1Password"
        ".local/share/Zeal" # Zeal's docsets
        ".local/share/devenv"
        ".local/share/direnv" # direnv.sh allowed directories
        ".local/share/fish" # fish
        ".local/share/zoxide" # command lines history
        ".mozilla" # firefox
        ".ssh"
      ];
    };
  };

  systemd.tmpfiles.rules = [ 
    "d /persist/z 0700 ${username} ${username} -" # create a persisted "home" directory for `zogstrip`
    "L /etc/machine-id - - - - /persist/etc/machine-id" # TODO: workaround for https://github.com/NixOS/nixpkgs/pull/351151
  ];
}
