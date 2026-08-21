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
        Whether to enable `niri` customisation.
      '';
      default = false;
      type = lib.types.bool;
    };
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {
    home.file.".config/niri/config.kdl" = {
      text = let
        # === Programs ===
        menu = "rofi";
        menuExec = "${menu} -show drun";

        terminal = "\$TERMINAL";
        terminalExec = "${terminal}";

        screenshotExec = "slurp | grim -g - - | wl-copy";
      in ''
        // Monitors
        output "" {
          scale 1
        }
        output "eDP-1" {
          scale 1
        }

        // Keyboard, Mouse, Touchpad
        input {
          mod-key "Super"
          mod-key-nested "Alt"

          keyboard {
            xkb {
              layout "gb"
            }
          }
          mouse {
          }
          touchpad {
            tap
            natural-scroll
          }
        }

        prefer-no-csd
        layout {
          preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
          }
          default-column-width { proportion 0.5; }

          // outer gap = gaps + struts
          gaps 5
          struts {
            left 5
            right 5
            top 5
            bottom 5
          }

          focus-ring {
            off
          }

          border {
            width 2
            active-gradient from="#33ccffee" to="#00ff99ee" angle=45
            inactive-color "#595959aa"
          }
        }

        window-rule {
          geometry-corner-radius 10
          clip-to-geometry true
        }

        binds {
          Mod+C repeat=false { close-window; }
          Mod+M { quit; }
          Mod+L { spawn-sh "hyprlock"; }
          Mod+Space { spawn-sh "${menuExec}"; }
          Mod+Q { spawn-sh "${terminalExec}"; }
          Mod+S { spawn-sh "${screenshotExec}"; }

          // Escape an application inhibiting keyboard shortcuts (remote desktop software)
          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

          // Move the focused window between the floating and the tiling layout.
          Mod+V       { toggle-window-floating; }
          Mod+Shift+V { switch-focus-between-floating-and-tiling; }

          // Move focus with arrow keys
          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }

          // Move the focused window in and out of a column.
          // If the window is alone, they will consume it into the nearby column to the side.
          // If the window is already in a column, they will expel it out.
          Mod+BracketLeft  { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }

          // Switch workplaces
          Mod+1         { focus-workspace 1;  }
          Mod+2         { focus-workspace 2;  }
          Mod+3         { focus-workspace 3;  }
          Mod+4         { focus-workspace 4;  }
          Mod+5         { focus-workspace 5;  }
          Mod+6         { focus-workspace 6;  }
          Mod+7         { focus-workspace 7;  }
          Mod+8         { focus-workspace 8;  }
          Mod+9         { focus-workspace 9;  }
          Mod+0         { focus-workspace 10; }
          Mod+Page_Up   { focus-workspace-up; }
          Mod+Page_Down { focus-workspace-down; }
          Mod+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }
          Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }

          // Move active column to workplaces
          Mod+Shift+1         { move-column-to-workspace 1;  }
          Mod+Shift+2         { move-column-to-workspace 2;  }
          Mod+Shift+3         { move-column-to-workspace 3;  }
          Mod+Shift+4         { move-column-to-workspace 4;  }
          Mod+Shift+5         { move-column-to-workspace 5;  }
          Mod+Shift+6         { move-column-to-workspace 6;  }
          Mod+Shift+7         { move-column-to-workspace 7;  }
          Mod+Shift+8         { move-column-to-workspace 8;  }
          Mod+Shift+9         { move-column-to-workspace 9;  }
          Mod+Shift+0         { move-column-to-workspace 10; }
          Mod+Shift+Page_Up   { move-column-to-workspace-up; }
          Mod+Shift+Page_Down { move-column-to-workspace-down; }
          Mod+Shift+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }
          Mod+Shift+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }

          // Overview
          Mod+O repeat=false { toggle-overview; }

          // Laptop multimedia keys for volume and LCD brightness
          XF86AudioRaiseVolume  allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1"; }
          XF86AudioLowerVolume  allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; }
          XF86AudioMute         allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
          XF86AudioMicMute      allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
          XF86MonBrightnessUp   allow-when-locked=true { spawn-sh "brightnessctl -e4 -n2 set 5%+"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn-sh "brightnessctl -e4 -n2 set 5%-"; }

          // Media controls
          XF86AudioPlay         allow-when-locked=true { spawn-sh "playerctl play-pause"; }
          XF86AudioPause        allow-when-locked=true { spawn-sh "playerctl play-pause"; }
          XF86AudioNext         allow-when-locked=true { spawn-sh "playerctl next"; }
          XF86AudioPrev         allow-when-locked=true { spawn-sh "playerctl previous"; }

          // Resize windows
          Mod+R { switch-preset-column-width; }
          Mod+Shift+R { switch-preset-window-height; }
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+Minus { set-column-width "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }
          Mod+Shift+Minus { set-window-height "-10%"; }
      }
      '';
    };
  };
  # === Config ===
}
