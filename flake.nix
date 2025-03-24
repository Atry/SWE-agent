{
  nixConfig.extra-substituters = [
    "https://devenv.cachix.org"
  ];
  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    devenv.url = "github:Atry/devenv";
    systems.url = "github:nix-systems/default-linux";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-ml-ops.url = "github:Atry/nix-ml-ops";
    nix-ml-ops.inputs.devenv-root.follows = "devenv-root";
    nix-ml-ops.inputs.devenv.follows = "devenv";
    nix-ml-ops.inputs.systems.follows = "systems";
  };
  outputs =
    inputs@{ nix-ml-ops, ... }:
    nix-ml-ops.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        imports = [
          nix-ml-ops.flakeModules.devcontainer
          nix-ml-ops.flakeModules.nixIde
          nix-ml-ops.flakeModules.nixLd
          nix-ml-ops.flakeModules.pythonVscode
          nix-ml-ops.flakeModules.ldFallbackManylinux
          nix-ml-ops.flakeModules.devcontainerNix
        ];
        perSystem =
          {
            pkgs,
            config,
            lib,
            system,
            inputs',
            ...
          }:
          {
            ml-ops.devcontainer = {
              devenvShellModule = {
                processes.jupyter-lab-collaborative.exec = ''
                  uv run jupyter-lab --collaborative
                '';

                packages = [
                  pkgs.saml2aws
                ];
                languages = {
                  python = {
                    venv.enable = true;
                    uv = {
                      enable = true;
                      sync = {
                        enable = true;
                        allExtras = true;
                      };
                    };
                    enable = true;
                  };
                  javascript = {
                    enable = true;
                    npm = {
                      enable = true;
                    };
                  };
                };
              };
            };

          };
      }
    );
}
