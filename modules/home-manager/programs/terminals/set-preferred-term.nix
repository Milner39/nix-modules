{
  lib,
  enable ? true,
  package,
  binaryPath,
}:

{
  # `mkIf` wraps the set, not the key: `attrsOf` would otherwise leave
  # `TERMINAL` declared with no value, which throws when anything reads it
  home.sessionVariables = lib.mkIf enable {
    "TERMINAL" = "${package}${binaryPath}";
  };
}
