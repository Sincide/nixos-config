{ pkgs, lib, ... }:

{
  home.stateVersion = "25.05";

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

    # App Launcher
    fuzzel

    # Notifications
    dunst

    # Screenshot tool
    swappy
    grim # swappy needs a tool to take the screenshot, grim is standard

    # Fonts for icons and style
    nerd-fonts.fira-code
  ];


  # 2. LINK OUR NEW DOTFILES
  # ==========================
  # This tells Home Manager to create symbolic links from the files
  # we just created into the correct ~/.config/ location.
  xdg.configFile = {
    "dunst".source = ./dotfiles/dunst;
    "fuzzel".source = ./dotfiles/fuzzel; # Fuzzel uses its default config if this is empty
    "hypr".source = ./dotfiles/hypr;
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
  
  home.activation.preserveClaudeConfig = lib.hm.dag.entryBefore ["writeBoundary"] ''
    [ -f "$HOME/.claude.json" ] && cp -p "$HOME/.claude.json" "$HOME/.claude.json.backup" || true
  '';
  
  home.activation.restoreClaudeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    [ -f "$HOME/.claude.json.backup" ] && [ ! -f "$HOME/.claude.json" ] && cp -p "$HOME/.claude.json.backup" "$HOME/.claude.json" || true
  '';
}
