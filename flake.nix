{
  description = "ZogStriP's NixOS flake.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.framezork = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      boot.loader.systemd-boot.enable = true;
    };
  };
}
