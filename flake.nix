{
  description = "My Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    matugen.url = "github:InioX/matugen";
    claude-code.url = "github:sadjow/claude-code-nix";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, home-manager, matugen, claude-code, ... }@inputs:
    let
      username = "martin";
      hostDirs = nixpkgs.lib.attrNames (nixpkgs.lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./hosts));
      mkHost = host: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs username; };
        modules = [
          { nixpkgs.overlays = [ claude-code.overlays.default ]; }
          ./hosts/common.nix
          ./hosts/${host}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.${username} = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit inputs username; hostName = host; };
          }
        ];
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hostDirs mkHost;
      checks = nixpkgs.lib.genAttrs hostDirs (h: {
        build = self.nixosConfigurations.${h}.config.system.build.toplevel;
      });
    };
}
