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

  pkg = pkgs-unstable.nerd-fonts;
in
{
  # === Options ===
  options = {
    "all" = lib.mkOption {
      description = "Whether to install all fonts from NerdFonts.";
      default = false;
      type = lib.types.bool;
    };

    "fonts" = lib.mkOption {
      description = ''
        Specific fonts to install from NerdFonts.

        This should be a function that takes `pkgs.nerd-fonts` as an argument, 
        and returns a list of packages from the package set.
      '';
      default = (_: []);
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
    };
  };
  # === Options ===


  # === Config ===
  config = {
    home.packages = (if cfg.all
      then builtins.filter (
        (lib.attrsets.isDerivation)
        (builtins.attrValues pkg)
      )

      else (cfg.fonts pkg)
    );
  };
  # === Config ===
}
