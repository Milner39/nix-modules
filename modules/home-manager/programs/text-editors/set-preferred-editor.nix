{
  lib,
  enable ? true,
  package,
  binaryPath,
}:

{
  home.sessionVariables."EDITOR" = lib.mkIf enable (
    "${package}${binaryPath}"
  );
}