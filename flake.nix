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
    # First, import the common settings
    ./hosts/common.nix

    # Then, import the machine-specific settings
    ./hosts/nixos-vm/configuration.nix

    # Your home-manager config is already shared!
    home-manager.nixosModules.home-manager
    {
      home-manager.users.martin = import ./home.nix;
      # ...
    }
  ];
};

    # --- FUTURE MACHINES (template) ---

    # 2. Configuration for your Main PC
    # This is commented out. Uncomment it when you are ready to add your main PC.
    /*
    nixosConfigurations."main-pc" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # It will also use the common settings
        ./hosts/common.nix

        # It will have its own machine-specific settings
        ./hosts/main-pc/configuration.nix

        # And it will share your same home-manager configuration
        home-manager.nixosModules.home-manager {
          home-manager.users.martin = import ./home.nix;
        }
      ];
    };
    */
  };
}
