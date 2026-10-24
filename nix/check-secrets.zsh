#!/bin/zsh
# Run with: zsh ~/dotfiles/nix/check-secrets.zsh
# Only presence, exit status, and vault-lock checks are reported.
setopt noxtrace

if [[ ${DEVELOPMENT_SECRET_CHECK_READY:-} != 1 ]]; then
  exec /usr/bin/env \
    -u CARVAGO_GITHUB_ACCESS_TOKEN -u CARVAGO_GITLAB_ACCESS_TOKEN \
    -u PHRASE_STRINGS_TOKEN -u BW_SESSION \
    DEVELOPMENT_SECRET_CHECK_READY=1 \
    /run/current-system/sw/bin/zsh -lic 'source "$1"' secrets-check "${0:A}"
fi

check_development_secrets() {
  setopt localoptions noxtrace noerrexit noerrreturn
  if (( ! $+functions[with_dev_secrets] )); then
    print -u2 'FAIL: with_dev_secrets is not available in the active login shell.'
    return 1
  fi

  local name
  for name in CARVAGO_GITHUB_ACCESS_TOKEN CARVAGO_GITLAB_ACCESS_TOKEN PHRASE_STRINGS_TOKEN BW_SESSION; do
    if [[ -n ${(P)name} ]]; then
      print -u2 'FAIL: a credential was exported by shell startup.'
      return 1
    fi
  done

  print 'Unlock Vaultwarden at the local prompt. No token values will be printed.'
  # Exit 23 deliberately to verify error propagation and cleanup too.
  with_dev_secrets python3 -c '
import os, sys
keys = ("CARVAGO_GITHUB_ACCESS_TOKEN", "CARVAGO_GITLAB_ACCESS_TOKEN", "PHRASE_STRINGS_TOKEN")
ok = all(os.environ.get(key) for key in keys) and not os.environ.get("BW_SESSION")
sys.exit(23 if ok else 31)
'
  local command_status=$?
  if (( command_status != 23 )); then
    print -u2 "FAIL: secret injection or child exit-status check failed (status $command_status)."
    return 1
  fi

  for name in CARVAGO_GITHUB_ACCESS_TOKEN CARVAGO_GITLAB_ACCESS_TOKEN PHRASE_STRINGS_TOKEN BW_SESSION; do
    if [[ -n ${(P)name} ]]; then
      print -u2 'FAIL: a credential remained in the parent shell.'
      return 1
    fi
  done

  local vault_state
  vault_state="$(bw status | python3 -c 'import json,sys; print(json.load(sys.stdin).get("status", "unknown"))')" || return 1
  if [[ $vault_state != locked ]]; then
    print -u2 'FAIL: the vault did not report locked after cleanup.'
    return 1
  fi
  print 'PASS: three tokens reached only the child; exit status was preserved; the vault is locked.'
}

if check_development_secrets; then
  outcome=passed
else
  outcome=failed
fi
python3 - "$outcome" <<'PY'
import datetime, json, os, pathlib, sys
directory = pathlib.Path.home() / '.local/state/nix-darwin'
directory.mkdir(parents=True, exist_ok=True)
path = directory / 'secret-check.json'
result = {'status': sys.argv[1], 'checked_at': datetime.datetime.now().astimezone().isoformat(), 'secrets_printed': False}
fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
with os.fdopen(fd, 'w') as stream:
    json.dump(result, stream, indent=2)
    stream.write('\n')
PY
[[ $outcome == passed ]]
