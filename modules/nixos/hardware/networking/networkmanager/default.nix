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


  # Registered by whichever wireless module is enabled, `null` if none is
  wirelessBackend = moduleTreeConfig.hardware.networking.wireless.backend;
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = ''
        Whether to enable `NetworkManager` as the networking backend.

        Wireless is left to a module under `wireless`. Without one the
        `networking` module turns it off, rather than `NetworkManager` falling
        back to `wpa_supplicant`.
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


      # Point at whichever wireless module registered
      wifi.backend = lib.mkIf (wirelessBackend != null) (wirelessBackend);
      wifi.powersave = false;
    };

    # Register with the `networking` module
    ${moduleTreeName}.hardware.networking.backends = [ "networkmanager" ];
  };
  # === Config ===
}
