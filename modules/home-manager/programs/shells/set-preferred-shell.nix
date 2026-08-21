{
  lib,
  enable ? true,
  package,
  binaryPath,
}:

/*
  Having `enable` as an argument lets us unconditionally import this function, 
  avoiding infinite recursion due to imports being evaluated "eagerly".
*/
{
  home.file.".config/environment.d/90-shell.conf" = lib.mkIf enable {
    text = ''
      SHELL=${package}${binaryPath}
    '';
  };
}

/* NOTE:
  The point of this function is to allow users to set `$SHELL` to anything 
  other than their login shell.

  `home.sessionVariables.SHELL` does not work because Home Manager only adds 
  those variables to:
    `~/.profile` (via `~/.nix-profile/etc/profile.d/hm-session-vars.sh`).
  And those variables get overridden by NixOS at some point (idk when, I'm not 
  that smart) and so `$SHELL` gets set back to the login shell.

  But since NixOS uses systemd, we can use `~/.config/environment.d` to set 
  variables AFTER NixOS does it's stuff.
*/