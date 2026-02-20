{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs?ref=master";
    handy = {
      url = "github:cjpais/Handy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-master, handy, ... }:
    let
      system = "x86_64-linux";
      hostname = "mbrieger-t14s-gen3";
      nixpkgsConfig = {
        allowUnfree = true;
      };
    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.config = nixpkgsConfig; }
          ./configuration.nix
        ];
        specialArgs = {
          inherit hostname;
          pkgsMaster = import nixpkgs-master {
            inherit system;
            config = nixpkgsConfig;
          };
          pkgsHandy = handy.packages.${system};
        };
      };
    };
}
