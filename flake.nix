{
  description = "My Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # Configuration for the Virtual Machine
    nixosConfigurations."nixos-vm" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };

      modules = [
        # Path to the VM's specific configuration
        ./hosts/nixos-vm/configuration.nix

        # Your home-manager config is shared!
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # ==> REPLACE 'your_username' with your actual username <==
          home-manager.users.martin = import ./home.nix;
        }
      ];
    };

    # --- How to add your main machine later ---
    # 1. Create a folder: hosts/main-machine
    # 2. Add its configuration.nix and hardware-configuration.nix
    # 3. Uncomment and adapt the following block:
    #
    # nixosConfigurations."main-machine" = nixpkgs.lib.nixosSystem {
    #   system = "x86_64-linux";
    #   specialArgs = { inherit inputs; };
    #   modules = [
    #     ./hosts/main-machine/configuration.nix
    #     home-manager.nixosModules.home-manager {
    #       home-manager.users.martin = import ./home.nix;
    #     }
    #   ];
    # };
  };
}
