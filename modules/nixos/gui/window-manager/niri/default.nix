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
      description = "Whether to enable `niri`.";
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    modules.gui.window-manager.compositor.wayland.enable = true;

    # === Niri ===

    environment.systemPackages = with pkgs_; [
      niri

      # Include Niri's default terminal so default shortcut works
      alacritty
    ];

    xdg.portal = {
      enable = true;

      extraPortals = with pkgs_; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];

      config.common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      };
    };

    # === Niri ===


    # === UWSM ===

    programs.uwsm.waylandCompositors.niri = {
      prettyName = "Niri";
      comment = "Niri compositor managed by UWSM";
      binPath = lib.getExe (
        pkgs_.writeShellScriptBin "niri-instance" ''
          exec ${pkgs_.niri}/bin/niri-session
        ''
      );
    };

    # === UWSM ===
  };
  # === Config ===
}
