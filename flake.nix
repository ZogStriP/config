{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @ inputs : {
    nixosConfigurations.framezork = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = inputs // {
        hostname = "framezork";
        username = "zogstrip";
        stateVersion = "24.05";
      };

      modules = [
        ./disko.nix
        ./config.nix
      ];
    };
  };
}
