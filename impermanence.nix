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
        ".cache"
        ".cargo"
        ".config/1Password"
        ".local/share"
        ".mozilla"
        ".ssh"
      ];
    };
  };

  systemd.tmpfiles.rules = [ 
    "d /persist/z 0700 ${username} ${username} -" # create a persisted "home" directory for `zogstrip`
    "L /etc/machine-id - - - - /persist/etc/machine-id" # TODO: workaround for https://github.com/NixOS/nixpkgs/pull/351151
  ];
}
