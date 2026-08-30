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


  sessionsRootDir = configRoot.modules.gui.display-manager.sessions.dir;

  sessionsDir = "${sessionsRootDir}/share/wayland-sessions";
  xSessionsDir = "${sessionsRootDir}/share/xsessions";


  /*
    `greetd` is a TTY greeter, so unlike `sddm` it never starts an X server
    itself. X11 sessions therefore have to be launched through `startx`, which
    is what `--xsession-wrapper` is for.
  */
  xSessionWrapper =
    if cfg.xsessions.wrapper != null then
      cfg.xsessions.wrapper
    else
      "${pkgs_.xinit}/bin/startx /usr/bin/env";


  # Build the greeter command line
  command = lib.concatStringsSep " " (
    [
      (lib.getExe pkgs_.tuigreet)

      "--sessions ${sessionsDir}"

      "--power-shutdown '/run/current-system/sw/bin/systemctl poweroff'"
      "--power-reboot '/run/current-system/sw/bin/systemctl reboot'"
    ]
    ++ lib.optionals cfg.xsessions.enable [
      "--xsessions ${xSessionsDir}"
      "--xsession-wrapper '${xSessionWrapper}'"
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

    "xsessions"."enable" = lib.mkOption {
      description = ''
        Offer X11 sessions alongside the Wayland ones.

        Pulls in the X server, since `greetd` has none of its own, and enables
        `services.xserver.displayManager.startx` for the `startx` that
        `--xsession-wrapper` needs.
      '';
      default = false;
      type = lib.types.bool;
    };

    "xsessions"."wrapper" = lib.mkOption {
      description = ''
        Command `tuigreet` prefixes to an X11 session's `Exec` line.
        `null` uses `startx` with the system's `/usr/bin/env`.
      '';
      default = null;
      type = lib.types.nullOr lib.types.str;
      example = "startx /usr/bin/env";
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


    services.xserver = lib.mkIf cfg.xsessions.enable {
      enable = true;
      displayManager.startx.enable = true;
    };
  };
  # === Config ===
}
