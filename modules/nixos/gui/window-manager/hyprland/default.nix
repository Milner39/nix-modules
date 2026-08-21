{
  configRoot,
  moduleConfig,
  lib,
  pkgs,
  pkgs-unstable,
  ...
} @ args:

let
  # Get module configuration
  cfg = moduleConfig;

  pkgs_ = pkgs;
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = "Whether to enable `hyprland`.";
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    modules.gui.window-manager.compositor.wayland.enable = true;

    # === Hyprland ===

    programs.hyprland = {
      enable = true;
      package = pkgs_.hyprland;
      portalPackage = pkgs_.xdg-desktop-portal-hyprland;

      # Because NixOS uses SystemD so use UWSM for better support
      withUWSM = true;
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [];


    # Include Hyprland's default terminal so default shortcut works
    environment.systemPackages = [ pkgs_.kitty ];

    # === Hyprland ===


    # === Hyprlock ===

    programs.hyprlock = {
      enable = true;
      package = pkgs_.hyprlock;
    };

    # Let Hyprlock use PAM
    security.pam.services.hyprlock = {};

    # === Hyprlock ===
  };
  # === Config ===
}
