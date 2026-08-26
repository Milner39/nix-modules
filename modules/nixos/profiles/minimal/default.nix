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

  keep = cfg.keep;


  /*
    Priority for every value this profile sets.

    It has to beat `lib.mkDefault` (1000), because the modules this profile is
    arguing with use exactly that:
    `services/misc/graphical-desktop.nix` sets `services.speechd.enable = lib.mkDefault true`,
    `services/networking/networkmanager.nix` sets `networking.modemmanager.enable = lib.mkDefault true`
    A `lib.mkDefault false` here does not lose gracefully to those.
    It conflicts with them at equal priority and fails evaluation.

    It must still lose to an ordinary assignment (100), so that a host
    overriding the underlying NixOS option directly wins without reaching for
    `lib.mkForce`.
  */
  profilePriority = 900;


  /*
    Every setting in this module is applied only when its group is not kept.

    A kept group leaves the underlying option alone rather than forcing it 
    back on, which matters for the options whose own default is already the 
    stripped value:
    `hardware.enableAllFirmware` off is the NixOS default and pulls in unfree
    firmware when on, so "keep firmware" must mean "don't touch it", and not
    "enable everything".

    A host therefore never has to use `keep.*` at all. Setting the underlying
    NixOS option directly also wins, the same escape hatch the upstream
    profiles in `nixpkgs/nixos/modules/profiles` rely on.
  */
  stripTo = kept: value: lib.mkIf (!kept) (lib.mkOverride profilePriority value);
  disable = kept: stripTo kept false;


  # Locale to keep when the rest are stripped
  onlyLocale = "${configRoot.i18n.defaultLocale}/${configRoot.i18n.defaultCharset}";
