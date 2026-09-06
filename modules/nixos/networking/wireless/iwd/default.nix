{
  configRoot,
  moduleConfig,
  moduleTreeConfig,
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
      description = ''
        Whether to enable `iwd` as the wireless backend.

        Networks are remembered by `iwd` in `/var/lib/iwd`.
      '';
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    networking.wireless.iwd = {
      enable = true;
      package = pkgs_.iwd;
    };

    # Register with the `wireless` module
    ${moduleTreeName}.networking.wireless.backend = "iwd";
  };
  # === Config ===
}
