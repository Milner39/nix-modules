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

  pkg = pkgs.bash;
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = "Whether to enable `bash`.";
      default = false;
      type = lib.types.bool;
    };

    "preferred" = lib.mkOption {
      description = "Whether to set `$SHELL` to this shell.";
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
      package = pkg;
    };
  };
  # === Config ===


  # === Imports ===
  imports = [
    (import ../set-preferred-shell.nix {
      inherit lib;
      enable = cfg.preferred;
      package = pkg;
      binaryPath = "/bin/bash";
    })
  ];
  # === Imports ===
}


# TODO: Option to enable ble.sh
