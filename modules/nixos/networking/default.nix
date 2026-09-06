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



  noWireless = cfg.backend.enabled != [] && cfg.wireless.backend == null;
  noWirelessPriority = 90;
in
{
  # === Config ===
  config = {
    networking = lib.mkIf noWireless {
      wireless.enable = lib.mkOverride noWirelessPriority false;

      # Tell `networkmanager` to ignore wifi
      networkmanager.unmanaged = [ "type:wifi" ];
    };
  };
  # === Config ===
}
