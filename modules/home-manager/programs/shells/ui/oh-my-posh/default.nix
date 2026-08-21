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

  pkg = pkgs-unstable.oh-my-posh;
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = "Whether to enable `oh-my-posh`.";
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = let

    # TODO: These will be turned into options so different themes can be used
    configFolder = "${configRoot.xdg.configHome}/oh-my-posh";
    entryFile = "config.toml";

  in lib.mkIf cfg.enable {
    programs.oh-my-posh = {
      enable = true;
      package = pkg;

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;

      configFile = "${configFolder}/${entryFile}";
    };

    home.file."${configFolder}".source = ./_config;
  };
  # === Config ===
}
