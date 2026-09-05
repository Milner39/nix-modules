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
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = ''
        Whether to enable `systemd-networkd` as the networking backend.
      '';
      default = false;
      type = lib.types.bool;
    };

    "dhcp"."enable" = lib.mkOption {
      description = ''
        Configure every interface without a static address by DHCP.
      '';
      default = true;
      type = lib.types.bool;
    };


    "waitOnline"."enable" = lib.mkOption {
      description = ''
        Hold `network-online.target` until a link has an address.

        Services ordered after that target then start with the network up, at
        the cost of a failed unit when nothing comes up before `timeout`.
      '';
      default = true;
      type = lib.types.bool;
    };

    "waitOnline"."anyInterface" = lib.mkOption {
      description = ''
        Treat the system as online at the first link up, rather than the last.
      '';
      default = true;
      type = lib.types.bool;
    };

    "waitOnline"."timeout" = lib.mkOption {
      description = ''
        Seconds to wait before giving up, `0` to wait forever.

        Boot stalls for this long when no link comes up.
      '';
      default = 120;
      type = lib.types.ints.unsigned;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    # Sets `systemd.network.enable` and disables `networking.dhcpcd` as
    # networkd has its own DHCP client
    networking.useNetworkd = true;
    networking.useDHCP = lib.mkDefault cfg.dhcp.enable;

    systemd.network.wait-online = {
      enable = cfg.waitOnline.enable;
      anyInterface = cfg.waitOnline.anyInterface;
      timeout = cfg.waitOnline.timeout;
    };

    # Register with the `networking` module
    ${optionTreeName}.hardware.networking.backends = [ "networkd" ];
  };
  # === Config ===
}
