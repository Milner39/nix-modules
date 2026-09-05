{
  inputs = {

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url           =  "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url  =  "github:nixos/nixpkgs/nixos-unstable";

  };

  outputs = { flake-parts, ... } @ inputs: flake-parts.lib.mkFlake {
    inherit inputs;
  } {
    # Supported systems (alleged)
    systems = [ "x86_64-linux" "aarch64-linux" ];


    flake = let

      # Use `fallback` if `value` is null
      orElse = value: fallback: if value != null then value else fallback;

      mkModuleTree = import ./mkModuleTree.nix;



      mkModuleTree_ = modulesDir: {
        moduleTreeName ? "modules",
        extraSpecialArgs ? {},

        # Pkgs options
        system ? null,
        overlays ? null,
        allowUnfree ? null,

      }: { config, lib, pkgs, ... } @ moduleArgs: let

        mkPkgs = nixpkgs: import nixpkgs {
          system              =  orElse system      pkgs.stdenv.hostPlatform.system;
          overlays            =  orElse overlays    pkgs.overlays;
          config.allowUnfree  =  orElse allowUnfree pkgs.config.allowUnfree;
        };

      in mkModuleTree { inherit lib; } {
        inherit modulesDir moduleTreeName;

        configRoot = config;

        specialArgs = moduleArgs // {
          pkgs           =  mkPkgs inputs.nixpkgs;
          pkgs-unstable  =  mkPkgs inputs.nixpkgs-unstable;
        } // extraSpecialArgs;
      };



    in {
      lib = {
        nixosModuleTree  =  mkModuleTree_ ./modules/nixos;
        homeModuleTree   =  mkModuleTree_ ./modules/home-manager;

        # For driving `mkModuleTree` directly
        inherit mkModuleTree;
        nixosModulesDir  =  ./modules/nixos;
        homeModulesDir   =  ./modules/home-manager;
      };
    };
  };
}
