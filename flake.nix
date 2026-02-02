{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs?ref=master";
  };

  outputs = { self, nixpkgs, nixpkgs-master }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        pkgsMaster = import nixpkgs-master {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [ 
        ./configuration.nix
      ];
    };
  };
}
