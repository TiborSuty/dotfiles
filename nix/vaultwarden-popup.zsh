# Internal helpers for check-secrets.zsh. Capture output; never call these
# directly at a prompt, because unlock returns a session key.

_vaultwarden_popup_password() {
  setopt localoptions noxtrace
  /usr/bin/osascript 2>/dev/null <<'APPLESCRIPT'
activate
set response to display dialog "Enter your Vaultwarden master password to check access to your development tokens. It will be used for this check only." default answer "" with hidden answer buttons {"Cancel", "Unlock"} default button "Unlock" cancel button "Cancel" with title "Vaultwarden secret check" giving up after 180
if gave up of response then error number -128
return text returned of response
APPLESCRIPT
}

_vaultwarden_popup_bw() {
  setopt localoptions noxtrace
  if [[ ${1:-} != unlock ]]; then
    _vaultwarden_bw "$@"
    return $?
  fi

  # This variable exists only during unlock. The password is never an argument
  # to an external process or written to a file or Keychain.
  local -x VAULTWARDEN_POPUP_PASSWORD=''
  local -i unlock_status=1
  {
    VAULTWARDEN_POPUP_PASSWORD="$(_vaultwarden_popup_password)" || {
      print -u2 'Vaultwarden unlock cancelled, timed out, or the dialog could not open.'
      return 1
    }
    if [[ -z "$VAULTWARDEN_POPUP_PASSWORD" ]]; then
      print -u2 'No Vaultwarden password was entered.'
      return 1
    fi
    _vaultwarden_bw "$@" --passwordenv VAULTWARDEN_POPUP_PASSWORD --nointeraction
    unlock_status=$?
  } always {
    VAULTWARDEN_POPUP_PASSWORD=''
    unset VAULTWARDEN_POPUP_PASSWORD
  }
  return $unlock_status
}
