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
      "/var/lib/tailscale"
    ];

    # required system files
    files = [
      "/etc/machine-id"
    ];

    users.${username} = {
      # required user directories
      directories = [
        ".cache"
        ".cargo"
        ".config/1Password"
        ".config/gh"
        # TODO: figure out why this doesn't work
        # { directory = ".config/op"; mode = "0700"; }
        ".local/share"
        ".mozilla"
        ".ssh"
      ];
      # required user files
      files = [
        ".claude.json"
      ];
    };
  };

  systemd.tmpfiles.rules = [ 
    "d /persist/z 0700 ${username} ${username} -" # create a persisted "home" directory for `zogstrip`
  ];
}
