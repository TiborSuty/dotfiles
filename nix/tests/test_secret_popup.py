"""Check the popup adapter with fake credentials; never open a real vault."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[2]
ZSH = '/run/current-system/sw/bin/zsh'
# Use the real command wrapper without loading interactive plugins or NVM.
CONFIG = (REPO / '.zshrc').read_text()
WRAPPER = CONFIG.split('_vaultwarden_bw_with_session() {', 1)[1].split('\nexport NVM_DIR=', 1)[0]
WRAPPER = '_vaultwarden_bw_with_session() {' + WRAPPER

HARNESS = r'''
source "$POPUP_HELPER"
_vaultwarden_popup_password() {
  case "$SCENARIO" in
    cancel) return 130 ;;
    empty) return 0 ;;
    *) print -rn -- "$FAKE_PASSWORD" ;;
  esac
}
_vaultwarden_bw() {
  case "$1" in
    unlock)
      [[ "$*" == 'unlock --raw --passwordenv VAULTWARDEN_POPUP_PASSWORD --nointeraction' ]] || return 90
      [[ "$VAULTWARDEN_POPUP_PASSWORD" == "$FAKE_PASSWORD" ]] || return 91
      python3 -c 'import os; assert os.environ["VAULTWARDEN_POPUP_PASSWORD"] == os.environ["FAKE_PASSWORD"]' || return 91
      [[ "$SCENARIO" == unlock_failure ]] && return 27
      print -rn -- 'fake-session'
      ;;
    sync|get)
      [[ -z ${VAULTWARDEN_POPUP_PASSWORD:-} && "$BW_SESSION" == fake-session ]] || return 92
      [[ "$SCENARIO" == sync_failure && "$1" == sync ]] && return 28
      [[ "$SCENARIO" == lookup_failure && "$1" == get ]] && return 29
      [[ "$1" == get ]] && print -rn -- 'fake-token'
      return 0
      ;;
    lock)
      [[ -z ${VAULTWARDEN_POPUP_PASSWORD:-} && -z ${BW_SESSION:-} ]] || return 93
      test_locked=1
      ;;
    *) return 94 ;;
  esac
}
bw() { _vaultwarden_popup_bw "$@"; }
typeset -g test_locked=0
if [[ "$SCENARIO" == direct_unlock_failure ]]; then
  SCENARIO=unlock_failure
  payload="$(_vaultwarden_popup_bw unlock --raw)"
  actual_status=$?
  [[ "$actual_status" == 27 && -z "$payload" && -z ${VAULTWARDEN_POPUP_PASSWORD:-} ]] || exit 95
  exit 0
fi
setopt xtrace
with_dev_secrets python3 -c '
import os, pathlib, sys
pathlib.Path(os.environ["CHILD_MARKER"]).touch()
tokens = ("CARVAGO_GITHUB_ACCESS_TOKEN", "CARVAGO_GITLAB_ACCESS_TOKEN", "PHRASE_STRINGS_TOKEN")
private = ("BW_SESSION", "VAULTWARDEN_POPUP_PASSWORD")
ok = all(os.environ.get(k) == "fake-token" for k in tokens) and not any(os.environ.get(k) for k in private)
sys.exit(23 if ok else 31)
'
actual_status=$?
unsetopt xtrace
expected_status=1
[[ "$SCENARIO" == success ]] && expected_status=23
[[ "$actual_status" == "$expected_status" && "$test_locked" == 1 ]] || exit 96
for name in CARVAGO_GITHUB_ACCESS_TOKEN CARVAGO_GITLAB_ACCESS_TOKEN PHRASE_STRINGS_TOKEN BW_SESSION VAULTWARDEN_POPUP_PASSWORD; do
  [[ -z ${(P)name} ]] || exit 97
done
'''


class PopupTests(unittest.TestCase):
    def test_unlock_and_cleanup(self):
        for scenario in ('success', 'cancel', 'empty', 'unlock_failure', 'sync_failure', 'lookup_failure', 'direct_unlock_failure'):
            with self.subTest(scenario=scenario), tempfile.TemporaryDirectory() as directory:
                marker = Path(directory) / 'child-ran'
                env = {key: value for key, value in os.environ.items() if key not in (
                    'CARVAGO_GITHUB_ACCESS_TOKEN', 'CARVAGO_GITLAB_ACCESS_TOKEN',
                    'PHRASE_STRINGS_TOKEN', 'BW_SESSION', 'BW_PASSWORD', 'VAULTWARDEN_POPUP_PASSWORD')}
                # Quoting, newlines, and shell metacharacters must remain data.
                password = 'fixture-only "quote" $variable $(false) `false`\nsecond line'
                env.update(SCENARIO=scenario, FAKE_PASSWORD=password,
                           POPUP_HELPER=str(REPO / 'nix/vaultwarden-popup.zsh'),
                           CHILD_MARKER=str(marker))
                result = subprocess.run([ZSH, '-dfc', WRAPPER + '\n' + HARNESS],
                                        env=env, capture_output=True, text=True, timeout=15)
                output = result.stdout + result.stderr
                # Do not include subprocess output in failures; it may itself
                # be evidence of a credential leak.
                self.assertEqual(result.returncode, 0, f'{scenario}: status {result.returncode}')
                for credential in (password, 'fixture-only', 'fake-session'):
                    self.assertTrue(credential not in output, f'{scenario}: credential appeared in output')
                self.assertEqual(marker.exists(), scenario == 'success')


if __name__ == '__main__':
    unittest.main()
