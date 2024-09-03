{ impermanence, username, ... } : {
  imports = [ impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
    ];

    files = [
      "/etc/machine-id"
    ];
  };

  systemd.tmpfiles.rules = [
    # Create a persisted "home" directory for `zogstrip`
    "d /persist/z 0700 ${username} ${username} -"
  ];
}
