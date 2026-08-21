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

  _pkgs = pkgs-unstable;
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = ''
        Whether to enable custom screenshot setup using 
        `grim`, `slurp`, and `wl-clipboard`
      '';
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    home.packages = with _pkgs; [
      grim
      slurp
      wl-clipboard
    ];
  };
  # === Config ===
}
