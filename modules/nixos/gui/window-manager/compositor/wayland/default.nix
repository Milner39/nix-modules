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
      description = "Whether to enable shared `wayland` settings.";
      default = false;
      type = lib.types.bool;
    };

    "tools"."enable" = lib.mkOption {
      description = ''
        Enable Wayland inspection and diagnostic tools:
        `wayland-info` (from `wayland-utils`), for compositor capabilities,
        `wev`, for input events,
        `libinput`, for `debug-events` and `list-devices`,
        `wlr-randr`, for output layout,
        `xwayland-satellite`, rootless X for compositors without their own.
      '';
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    # === Wayland ===

     # X11 compatibility
    programs.xwayland = {
      enable = true;
      package = pkgs_.xwayland.override {
        inherit (configRoot.programs.xwayland) defaultFontPath;
      };
    };

    environment.systemPackages = lib.optionals cfg.tools.enable (with pkgs_; [
      wayland-utils
      wev
      libinput
      wlr-randr
      xwayland-satellite
    ]);

    # Tell electron apps to use Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Prioritise Wayland, fallback to X11
    environment.sessionVariables.QT_QPA_PLATFORM = "wayland;xcb";

    # === Wayland ===


    # === UWSM ===

    programs.uwsm = {
      enable = true;
      package = pkgs_.uwsm;
    };

    # === UWSM ===


    # === Hyprlock ===

    # programs.hyprlock = {
    #   enable = true;
    #   package = pkgs_.hyprlock;
    # };
    #
    # # Let Hyprlock use PAM
    # security.pam.services.hyprlock = {};

    # === Hyprlock ===



    # === NVIDIA Fixes ===

    # Needed for Wayland
    hardware.nvidia.modesetting.enable = true;

    # Fix mouse flickering
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

    # === NVIDIA Fixes ===
  };
  # === Config ===
}
