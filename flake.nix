{
  description = "Nix configuration with flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf.url = "github:notashelf/nvf";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
            inputs.sops-nix.nixosModules.sops
            ./hosts/${host.dir}/configuration.nix
            { nixpkgs.overlays = overlays; }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.users."${host.user.username}" = import ./hosts/${host.dir}/home.nix;
              home-manager.sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ] ++ homeManagerModules;
            }
          ] ++ modules;
        };

      # mkOverlayFromUnstable = pkgNames:
      #   map (name: (final: prev: {
      #     ${name} = (import inputs.nixpkgs-unstable {
      #         inherit (final) system;
      #         config = {
      #           allowUnfree = true;
      #         };
      #     }).${name};
      # })) pkgNames;

      unstableOverlay = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      };

      neovimOverlay = (
        final: prev: {
          neovimWrapped = (inputs.nvf.lib.neovimConfiguration {
            pkgs = final.unstable;
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
        homeManagerModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
        overlays = [ neovimOverlay unstableOverlay ];
      };

      # Mainframe config
      nixosConfigurations."${hosts.mainframe.hostname}" = mkNixOSConfigurations {
        host = hosts.mainframe;
        nixpkgs = inputs.nixpkgs;
        home-manager = inputs.home-manager;
        modules = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
        overlays = [ neovimOverlay unstableOverlay inputs.nix-minecraft.overlay ];
      };

      # Sample config for non nix-os systems using home manager
      # homeConfigurations."${hosts.<host>.user}@${hosts.<host>.hostname}" = mkHomeConfigurations {
      #   host = hosts.<host>;
      #   nixpkgs = inputs.nixpkgs;
      #   home-manager = inputs.home-manager;
      # };
    };
}
