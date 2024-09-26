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
      "/etc/machine-id"
    ];

    users.${username} = {
      # required user directories
      directories = [
        ".cache/Zeal" # Zeal's tmp files
        ".cache/nix" # Nix's tmp files
        ".cache/direnv"
        ".config/1Password"
        ".local/share/Zeal" # Zeal's docsets
        ".local/share/atuin" # command lines database
        ".local/share/direnv" # direnv.sh allowed directories
        ".local/share/devenv"
        ".local/share/zoxide" # command lines history
        ".ssh"
      ];
    };
  };

  # Create a persisted "home" directory for `zogstrip`
  systemd.tmpfiles.rules = [ "d /persist/z 0700 ${username} ${username} -" ];
}
