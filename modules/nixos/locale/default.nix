{
  configRoot,
  moduleConfig,
  moduleTreeName,
  moduleTreeConfig,
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
        Whether to enable `locale` settings.
      '';
      default = false;
      type = lib.types.bool;
    };

    "keyMap" = lib.mkOption {
      description = ''
        Default key map to use system-wide.
      '';
      default = "uk";
      type = lib.types.str;
    };

    "timeZone" = lib.mkOption {
      description = ''
        Default time zone to use system-wide.
      '';
      default = "Europe/London";
      type = lib.types.str;
    };

    "locale" = lib.mkOption {
      description = ''
        Default locale to use system-wide.
      '';
      default = "en_GB.UTF-8";
      type = lib.types.str;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {

    console.keyMap = cfg.keyMap;

    time.timeZone = cfg.timeZone;

    i18n = let
      locale = cfg.locale;
    in {
      defaultLocale = locale;
      extraLocaleSettings = {
        LC_ADDRESS = locale;
        LC_COLLATE = locale;
        LC_CTYPE = locale;
        LC_IDENTIFICATION = locale;
        LC_MEASUREMENT = locale;
        LC_MESSAGES = locale;
        LC_MONETARY = locale;
        LC_NAME = locale;
        LC_NUMERIC = locale;
        LC_PAPER = locale;
        LC_TELEPHONE = locale;
        LC_TIME = locale;
      };
    };

  };
  # === Config ===
}
