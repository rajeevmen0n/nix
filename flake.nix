{
  description = "Nix configuration with flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf.url = "github:notashelf/nvf";
  };

  outputs =
    {
      self,
      ...
    }@inputs:

    let
      hosts = import ./config/hosts.nix;

      mkHomeConfigurations =
        {
          host,
          nixpkgs,
          home-manager,
          modules ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = host.arch;
            config = {
              allowUnfree = true;
            };
          };
          modules = [
            ./hosts/${host.dir}/home.nix
          ] ++ modules;
        };

      mkNixOSConfigurations =
        {
          host,
          nixpkgs,
          home-manager,
          modules ? [ ]
        }:
        nixpkgs.lib.nixosSystem {
          system = host.arch;
          modules = [
            ./hosts/${host.dir}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users."${host.user.username}" = import ./hosts/${host.dir}/home.nix;
            }
          ] ++ modules;
        };

    in

    {
      # Neovim setup
      packages.x86_64-linux.neovim = 
        (inputs.nvf.lib.neovimConfiguration {
          pkgs = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
          modules = [ ./config/nvim/nvf.nix ];
        }).neovim;

      # Laptop NixOS config
      nixosConfigurations."${hosts.laptop-nixos.hostname}" = mkNixOSConfigurations {
        host = hosts.laptop-nixos;
        nixpkgs = inputs.nixpkgs;
        home-manager = inputs.home-manager;
        modules = [({pkgs, ...}: {
          environment.systemPackages = [self.packages.${hosts.laptop-nixos.arch}.neovim];
        })];
      };

      # Sample config for non nix-os systems using home manager
      # homeConfigurations."${hosts.<host>.user}@${hosts.<host>.hostname}" = mkHomeConfigurations {
      #   host = hosts.<host>;
      #   nixpkgs = inputs.nixpkgs;
      #   home-manager = inputs.home-manager;
      # };
    };
}