in
{
  # === Options ===
  options = {
    "enable" = lib.mkOption {
      description = ''
        Whether to enable the minimal profile.

        Strips a NixOS system down to the smallest closure that is still a
        functioning, rebuildable system. Everything it removes can be kept
        individually through `keep.*`.

        Not included here:
        - Package substitutions (`programs.git.package = pkgs.gitMinimal`).
        - Dropping Perl or Bash from activation, and appliance systems that
          cannot rebuild themselves. Those belong in sibling profiles rather 
          than here.
      '';
      default = false;
      type = lib.types.bool;
    };


    # === NixOS Tools ===

    "rebuildable" = lib.mkOption {
      description = ''
        Keep `nixos-rebuild` when `keep.installerTools` is off.

        `system.disableInstallerTools` sets the default for every
        `system.tools.<name>.enable`, and `nixos-rebuild` is in that list
        alongside `nixos-install`. Without this the host cannot rebuild itself.

        Turn it off only for a system that is updated by replacing its image.
      '';
      default = true;
      type = lib.types.bool;
    };

    "keep"."installerTools" = lib.mkOption {
      description = ''
        Keep the NixOS installer tools:
        `nixos-install`,
        `nixos-enter`,
        `nixos-generate-config`,
        `nixos-option`,
        `nixos-version`,
        `nixos-build-vms`.

        `nixos-rebuild` is governed separately by `rebuildable`, because
        `system.disableInstallerTools` would otherwise take it out too.
      '';
      default = false;
      type = lib.types.bool;
    };

    # === NixOS Tools ===


    # === Documentation ===

    "keep"."docs"."packages" = lib.mkOption {
      description = ''
        Keep the `doc` output of installed packages.
      '';
      default = false;
      type = lib.types.bool;
    };

    "keep"."docs"."man" = lib.mkOption {
      description = ''
        Keep man pages.
      '';
      default = false;
      type = lib.types.bool;
    };

    "keep"."docs"."nixos" = lib.mkOption {
      description = ''
        Keep the NixOS manual and `nixos-help`.
      '';
      default = false;
      type = lib.types.bool;
    };

    "keep"."docs"."info" = lib.mkOption {
      description = ''
        Keep GNU info pages.
      '';
      default = false;
      type = lib.types.bool;
    };

    # === Documentation ===


    # === Packages ===

    "keep"."nixChannels" = lib.mkOption {
      description = ''
        Keep the channel and registry machinery: `nix.channel`,
        `nixpkgs.flake.setFlakeRegistry` and `nixpkgs.flake.setNixPath`.

        `setFlakeRegistry` writes `/etc/nix/registry.json` pinning
        `nixpkgs`, which puts an entire nixpkgs checkout in the system
        closure. That is a couple of hundred megabytes to save typing a flake
        reference in full.

        Keep this on for a host still managed by `nix-channel` (bad).
      '';
      default = false;
      type = lib.types.bool;
    };

    "keep"."defaultPackages" = lib.mkOption {
      description = ''
        Keep the packages a nixos adds by default:
        `environment.defaultPackages` (`perl`, `rsync`, `strace`),
        `environment.stub-ld`,
        `programs.nano`,
        `programs.command-not-found`,
        `programs.fish.generateCompletions`.

        `perl` is the largest of these. Note that stripping this only removes the
        copy in the system path, not from activation.
      '';
      default = false;
      type = lib.types.bool;
    };

    # === Packages ===


    # === Services ===

    "keep"."hostServices" = lib.mkOption {
      description = ''
        Keep default services:
        `services.logrotate`,
        `services.udisks2`,
        `services.printing`,
        `networking.modemmanager`.
      '';
      default = false;
      type = lib.types.bool;
    };

    # === Services ===


    # === Fonts ===

    "keep"."fonts"."defaultPackages" = lib.mkOption {
      description = ''
        Keep `fonts.enableDefaultPackages`.
      '';
      default = false;
      type = lib.types.bool;
    };

    # === Fonts ===


    # === Locale ===

    "keep"."locales" = lib.mkOption {
      description = ''
        Keep `i18n.supportedLocales` as NixOS computes it.

        Stripping narrows it to `i18n.defaultLocale` plus `C.UTF-8`.

        Keep this on for a host that needs to format output in a locale it
        does not otherwise declare.
      '';
      default = false;
      type = lib.types.bool;
    };

    # === Locale ===


    # === Desktop ===

    "keep"."desktopIntegration" = lib.mkOption {
      description = ''
        Keep the freedesktop integration directories:
        `xdg.autostart`,
        `xdg.icons`,
        `xdg.mime`,
        `xdg.sounds`.

        Needed for a desktop to launch applications by MIME type and show
        their icons.
      '';
      default = false;
      type = lib.types.bool;
    };

    "keep"."accessibility" = lib.mkOption {
      description = ''
        Keep accessibility tooling:
        `services.speechd`,
        `services.orca`,
        `i18n.inputMethod.

        `services.speechd` is the largest of these. it brings in 
        several hundred megabytes of speech synthesis voice data.
      '';
      default = false;
      type = lib.types.bool;
    };

    # === Desktop ===


    # === Hardware ===

    "keep"."firmware" = lib.mkOption {
      description = ''
        Keep firmware packages:
        `hardware.enableRedistributableFirmware`,
        `hardware.enableAllFirmware`,
        `hardware.enableAllHardware`.

        WARNING: `linux-firmware` is one of the largest single paths in a
        NixOS closure, and dropping it breaks most WiFi and Bluetooth
        adaptors, and a lot of GPUs.
        Keep this on unless the board's firmware comes from somewhere else, 
        the way `nixos-hardware`'s Raspberry Pi profiles provide it.

        `enableAllFirmware` and `enableAllHardware` are off by default, so
        keeping this does not turn them on.
      '';
      default = false;
      type = lib.types.bool;
    };

    "keep"."storage" = lib.mkOption {
      description = ''
        Keep extra storage and boot tooling:
        `services.lvm`,
        `boot.bcache`,
        `boot.swraid`,
        `boot.kexec`.

        Keep this on for anything using LVM, bcache, software RAID, or
        kexec-based reboots.
      '';
      default = false;
      type = lib.types.bool;
    };

    # === Hardware ===
  };
  # === Options ===


  # === Config ===
  config = lib.mkIf cfg.enable {

    # === NixOS Tools ===

    system.disableInstallerTools = stripTo keep.installerTools true;
    system.tools.nixos-rebuild.enable = stripTo keep.installerTools cfg.rebuildable;

    # === NixOS Tools ===


    # === Documentation ===

    # Gate for all four, so only pinned off when none are kept
    documentation.enable = disable (
      keep.docs.packages || keep.docs.man || keep.docs.nixos || keep.docs.info
    );

    documentation.doc.enable = disable keep.docs.packages;
    documentation.man.enable = disable keep.docs.man;
    documentation.nixos.enable = disable keep.docs.nixos;
    documentation.info.enable = disable keep.docs.info;

    # === Documentation ===


    # === Packages ===

    nix.channel.enable = disable keep.nixChannels;

    # Writes `/etc/nix/registry.json`, which pins a whole nixpkgs checkout
    # into the system closure
    nixpkgs.flake.setFlakeRegistry = disable keep.nixChannels;
    nixpkgs.flake.setNixPath = disable keep.nixChannels;


    environment.defaultPackages = stripTo keep.defaultPackages [];
    environment.stub-ld.enable = disable keep.defaultPackages;
    programs.nano.enable = disable keep.defaultPackages;
    programs.command-not-found.enable = disable keep.defaultPackages;
    programs.fish.generateCompletions = disable keep.defaultPackages;

    # === Packages ===


    # === Services ===

    services.logrotate.enable = disable keep.hostServices;
    services.udisks2.enable = disable keep.hostServices;
    services.printing.enable = disable keep.hostServices;
    networking.modemmanager.enable = disable keep.hostServices;

    # === Services ===


    # === Fonts ===

    fonts.enableDefaultPackages = disable keep.fonts.defaultPackages;
    fonts.fontconfig.enable = lib.mkOverride profilePriority true;

    # === Fonts ===


    # === Locale ===

    /*
      `C` is excluded because glibc cannot build it, matching the guard in
      `nixpkgs`' own `config/i18n.nix`. `C.UTF-8` is kept because systemd and
      much else assume it exists.
    */
    i18n.supportedLocales = stripTo keep.locales (
      [ "C.UTF-8/UTF-8" ]
      ++ lib.optional (configRoot.i18n.defaultLocale != "C") onlyLocale
    );

    # === Locale ===


    # === Desktop ===

    xdg.autostart.enable = disable keep.desktopIntegration;
    xdg.icons.enable = disable keep.desktopIntegration;
    xdg.mime.enable = disable keep.desktopIntegration;
    xdg.sounds.enable = disable keep.desktopIntegration;

    services.speechd.enable = disable keep.accessibility;
    services.orca.enable = disable keep.accessibility;
    i18n.inputMethod.enable = disable keep.accessibility;

    # === Desktop ===


    # === Hardware ===

    hardware.enableRedistributableFirmware = disable keep.firmware;
    hardware.enableAllFirmware = disable keep.firmware;
    hardware.enableAllHardware = disable keep.firmware;

    services.lvm.enable = disable keep.storage;
    boot.bcache.enable = disable keep.storage;
    boot.swraid.enable = disable keep.storage;
    boot.kexec.enable = disable keep.storage;

    # === Hardware ===
  };
  # === Config ===
}
