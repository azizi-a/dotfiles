{
  description = "azizi-a NixOS + Home Manager configuration";

  inputs = {
    # 26.05 "Yarara" is the current stable release. Swap for
    # "github:NixOS/nixpkgs/nixos-unstable" if you want rolling.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware quirk modules. Tracks master rather than a release branch
    # because it has no nixpkgs dependency of its own and fixes land there
    # first. Imported per-host, in hosts/laptop/default.nix.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      # Single source of truth for identity. Referenced by both the NixOS
      # modules and the Home Manager modules via specialArgs.
      user = {
        name = "azizi";
        fullName = "Azizi";
        email = "64193693+azizi-a@users.noreply.github.com";
      };
    in
    {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs user; };

        modules = [
          ./hosts/laptop

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # Renames any pre-existing dotfile that HM wants to own,
              # rather than refusing to activate. Handy during migration.
              backupFileExtension = "hm-bak";
              extraSpecialArgs = { inherit inputs user; };
              users.${user.name} = import ./modules/home;
            };
          }
        ];
      };

      # Convenience: `nix fmt`
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
