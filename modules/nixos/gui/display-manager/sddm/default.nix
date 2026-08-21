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

  pkg = pkgs.kdePackages.sddm;
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = "Whether to enable `sddm`.";
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      package = pkg;

      # # Enable support for Wayland
      # wayland.enable = true;
      # wayland.compositor = "weston";
    };

    # NOTE: As of nixpkgs 26.05, required for mouse input (annoying)
    # Uncomment lines above when fix exists
    services.xserver.enable = lib.mkForce true;
  };
  # === Config ===
}
