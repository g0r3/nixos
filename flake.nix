{
  description = "Recreating my desktop before moving to it";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    dotfiles = {
      url = "git+ssh://git@github.com/g0r3/dotfiles.git";
      flake = false; # This is not a flake itself, just a collection of files.
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # Pass inputs to modules
      modules = [
        # This is the main entry point for the desktop configuration
        ./machines/desktop/configuration.nix
      ];
    };
  };
}
