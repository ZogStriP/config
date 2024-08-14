{
  description = "ZogStriP's NixOS flake.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... } @ inputs : {
    nixosConfigurations.framezork = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialAttrs = inputs;
      modules = [
        ./disko.nix
        ./config.nix
      ];
    };
  };
}
