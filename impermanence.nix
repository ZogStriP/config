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

  # Create a persisted "home" directory for `zogstrip`
  systemd.tmpfiles.rules = [ "d /persist/z 0700 ${username} ${username} -" ];
}
