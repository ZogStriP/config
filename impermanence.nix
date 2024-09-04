{ impermanence, username, ... } : {
  imports = [ impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    hideMounts = true;

    # required system directories
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
    ];

    # required system files
    files = [
      "/etc/machine-id"
    ];

    users.${username} = {
      # required user directories
      directories = [
        ".local/share/atuin"
        ".local/share/zoxide"
        ".config/1Password"
      ];

      # require user files
      files = [
        ".ssh/known_hosts"
      ];
    };
  };

  # Create a persisted "home" directory for `zogstrip`
  systemd.tmpfiles.rules = [ "d /persist/z 0700 ${username} ${username} -" ];
}
