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

  pkgs_ = pkgs;



  # Every session registered with NixOS
  # (`services.displayManager.sessionPackages`) ends up here, including the
  # UWSM entries created by the window manager modules
  sessionsDir = "${configRoot.services.displayManager.sessionData.desktops}/share/wayland-sessions";

  # NOTE: X11 sessions (`--xsessions`) are deliberately not passed.
  # `tuigreet` launches them through `--xsession-wrapper`, which defaults to
  # `startx /usr/bin/env` and does not exist on NixOS.


  # Build the greeter command line
  command = lib.concatStringsSep " " (
    [
      (lib.getExe pkgs_.tuigreet)

      "--sessions ${sessionsDir}"

      "--power-shutdown '/run/current-system/sw/bin/systemctl poweroff'"
      "--power-reboot '/run/current-system/sw/bin/systemctl reboot'"
    ]
    ++ lib.optionals cfg.time.enable [ "--time" ]
    ++ lib.optionals (cfg.time.format != null) [ "--time-format '${cfg.time.format}'" ]
    ++ lib.optionals (cfg.greeting != null) [ "--greeting '${cfg.greeting}'" ]
    ++ lib.optionals cfg.asterisks [ "--asterisks" ]
    ++ lib.optionals cfg.remember [
      # Remember the last user, and the last session that user picked
      "--remember"
      "--remember-user-session"
    ]
    ++ lib.optionals cfg.userMenu.enable [
      "--user-menu"

      # `tuigreet` picks the menu's entries straight out of `/etc/passwd` by
      # UID, so the bounds are the only way to keep service accounts
      # (`nixbld*` in particular) out of it
      "--user-menu-min-uid ${toString cfg.userMenu.minUid}"
      "--user-menu-max-uid ${toString cfg.userMenu.maxUid}"
    ]
    ++ lib.optionals (cfg.theme != null) [ "--theme '${cfg.theme}'" ]
  );
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = "Whether to enable `tuigreet`.";
      default = false;
      type = lib.types.bool;
    };

    "time"."enable" = lib.mkOption {
      description = "Show the current date and time above the login prompt.";
      default = true;
      type = lib.types.bool;
    };

    "time"."format" = lib.mkOption {
      description = ''
        `strftime` format used when `time.enable` is set.
        `null` uses `tuigreet`'s own default.
      '';
      default = null;
      type = lib.types.nullOr lib.types.str;
      example = "%H:%M - %a %d %b %Y";
    };

    "greeting" = lib.mkOption {
      description = "Custom text to show above the login prompt.";
      default = null;
      type = lib.types.nullOr lib.types.str;
    };

    "asterisks" = lib.mkOption {
      description = "Show asterisks as a password is typed.";
      default = true;
      type = lib.types.bool;
    };

    "remember" = lib.mkOption {
      description = ''
        Remember the last user to log in, and the session that user last
        selected.
        Requires `/var/cache/tuigreet`, which the `greetd` module creates.
      '';
      default = true;
      type = lib.types.bool;
    };

    "userMenu"."enable" = lib.mkOption {
      description = "Pick a user from a menu instead of typing a username.";
      default = true;
      type = lib.types.bool;
    };

    "userMenu"."minUid" = lib.mkOption {
      description = "Lowest UID to show in the user menu.";
      default = 1000;
      type = lib.types.int;
    };

    "userMenu"."maxUid" = lib.mkOption {
      description = ''
        Highest UID to show in the user menu.
        Defaults to just below the `nixbld` range, since Nix's build users are
        ordinary `/etc/passwd` entries and would otherwise fill the menu.
      '';
      default = configRoot.ids.uids.nixbld - 1;
      type = lib.types.int;
    };

    "theme" = lib.mkOption {
      description = ''
        `tuigreet` theme specification, a `;` separated list of
        `component=colour` pairs.
      '';
      default = null;
      type = lib.types.nullOr lib.types.str;
      example = "border=magenta;button=yellow;container=black;input=red";
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs_.tuigreet ];

    services.greetd = {
      enable = true;
      package = pkgs_.greetd;

      settings.default_session = {
        inherit command;
        user = "greeter";
      };

      # Since `tuigreet` is text based
      useTextGreeter = true;
    };
  };
  # === Config ===
}
