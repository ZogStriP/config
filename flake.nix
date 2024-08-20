{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @ inputs : {
    nixosConfigurations.framezork = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = inputs // {
        hostname = "framezork";
        username = "zogstrip";
        stateVersion = "24.11";
      };

      modules = [
        ./disko.nix
        ./impermanence.nix
        ./home.nix
        ./config.nix
      ];
    };
  };
}
