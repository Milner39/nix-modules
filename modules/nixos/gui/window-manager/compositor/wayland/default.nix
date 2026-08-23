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
      description = "Whether to enable general `wayland` settings.";
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs_; [
      # X11 compatibility
      xwayland
      xwayland-satellite

      # Wayland inspection/debugging
      wayland-utils
      wev

      # Input devices
      libinput

      # Screens / outputs
      wlr-randr
    ];


    # Tell electron apps to use Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Prioritise Wayland, fallback to X11
    environment.sessionVariables.QT_QPA_PLATFORM = "wayland;xcb";


    # === Hyprlock ===

    programs.hyprlock = {
      enable = true;
      package = pkgs_.hyprlock;
    };

    # Let Hyprlock use PAM
    security.pam.services.hyprlock = {};

    # === Hyprlock ===


    # === UWSM ===

    programs.uwsm = {
      enable = true;
      package = pkgs_.uwsm;
    };

    # === UWSM ===


    # === NVIDIA Fixes ===

    # Needed for Wayland
    hardware.nvidia.modesetting.enable = true;

    # Fix mouse flickering
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

    # === NVIDIA Fixes ===
  };
  # === Config ===
}
