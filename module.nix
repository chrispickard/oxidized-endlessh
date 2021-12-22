{ lib, pkgs, config, inputs, ... }:
with lib;
let cfg = config.chrispickard.services.oxidized-endlessh;
in {

  options.chrispickard.services.oxidized-endlessh = {
    enable = mkEnableOption "oxidized-endlessh service";

    opts = {
      addresses = mkOption {
        type = types.list;
        default = [ "127.0.0.1:2222" ];
        example = [ "127.0.0.1:2222" ];
        description = "Host to listen on";
      };
    };

  };

  config = mkIf cfg.enable {

    # User and group
    users.users.oxidized-endlessh = {
      isSystemUser = true;
      description = "oxidized-endlessh user";
      extraGroups = [ "oxidized-endlessh" ];
      group = "oxidized-endlessh";
    };

    users.groups.oxidized-endlessh = { name = "oxidized-endlessh"; };

    # Service
    systemd.services.oxidized-endlessh = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Startmatrix-hook";
      serviceConfig = {

        User = "oxidized-endlessh";
        ExecStart = "${
            inputs.oxidized-endlessh.packages."${config.nixpkgs.system}".oxidized-endlessh
          }/bin/oxidized-endlessh -f /etc/oxidized-endlessh/settings.json";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      environment.etc."oxidized-endlessh/settings.json".text =
        builtins.toJSON (cfg.opts);
    };

  };
}
