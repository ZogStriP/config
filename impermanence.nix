{ impermanence, username, ... } : {
  imports = [ impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    hideMounts = true;

    # required system directories
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/fprint/${username}"
    ];

    # required system files
    files = [
      "/etc/machine-id"
    ];

    users.${username} = {
      # required user directories
      directories = [
        ".config/1Password"
        ".local/share/atuin"
        ".local/share/zoxide"
        ".ssh"
      ];
    };
  };

  # Create a persisted "home" directory for `zogstrip`
  systemd.tmpfiles.rules = [ "d /persist/z 0700 ${username} ${username} -" ];
}
