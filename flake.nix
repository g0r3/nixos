{
  description = "";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";

      # 👇 Define pkgs with allowUnfree = true here
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    in
    {

      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; }; # Pass inputs to modules
          modules = [
            # This is the main entry point for the desktop configuration
            ./machines/desktop/configuration.nix
          ];
        };
        work-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/work-laptop/configuration.nix
          ];
        };
        arr = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/homelab/arr/configuration.nix
          ];
        };
      };
    };
}
