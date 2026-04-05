{
  description = "";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      nix-homebrew,
      ...
    }@inputs:
    let
      sharedConfig = {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = [
          (final: prev: {
            claude-code = final.callPackage ./packages/claude-code { };
          })
        ];
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      mkNixSystem =
        machine:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            isLinux = true;
            isDarwin = false;
          };
          modules = [
            machine
            sharedConfig
          ];
        };

      mkDarwinSystem =
        machine:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            isLinux = false;
            isDarwin = true;
          };
          modules = [
            machine
            sharedConfig
          ];
        };
    in
    {
      nixosConfigurations = {
        desktop = mkNixSystem ./machines/desktop/configuration.nix;
        ENG-rstaudacher = mkNixSystem ./machines/ENG-rstaudacher/configuration.nix;
        # arr = mkNixSystem ./machines/homelab/arr/configuration.nix;
      };
      darwinConfigurations = {
        mbp = mkDarwinSystem ./machines/mbp/configuration.nix;
      };
    };
}
