# Mac-specific initialization; portable settings live in nix/home/shell-init.zsh.

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Keep local launchers available without depending on a previous uv installer.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH="$HOME/Documents/work/backend-monorepo/bin:$PATH"

# Vaultwarden item references. Secret values are injected only into the command
# executed by with_dev_secrets and are never exported into the interactive shell.
typeset -gr BW_ITEM_CARVAGO_GITHUB_ACCESS_TOKEN='dev/carvago/github-access-token'
typeset -gr BW_ITEM_CARVAGO_GITLAB_ACCESS_TOKEN='dev/carvago/gitlab-access-token'
typeset -gr BW_ITEM_PHRASE_STRINGS_TOKEN='dev/phrase/strings-token'

_vaultwarden_bw() {
  local vaultwarden_ca_file="${VAULTWARDEN_CA_FILE:-${NODE_EXTRA_CA_CERTS:-$HOME/.config/bitwarden/vaultwarden-ca.crt}}"

  if [[ ! -r "$vaultwarden_ca_file" ]]; then
    print -u2 "Vaultwarden CA certificate is not readable: $vaultwarden_ca_file"
    return 1
  fi

  local -x NODE_EXTRA_CA_CERTS="$vaultwarden_ca_file"
  command bw "$@"
}

_vaultwarden_bw_with_session() {
  local -x BW_SESSION="$1"
  shift
  _vaultwarden_bw "$@"
}

bw() {
  _vaultwarden_bw "$@"
}

with_dev_secrets() {
  setopt localoptions noxtrace

  if (( $# == 0 )); then
    print -u2 'Usage: with_dev_secrets <command> [args...]'
    return 2
  fi

  if (( ! $+commands[bw] )); then
    print -u2 'Bitwarden CLI is not installed or not available in PATH.'
    return 127
  fi

  local bw_session=''
  local github_token=''
  local gitlab_token=''
  local phrase_token=''
  local -i command_status=1

  {
    bw_session="$(bw unlock --raw)" || {
      print -u2 'Could not unlock Vaultwarden. Run `bw login` first if necessary.'
      return 1
    }

    if [[ -z "$bw_session" ]]; then
      print -u2 'Vaultwarden returned an empty session key.'
      return 1
    fi

    _vaultwarden_bw_with_session "$bw_session" sync >/dev/null || {
      print -u2 'Could not synchronize the Vaultwarden vault.'
      return 1
    }

    github_token="$(_vaultwarden_bw_with_session "$bw_session" get password "$BW_ITEM_CARVAGO_GITHUB_ACCESS_TOKEN")" || {
      print -u2 "Could not read Vaultwarden item: $BW_ITEM_CARVAGO_GITHUB_ACCESS_TOKEN"
      return 1
    }
    gitlab_token="$(_vaultwarden_bw_with_session "$bw_session" get password "$BW_ITEM_CARVAGO_GITLAB_ACCESS_TOKEN")" || {
      print -u2 "Could not read Vaultwarden item: $BW_ITEM_CARVAGO_GITLAB_ACCESS_TOKEN"
      return 1
    }
    phrase_token="$(_vaultwarden_bw_with_session "$bw_session" get password "$BW_ITEM_PHRASE_STRINGS_TOKEN")" || {
      print -u2 "Could not read Vaultwarden item: $BW_ITEM_PHRASE_STRINGS_TOKEN"
      return 1
    }

    if [[ -z "$github_token" || -z "$gitlab_token" || -z "$phrase_token" ]]; then
      print -u2 'A required Vaultwarden item has an empty password.'
      return 1
    fi

    (
      export CARVAGO_GITHUB_ACCESS_TOKEN="$github_token"
      export CARVAGO_GITLAB_ACCESS_TOKEN="$gitlab_token"
      export PHRASE_STRINGS_TOKEN="$phrase_token"
      command "$@"
    )
    command_status=$?
  } always {
    github_token=''
    gitlab_token=''
    phrase_token=''
    bw lock >/dev/null 2>&1
    bw_session=''
  }

  return $command_status
}

export NVM_DIR="$HOME/.config/nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
elif [[ -s /opt/homebrew/opt/nvm/nvm.sh ]]; then
  source /opt/homebrew/opt/nvm/nvm.sh
fi
if [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
elif [[ -s /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm ]]; then
  source /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm
fi
