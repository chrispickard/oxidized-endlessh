{ naersk-lib, ... }:

naersk-lib.buildPackage {
  pname = "oxidized-endlessh";
  root = ./.;
}
