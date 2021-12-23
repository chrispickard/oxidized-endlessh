# Oxidized Endlessh

a rust implementation of Chris Wellons' [Endlessh](https://nullprogram.com/blog/2019/03/22/). It is implemented with
tokio.

go read his post for more information as to why you would do this, however this was mainly an exercise for me to become
more comfortable with nix flakes and packaging a nix module outside nixpkgs itself.

this package is used on my server, pickard.cc, you can ssh to `ssh pickard.cc -p 2222` to get stuck in the
tar pit yourself. See the [repo for pickard.cc](https://github.com/chrispickard/pickard.cc) for a demonstration on how
to use an external module with nixos. The tl;dr is to make sure your downstream flake has both the 
`oxidized-endlessh.overlay` in its nixpkgs overlays and that it is set as a module in the `nixosConfiguration`. Then
you can configure the module like any other in your `configuration.nix`

something like

```
... <snip> ...
  outputs = inputs@{ self, nixpkgs, deploy-rs, oxidized-endlessh, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ oxidized-endlessh.overlay ]; # include the oxidized-endlessh overlay
      };
    in {
      nixosConfigurations.bellona = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          oxidized-endlessh.nixosModules.oxidized-endlessh # include the module declared in oxidized-endlessh
          ./modules/hardware-configuration.nix
          ./modules/networking.nix
          ./modules/configuration.nix
        ];
      };
... <snip> ...
```

Soon there may be a leaderboard for most people caught at one time
