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
    "backends" = lib.mkOption {
      description = ''
        Names of the enabled IP configuration backends.

        Each backend module under this one appends its own name, and this
        module asserts that no more than one is enabled.

        Set by the backend modules. Not intended to be set by hand.
      '';
      default = [];
      type = lib.types.listOf lib.types.str;
    };
  };
  # === Options ===


  # === Config ===
  config = {
    assertions = [
      {
        assertion = (lib.length cfg.backends) <= 1;
        message = ''
          Only one networking backend can be enabled at a time, but these are:
          ${lib.concatStringsSep ", " cfg.backends}.

          Pick one under `${optionTreeName}.hardware.networking`.
        '';
      }
    ];
  };
  # === Config ===
}
