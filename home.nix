{ pkgs, lib, inputs, ... }:

{
  home.stateVersion = "25.05";

  # Allow unfree packages (needed for claude-code)
  nixpkgs.config.allowUnfree = true;

  # 1. INSTALL THE PACKAGES
  # ========================
  home.packages = with pkgs; [
    # Base essentials
    neofetch
    htop
    git

    # Development tools
    claude-code # AI coding assistant (community package with daily updates)

    # Wayland Compositor & Bar
    hyprland # Provides hypr
    waybar
    niri
    # Terminal
    kitty

    # App Launcher and Wallpaper Selector
    rofi-wayland
    
    # Wallpaper daemon
    swww

    # Notifications
    dunst

    # Screenshot tool
    swappy
    grim # swappy needs a tool to take the screenshot, grim is standard

    # Fonts for icons and style
    nerd-fonts.fira-code
    
    # Image manipulation for wallpaper thumbnails
    imagemagick
    
    # File manager with archive support
    nemo-with-extensions
    file-roller # Archive manager
    
    # Archive/compression support
    p7zip
    unzip
    unrar
    
    # Disk management
    gnome-disk-utility
  ];


  # Import matugen module
  imports = [ inputs.matugen.nixosModules.default ];

  # 2. LINK OUR NEW DOTFILES
  # ==========================
  # This tells Home Manager to create symbolic links from the files
  # we just created into the correct ~/.config/ location.
  xdg.configFile = {
    "dunst".source = ./dotfiles/dunst;
    "rofi".source = ./dotfiles/rofi;
    "hypr".source = ./dotfiles/hypr; # Modular Hyprland config with your monitor setup
    "kitty".source = ./dotfiles/kitty;
    "niri".source = ./dotfiles/niri; # Empty for now, ready for you to configure
    "swappy".source = ./dotfiles/swappy; # Empty for now
    "waybar".source = ./dotfiles/waybar;
  };

  # Enable Fish shell
  programs.fish.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Martin";  # Replace with your name
    userEmail = "martin.erman@gmail.com";  # Replace with your email
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  # Your existing bash and home-manager config
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake ~/nixos-config/#nixos";
    };
  };
  programs.home-manager.enable = true;

  # Claude Code stable link and config preservation
  home.activation.claudeStableLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.local/bin
    rm -f $HOME/.local/bin/claude
    ln -s ${pkgs.claude-code}/bin/claude $HOME/.local/bin/claude
  '';

  home.sessionPath = [ "$HOME/.local/bin" ];
  
  # Install wallpaper selector script
  home.file.".local/bin/wallpaper-selector" = {
    source = ./wallpaper-selector;
    executable = true;
  };
  
  home.activation.preserveClaudeConfig = lib.hm.dag.entryBefore ["writeBoundary"] ''
    [ -f "$HOME/.claude.json" ] && cp -p "$HOME/.claude.json" "$HOME/.claude.json.backup" || true
  '';
  
  home.activation.restoreClaudeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    [ -f "$HOME/.claude.json.backup" ] && [ ! -f "$HOME/.claude.json" ] && cp -p "$HOME/.claude.json.backup" "$HOME/.claude.json" || true
  '';

  # Matugen configuration for dynamic theming
  programs.matugen = {
    enable = true;
    variant = "dark";
    jsonFormat = "hex";
    templates = {
      kitty = {
        input_path = ./templates/kitty.conf;
        output_path = "~/.config/kitty/colors.conf";
      };
      waybar = {
        input_path = ./templates/waybar-colors.css;
        output_path = "~/.config/waybar/colors.css";
      };
      rofi = {
        input_path = ./templates/rofi-colors.rasi;
        output_path = "~/.config/rofi/colors.rasi";
      };
      hyprland = {
        input_path = ./templates/hyprland-colors.conf;
        output_path = "~/.config/hypr/colors.conf";
      };
      dunst = {
        input_path = ./templates/dunst-colors;
        output_path = "~/.config/dunst/colors.conf";
      };
    };
  };
}
