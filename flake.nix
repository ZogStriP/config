{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @ inputs : let
    hostname = "framezork";
    username = "zogstrip";
    systemVersion = "24.05";
  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs // { inherit hostname username systemVersion };
      modules = [
        ./disko.nix
        ./config.nix
      ];
    };
  };
}
