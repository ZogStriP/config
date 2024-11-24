{ pkgs, ... } : {
  security.wrappers.power-led = {
    setuid = true;
    owner = "root";
    group = "root";
    source = pkgs.writeScript "power-led" ''
      #!${pkgs.bash}/bin/bash -p
      echo $2 > /sys/class/leds/chromeos:multicolor:power/$1
    '';
  };
}
