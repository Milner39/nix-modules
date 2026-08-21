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

  pkg = pkgs.zsh;
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = "Whether to enable `zsh`.";
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
    programs.zsh = {
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
      binaryPath = "/bin/zsh";
    })
  ];
  # === Imports ===
}
