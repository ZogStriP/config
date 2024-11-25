{ pkgs, ... } : {
  systemd.services.luciole = {
    wantedBy = [ "fprintd.service" ];
    description = "changes the power LED color based on fprintd events";
    serviceConfig = {
      User = "root";
      ExecStart = pkgs.writeShellScript "luciole" ''
        declare -A COLORS=(
          [default]="0 0 0 0 1 0" # white
          [scan]="0 0 0 0 0 1"    # amber
          [success]="0 1 0 0 0 0" # green
          [fail]="1 0 0 0 0 0"    # red
        )

        brightness() {
          echo $1 > /sys/class/leds/chromeos:multicolor:power/brightness
        }

        color() {
          echo "''${COLORS[$1]}" > /sys/class/leds/chromeos:multicolor:power/multi_intensity
        }

        reset() {
          echo chromeos-auto > /sys/class/leds/chromeos:multicolor:power/trigger
        }

        trap 'reset' EXIT

        brightness 100
        color default

        ${pkgs.dbus}/bin/dbus-monitor --system "interface='net.reactivated.Fprint.Device'" | while IFS= read -r line; do
          if [[ $line == *"member=VerifyFingerSelected"* ]]; then
            color scan
          elif [[ $line == *"member=VerifyStatus"* ]]; then
            read -r result

            if [[ $result == *"verify-match"* ]]; then
              color success
            else
              color fail
            fi

            sleep 0.3

            color default
          fi
        done
      '';
    };
  };
}
