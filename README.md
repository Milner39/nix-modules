# nix-modules

[![Nix Flake](https://img.shields.io/badge/nix-flake-5277c3?logo=nixos&logoColor=white)](https://nixos.org)

## What is this?

Shared NixOS and Home Manager modules, exposed as option trees built from this
repository's directory structure.

Each release branch is pinned to the nixpkgs release it was written against,
so a system configuration can track a different version of these modules from
its siblings. Only nixpkgs 26.05 and later are supported.

## Usage

### Add the input

```nix
inputs = {

  nixpkgs.url           =  "github:nixos/nixpkgs/nixos-26.05";
  nixpkgs-unstable.url  =  "github:nixos/nixpkgs/nixos-unstable";

  nix-modules = {
    url = "github:Milner39/nix-modules/release-26.05";

    # Optional, see "Which nixpkgs the modules use" below
    inputs.nixpkgs.follows           =  "nixpkgs";
    inputs.nixpkgs-unstable.follows  =  "nixpkgs-unstable";
  };

};
```

### Import a tree

Both trees are ordinary modules, so they go straight into `imports`. Nothing
needs to be passed to them.

In a NixOS configuration:

```nix
{ inputs, ... }:
{
  imports = [
    (inputs.nix-modules.lib.nixosModuleTree { })
  ];

  modules.gui.window-manager.niri.enable = true;
}
```

In a Home Manager configuration:

```nix
{ inputs, ... }:
{
  imports = [
    (inputs.nix-modules.lib.homeModuleTree { })
  ];

  modules.programs.terminals.ghostty.enable = true;
}
```

The `{ }` is required. Without it the module system receives the function that
*takes* the options below, rather than the module itself, and fails with:

```
error: function 'mkModuleTree_' called with unexpected argument 'lib'
```

### Options

Both `nixosModuleTree` and `homeModuleTree` accept the same attribute set.
Every attribute is optional.

| Attribute | Default | Meaning |
| --- | --- | --- |
| `moduleTreeName` | `"modules"` | Namespace the option tree is declared under. |
| `extraSpecialArgs` | `{ }` | Extra arguments passed to every module. Overrides anything of the same name. |
| `system` | inherited | Platform to instantiate nixpkgs for. |
| `overlays` | inherited | Overlays to apply. |
| `allowUnfree` | inherited | Whether unfree packages are permitted. |

"Inherited" means the value is read back off the `pkgs` of the configuration
doing the importing, so overlays and `allowUnfree` carry over without being
restated. Set one explicitly only to deliberately diverge.

To rename the namespace:

```nix
(inputs.nix-modules.lib.nixosModuleTree {
  moduleTreeName = "myModules";
})
```

To pass something extra through to the modules:

```nix
(inputs.nix-modules.lib.nixosModuleTree {
  extraSpecialArgs = { inherit usersData; };
})
```

### Which nixpkgs the modules use

The modules are given `pkgs` and `pkgs-unstable` built from **this flake's own**
`nixpkgs` and `nixpkgs-unstable` inputs, not from the importing
configuration's. A release therefore evaluates against the nixpkgs it was
written against, whatever the consumer happens to be tracking.

Adding the `follows` lines from the first example makes the modules and the rest
of the configuration share a single nixpkgs, which avoids a second
evaluation and guarantees the two can never drift apart.

## Repository layout

Each directory under `modules/nixos` and `modules/home-manager` becomes an
attribute in the option tree:

```
modules/nixos/gui/window-manager/niri/default.nix
  -> modules.gui.window-manager.niri.*
```

- A directory's `default.nix` declares the options and config for that module.
- `default.nix` is optional. Directories without one simply group their
  children, and declare nothing themselves.
- Directories whose name begins with `_` are skipped. Use them
  for supporting files that should not become options, such as `_config` for
  static assets or `_scripts` for helper derivations.
- Files other than `default.nix` are not picked up automatically. They are
  plain functions, imported by hand from a module's own `imports`.

## Writing a module

A `default.nix` is a function returning any of `options`, `config` and
`imports`. All three are optional and default to empty.

```nix
{
  configRoot,
  moduleConfig,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  cfg = moduleConfig;
in
{
  options = {
    "enable" = lib.mkOption {
      description = "Whether to enable the thing.";
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.thing ];
  };
}
```

Options are declared **relative to the module itself**, not the full path.
The `enable` option above becomes `modules.<path to this directory>.enable`.

Arguments available to every module:

| Argument | Meaning |
| --- | --- |
| `moduleConfig` | The configuration set for this module. Usually aliased to `cfg`. |
| `moduleTreeConfig` | The configuration of the whole tree, for reading other modules. |
| `moduleTreeName` | The namespace the tree is declared under, for setting other modules' options. |
| `configRoot` | The root `config` of the whole configuration. |
| `lib` | The consuming configuration's `lib`, including any extensions it has made. |
| `pkgs`, `pkgs-unstable` | Package sets built from this flake's nixpkgs inputs. |

Anything the consumer supplies through `specialArgs` or `extraSpecialArgs` is
also available. Read configuration from `moduleConfig` rather than
`configRoot`, as the latter risks infinite recursion.

A module reaching another module in the tree goes through `moduleTreeConfig`
and `moduleTreeName`, never a literal `modules.*`, so that a consumer renaming
the namespace with `moduleTreeName` does not break it:

Every `default.nix` in the tree is imported and applied whenever the tree is
imported, regardless of what is enabled. A missing argument is therefore an
error at evaluation time even for a module not used.

## Other outputs

For driving the tree builder directly, rather than through the wrappers above:

| Output | Meaning |
| --- | --- |
| `lib.mkModuleTree` | The underlying tree builder. |
| `lib.nixosModulesDir` | Path to the NixOS module directory. |
| `lib.homeModulesDir` | Path to the Home Manager module directory. |

## Releases

Release branches are named after the nixpkgs release they target:

```
release-26.05
release-26.11
and so on
```

Branches are mutable, so fixes can be backported to a line and picked up with
`nix flake update`. Pin to an exact point with a tag if a configuration needs
one; day to day, `flake.lock` already provides that.

## License

Copyright © 2026 Finn Milner.

Licensed under the [Apache License 2.0](LICENSE.md).

