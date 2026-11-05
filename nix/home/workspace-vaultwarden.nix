{ config, lib, pkgs, bitwardenPackage ? pkgs.bitwarden-cli, ... }:

let
  server = "https://vaultwarden.vaultwarden.svc.cluster.local";
  ca = ../../.config/bitwarden/vaultwarden-ca.crt;
  cli = pkgs.writeShellScriptBin "bw" ''
    umask 077
    export BITWARDENCLI_APPDATA_DIR="$HOME/.local/share/bitwarden-workspace"
    export NODE_EXTRA_CA_CERTS=${ca}
    exec ${bitwardenPackage}/bin/bw "$@"
  '';
  withSecrets = pkgs.writeTextFile {
    name = "with-dev-secrets";
    destination = "/bin/with_dev_secrets";
    executable = true;
    text = ''
      #!${pkgs.zsh}/bin/zsh -f
      export PATH=${cli}/bin:$PATH
      source ${./vaultwarden.zsh}
      with_dev_secrets "$@"
    '';
  };
  configure = pkgs.writeShellScript "configure-workspace-vaultwarden" ''
    set -eu
    umask 077
    state="$HOME/.local/share/bitwarden-workspace"
    ${pkgs.coreutils}/bin/install -d -m 0700 "$state"
    if [[ -f "$state/data.json" ]]; then
      current="$(${cli}/bin/bw config server)"
      if [[ "$current" != ${lib.escapeShellArg server} ]]; then
        echo 'Workspace Bitwarden state points to another server; preserving it. Review bw config server before activation.' >&2
        exit 1
      fi
    else
      ${cli}/bin/bw config server ${lib.escapeShellArg server} >/dev/null
    fi
  '';
in
{
  home.packages = [ cli withSecrets ];
  xdg.configFile."bitwarden/vaultwarden-ca.crt".source = ca;
  home.activation.workspaceVaultwarden = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${configure}
  '';
}
