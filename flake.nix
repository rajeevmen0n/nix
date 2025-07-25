{
  description = "Nix configuration with flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nvf.url = "github:notashelf/nvf";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      ...
    }@inputs:

    let
      hosts = import ./config/hosts.nix;

      # mkHomeConfigurations =
      #   {
      #     host,
      #     nixpkgs,
      #     home-manager,
      #     modules ? [ ],
      #   }:
      #   home-manager.lib.homeManagerConfiguration {
      #     pkgs = import nixpkgs {
      #       system = host.arch;
      #       config = {
      #         allowUnfree = true;
      #       };
      #     };
      #     modules = [
      #       ./hosts/${host.dir}/home.nix
      #     ] ++ modules;
      #   };

      mkNixOSConfigurations =
        {
          host,
          nixpkgs,
          home-manager,
          modules ? [ ],
          homeManagerModules ? [ ],
          overlays ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          system = host.arch;
          modules = [
            ./hosts/${host.dir}/configuration.nix
            { nixpkgs.overlays = overlays; }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users."${host.user.username}" = import ./hosts/${host.dir}/home.nix;
              home-manager.sharedModules = homeManagerModules;
            }
          ] ++ modules;
        };

      mkOverlayFromUnstable = pkgNames:
        map (name: (final: prev: {
          ${name} = (import inputs.nixpkgs-unstable {
              inherit (final) system;
              config = {
                allowUnfree = true;
              };
          }).${name};
      })) pkgNames;

      unstableOverlay = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.system;
          config.allowUnfree = true;
        };
      };

      neovimOverlay = (
        final: prev: {
          neovimWrapped = (inputs.nvf.lib.neovimConfiguration {
            pkgs = inputs.nixpkgs-unstable.legacyPackages.${final.system};
            modules = [ ./config/nvim/nvf.nix ];
          }).neovim;
        }
      );

    in

    {
      # Laptop NixOS config
      nixosConfigurations."${hosts.ga605wi.hostname}" = mkNixOSConfigurations {
        host = hosts.ga605wi;
        nixpkgs = inputs.nixpkgs;
        home-manager = inputs.home-manager;
        modules = [ inputs.lanzaboote.nixosModules.lanzaboote ];
        homeManagerModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
        overlays = [ neovimOverlay unstableOverlay ];
      };

      # Mainframe config
      nixosConfigurations."${hosts.mainframe.hostname}" = mkNixOSConfigurations {
        host = hosts.mainframe;
        nixpkgs = inputs.nixpkgs;
        home-manager = inputs.home-manager;
        overlays = [ neovimOverlay unstableOverlay ];
      };

      # Sample config for non nix-os systems using home manager
      # homeConfigurations."${hosts.<host>.user}@${hosts.<host>.hostname}" = mkHomeConfigurations {
      #   host = hosts.<host>;
      #   nixpkgs = inputs.nixpkgs;
      #   home-manager = inputs.home-manager;
      # };
    };
}
