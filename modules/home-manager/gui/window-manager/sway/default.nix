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

in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = ''
        Whether to enable `sway` customisation.
      '';
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;

      # Use packages installed by NixOS system config
      package = null;

      # Conflicts with UWSM
      systemd.enable = false;
    };



    wayland.windowManager.sway.config = let
      # === Programs ===
      menu = "rofi";
      menuExec = "${menu} -show drun";

      terminal = "\${TERMINAL}";
      terminalExec = "${terminal}";

      screenshotExec = "slurp | grim -g - - | wl-copy";

      # === Keybindings ===
      mod = "Mod4"; # Super
    in {
      inherit menu terminal;

      # === Autostart ===
      /*
        Unlike `niri` and `hyprland`, `sway` does not export `WAYLAND_DISPLAY`
        and `SWAYSOCK` to the systemd & D-Bus activation environments itself.

        Without this UWSM never sees the session come up: it tears the session
        down after ~30 seconds, and until then anything needing a portal (such
        as `ghostty`) hangs waiting for `org.freedesktop.portal.Settings`.
      */
      startup = [
        { command = "exec uwsm finalize"; }
      ];

      # === Monitors ===
      output = {
        "*" = {
          scale = "1";
        };
        "eDP-1" = {
          scale = "1";
        };
      };

      # === Input ===
      input = {
        "type:keyboard" = {
          xkb_layout = "gb";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
      };

      # === UI & UX ===
      window = {
        titlebar = false;
        border = 2;
      };

      floating = {
        titlebar = false;
        border = 2;
      };

      gaps = {
        inner = 5;
        outer = 5;
      };

      colors = {
        focused = {
          border = "#33ccffee";
          childBorder = "#33ccffee";
          background = "#33ccffee";
          indicator = "#00ff99ee";
          text = "#ffffffff";
        };
        focusedInactive = {
          border = "#595959aa";
          childBorder = "#595959aa";
          background = "#595959aa";
          indicator = "#595959aa";
          text = "#ffffffff";
        };
        unfocused = {
          border = "#595959aa";
          childBorder = "#595959aa";
          background = "#595959aa";
          indicator = "#595959aa";
          text = "#ffffffff";
        };
      };

      # No status bar
      bars = [];

      # === Keybindings ===
      modifier = mod;


      defaultWorkspace = "workspace number 1";

      keybindings = {
        "--no-repeat ${mod}+c" = "kill";
        "${mod}+m" = "exit";
        "${mod}+l" = "exec hyprlock";
        "${mod}+space" = "exec ${menuExec}";
        "${mod}+q" = "exec ${terminalExec}";
        "${mod}+s" = "exec ${screenshotExec}";

        # Escape an application inhibiting keyboard shortcuts (remote desktop)
        "--inhibited ${mod}+Escape" = "shortcuts_inhibitor disable";
        "${mod}+Shift+Escape" = "shortcuts_inhibitor enable";

        # Move the focused window between the floating and the tiling layout.
        "${mod}+v" = "floating toggle";
        "${mod}+Shift+v" = "focus mode_toggle";

        # Move focus with arrow keys
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        # Switch workplaces
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";
        "${mod}+Prior" = "workspace prev_on_output";
        "${mod}+Next" = "workspace next_on_output";
        "${mod}+button4" = "workspace prev_on_output";
        "${mod}+button5" = "workspace next_on_output";

        # Move active container to workplaces
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";
        "${mod}+Shift+Prior" = "move container to workspace prev_on_output";
        "${mod}+Shift+Next" = "move container to workspace next_on_output";
        "${mod}+Shift+button4" = "workspace prev_on_output";
        "${mod}+Shift+button5" = "workspace next_on_output";

        # Laptop multimedia keys for volume and LCD brightness
        "--locked XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1";
        "--locked XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "--locked XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "--locked XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "--locked XF86MonBrightnessUp" = "exec brightnessctl -e4 -n2 set 5%+";
        "--locked XF86MonBrightnessDown" = "exec brightnessctl -e4 -n2 set 5%-";

        # Media controls
        "--locked XF86AudioPlay" = "exec playerctl play-pause";
        "--locked XF86AudioPause" = "exec playerctl play-pause";
        "--locked XF86AudioNext" = "exec playerctl next";
        "--locked XF86AudioPrev" = "exec playerctl previous";

        # Resize windows
        "${mod}+r" = "mode resize";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+Shift+f" = "fullscreen toggle global";
        "${mod}+equal" = "resize grow width 10 ppt";
        "${mod}+minus" = "resize shrink width 10 ppt";
        "${mod}+Shift+equal" = "resize grow height 10 ppt";
        "${mod}+Shift+minus" = "resize shrink height 10 ppt";
      };
    };
  };
  # === Config ===
}
