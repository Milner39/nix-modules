{
  configRoot,
  moduleConfig,
  optionTreeName,
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
      description = "Whether to enable `sway`.";
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    ${optionTreeName}.gui.window-manager.compositor.wayland.enable = true;

    # === Sway ===

    programs.sway = {
      enable = true;
      package = pkgs_.sway;

      # By default this installs the programs `sway`'s own default config
      # expects: a lock screen, idle daemon, terminal, menu, screenshot tool
      # and more.
      extraPackages = [];
    };

    # === Sway ===


    # === UWSM ===

    programs.uwsm.waylandCompositors.sway = {
      prettyName = "Sway";
      comment = "Sway compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/sway";
    };

    # === UWSM ===
  };
  # === Config ===
}
