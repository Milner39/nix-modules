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

  # Use latest version, wrapped variant that launches with FHS compatible env
  # This lets all vscode extensions work without the need for nix-specific conf
  pkg = pkgs-unstable.vscode-fhs;
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = "Whether to enable `code`.";
      default = false;
      type = lib.types.bool;
    };

    "preferred" = lib.mkOption {
      description = "Whether to set `$EDITOR` to this editor.";
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkg
    ];
  };
  # === Config ===


  # === Imports ===
  imports = [
    (import ../set-preferred-editor.nix {
      inherit lib;
      enable = cfg.preferred;
      package = pkg;
      binaryPath = "/bin/code";
    })
  ];
  # === Imports ===
}
