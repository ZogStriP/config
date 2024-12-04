{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    hm.url = "github:nix-community/home-manager";
    hm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { darwin, ... } @ inputs : {
    darwinConfigurations.zMacBookPro = darwin.lib.darwinSystem {
      specialArgs = inputs;
      modules = [ ./config.nix ];
    };
  };
}
