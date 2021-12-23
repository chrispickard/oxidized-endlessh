{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages."${system}";
      naersk-lib = naersk.lib."${system}";
    in rec {
      # `nix build`
      packages.oxidized-endlessh =
        (pkgs.callPackage ./default.nix { inherit naersk-lib; });

      overlay = final: prev: {
        oxidized-endlessh =
          (prev.callPackage ./default.nix { inherit naersk-lib; });
      };

      defaultPackage."${system}" = packages.oxidized-endlessh;

      nixosModules = { oxidized-endlessh = import ./module.nix; };

      # `nix run`
      apps.oxidized-endlessh =
        utils.lib.mkApp { drv = packages.oxidized-endlessh; };
      defaultApp = apps.oxidized-endlessh;

      # `nix develop`
      # devShell =
      #   pkgs.mkShell { nativeBuildInputs = with pkgs; [ rustc cargo ]; };
    };
}
