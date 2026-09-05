{
  configRoot,
  moduleConfig,
  moduleTreeConfig,
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


  # Registered by whichever wireless module is enabled, `null` if none is
  wirelessBackend = moduleTreeConfig.hardware.networking.wireless.backend;
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = ''
        Whether to enable `NetworkManager` as the networking backend.

        This drives wireless itself, through `wpa_supplicant` by default. 
        Enabling a wireless module switches it to that daemon instead.
      '';
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      package = pkgs_.networkmanager;


      # `wpa_supplicant by default`
      wifi.backend = lib.mkIf (wirelessBackend != null) (wirelessBackend);
      wifi.powersave = false;
    };

    # Register with the `networking` module
    ${optionTreeName}.hardware.networking.backends = [ "networkmanager" ];
  };
  # === Config ===
}
