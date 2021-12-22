{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        naersk-lib = naersk.lib."${system}";
      in rec {
        # `nix build`
        packages.oxidized-endlessh = naersk-lib.buildPackage {
          pname = "oxidized-endlessh";
          root = ./.;
        };
        # defaultPackage = packages.oxidized-endlessh;

        # `nix run`
        # apps.oxidized-endlessh =
        #   utils.lib.mkApp { drv = packages.oxidized-endlessh; };
        # defaultApp = apps.oxidized-endlessh;

        # `nix develop`
        # devShell =
        #   pkgs.mkShell { nativeBuildInputs = with pkgs; [ rustc cargo ]; };
      });
}
