{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.oxidized-endlessh;
  settings = pkgs.writeTextDir "oxidized-endlessh/settings.json"
    (builtins.toJSON (cfg.opts));
in {

  options.services.oxidized-endlessh = {
    enable = mkEnableOption "oxidized-endlessh service";

    opts = {
      addrs = mkOption {
        type = with types; listOf string;
        default = [ "127.0.0.1:2222" ];
        example = [ "0.0.0.0:2222" ];
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
      description = "";
      serviceConfig = {
        User = "oxidized-endlessh";
        ExecStart =
          "${pkgs.oxidized-endlessh}/bin/oxidized-endlessh -f ${settings}/oxidized-endlessh/settings.json";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
