{
  description = "NixOS Configuration with Hyprland/Niri and Dynamic Theming";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Essential for dynamic theming
    matugen.url = "github:InioX/matugen";
    
    # Optional: AI coding assistant
    claude-code.url = "github:sadjow/claude-code-nix";
    
    # Optional: for impermanence setups
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, home-manager, matugen, claude-code, impermanence, ... }@inputs:
    let
      username = "martin";
      
      # Safe directory reading with error handling
      hostDirs = 
        let
          hostsPath = ./hosts;
        in
        if builtins.pathExists hostsPath
        then nixpkgs.lib.attrNames (nixpkgs.lib.filterAttrs (_: v: v == "directory") (builtins.readDir hostsPath))
        else [ "nixos" ]; # fallback to default host
      
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
            home-manager.extraSpecialArgs = { 
              inherit inputs username; 
              hostName = host;
            };
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
