{ impermanence, username, ... } : {
  imports = [ impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    hideMounts = true;

    # required system directories
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/fprint/${username}" # fingerprints
      "/var/lib/iwd" # WiFi connections
    ];

    # required system files
    files = [
      "/etc/machine-id"
    ];

    users.${username} = {
      # required user directories
      directories = [
        ".config/1Password"
        ".local/share/atuin" # command lines database
        ".local/share/zoxide" # command lines history
        ".local/share/Zeal" # where zeal stores docsets
        ".cache/Zeal" # tmp files
        ".ssh"
      ];
    };
  };

  # Create a persisted "home" directory for `zogstrip`
  systemd.tmpfiles.rules = [ "d /persist/z 0700 ${username} ${username} -" ];
}
