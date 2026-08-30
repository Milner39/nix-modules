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


  dm = configRoot.services.displayManager;

  # Every session name registered with NixOS
  allSessions = lib.concatMap (p: p.providedSessions or [ ]) dm.sessionPackages;



  /*
    Compositors register their own session on top of the UWSM one, so a
    greeter lists both `sway` and `sway-uwsm`.
    Get the list of compositors that have 2 entries.
  */
  shadowedByUwsm = lib.optionals cfg.sessions.preferUwsm (
    lib.filter (name: lib.elem "${name}-uwsm" allSessions) allSessions
  );

  hidden = lib.unique (cfg.sessions.hide ++ shadowedByUwsm);

  /*
    Rebuilds the directory with the hidden entries left out, and each 
    display manager module points at `sessions.dir` rather than at 
    `sessionData.desktops`.
  */
  filtered = pkgs_.runCommand "display-manager-sessions" {
    preferLocalBuild = true;
    allowSubstitutes = false;
  } ''
    mkdir -p "$out/share/"{xsessions,wayland-sessions}

    for dir in xsessions wayland-sessions; do
      src="${dm.sessionData.desktops}/share/$dir"
      [ -d "$src" ] || continue

      for entry in "$src"/*.desktop; do
        [ -e "$entry" ] || continue

        name="$(basename "$entry" .desktop)"
        case " ${lib.concatStringsSep " " hidden} " in
          *" $name "*) continue ;;
        esac

        ln -s "$entry" "$out/share/$dir/$name.desktop"
      done
    done
  '';
in
{
  # === Options ===
  options = {
    "sessions"."preferUwsm" = lib.mkOption {
      description = ''
        Hide a compositor's own session entry when UWSM provides one for it.

        Hides `<name>` whenever `<name>-uwsm` is also registered, so a greeter
        offers each compositor once rather than twice.
      '';
      default = true;
      type = lib.types.bool;
    };

    "sessions"."hide" = lib.mkOption {
      description = ''
        Session names to hide from every display manager, without the
        `.desktop` suffix.
      '';
      default = [];
      type = lib.types.listOf lib.types.str;
    };

    "sessions"."dir" = lib.mkOption {
      description = ''
        Directory holding the session entries, after `hide` and `preferUwsm`
        have been applied. Contains `share/wayland-sessions` and
        `share/xsessions`, matching the layout of
        `services.displayManager.sessionData.desktops`.

        Display manager modules should read this rather than
        `sessionData.desktops`, so that hiding works for all of them at once.
        Read only.
      '';
      readOnly = true;
      default = if hidden == [] then dm.sessionData.desktops else filtered;
      type = lib.types.package;
    };
  };
  # === Options ===
}
