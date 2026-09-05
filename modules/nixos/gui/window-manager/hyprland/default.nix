{
  configRoot,
  moduleConfig,
  moduleTreeName,
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
    ${moduleTreeName}.gui.window-manager.compositor.wayland.enable = true;

    # === Hyprland ===

    programs.hyprland = {
      enable = true;
      package = pkgs_.hyprland;
      portalPackage = pkgs_.xdg-desktop-portal-hyprland;
    };

    # === Hyprland ===


    # === UWSM ===

    programs.uwsm.waylandCompositors.hyprland = {
      prettyName = "Hyprland";
      comment = "Hyprland compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/Hyprland";
    };

    # === UWSM ===
  };
  # === Config ===
}
