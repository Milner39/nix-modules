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

    # Add X11 fallback
    environment.systemPackages = [ pkgs.xwayland ];


    # Tell electron apps to use Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Prioritise Wayland, fallback to X11
    environment.sessionVariables.QT_QPA_PLATFORM = "wayland;xcb";


    # === NVIDIA Fixes ===

    # Needed for Wayland
    hardware.nvidia.modesetting.enable = true;

    # Fix mouse flickering
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

    # === NVIDIA Fixes ===
  };
  # === Config ===
}
