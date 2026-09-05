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

  firmwarePriority = 500;
in
{
  # === Options ===
  options = {
    "backend" = lib.mkOption {
      description = ''
        Names of the enabled wireless backends.

        Wireless modules under this one register themselves here.

        Set by the wireless modules. Not intended to be set by hand.
      '';
      default = null;
      type = lib.types.nullOr (lib.types.enum [ "wpa_supplicant" "iwd" ]);
    };

    "firmware"."enable" = lib.mkOption {
      description = ''
        Install the redistributable firmware a wireless radio needs to run.

        Turn it off for a host that gets firmware elsewhere, such as from a
        `nixos-hardware` profile, or one whose radio needs unfree firmware
        through `hardware.enableAllFirmware`. Off leaves the option alone
        rather than forcing it off.
      '';
      default = true;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf (cfg.backend != null) {
    /*
      Without `wireless-regdb` the kernel falls back to the world domain, which 
      is the most restrictive:
      Fewer channels at lower power, so an access point on a channel legal 
      where the host is geographically may not be seen.
    */
    hardware.wirelessRegulatoryDatabase = true;

    /*
      `mkIf` so turning it off leaves the option to whatever else sets it.

      Priority beats the `minimal` profile pinning firmware off at 900, while
      still losing to a host setting the NixOS option itself, the way a board
      whose firmware comes from `nixos-hardware` does.
    */
    hardware.enableRedistributableFirmware =
      lib.mkIf cfg.firmware.enable (lib.mkOverride firmwarePriority true);
  };
  # === Config ===
}
