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

  pkg = pkgs.git;
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = "Whether to enable `git`.";
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkg;

      settings = {
        user = {
          name = "Milner39";
          email = "91906877+Milner39@users.noreply.github.com";
        };

        init.defaultBranch = "main";
        safe.directory = [ "/etc/nixos" ];
      };
    };
  };
  # === Config ===
}
