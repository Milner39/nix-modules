{
  lib,
  enable ? true,
  package,
  binaryPath,
}:

{
  home.sessionVariables."TERMINAL" = lib.mkIf enable (
    "${package}${binaryPath}"
  );
}