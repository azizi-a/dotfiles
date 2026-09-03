{
  description = "azizi-a NixOS + Home Manager configuration";

  inputs = {
    # nixos-unstable for rolling.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # master rather than a release branch: no nixpkgs dependency of its
    # own, and fixes land there first. Imported per-host.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      # Reaches both module trees via specialArgs.
      user = {
        name = "azizi";
        fullName = "Azizi";
        email = "64193693+azizi-a@users.noreply.github.com";
      };
    in
    {
      nixosConfigurations.nixos-laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs user; };

        modules = [
          ./hosts/laptop

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # Rename rather than refuse to activate on a clash.
              backupFileExtension = "hm-bak";
              extraSpecialArgs = { inherit inputs user; };
              users.${user.name} = import ./modules/home;
            };
          }
        ];
      };

      # Convenience: `nix fmt`
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
    };
}
