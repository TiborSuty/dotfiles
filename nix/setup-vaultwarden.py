#!/usr/bin/env python3
"""Sign into a new account and add missing development tokens via local popups.

Credentials never appear in command arguments, logs, or dotfiles. The Bitwarden
CLI maintains its usual private authentication cache and encrypted vault data.
"""
import argparse
import base64
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import uuid

SERVER = 'https://vaultwarden.vaultwarden.homelab.internal'
BW = '/run/current-system/sw/bin/bw'
ITEMS = (
    ('dev/carvago/github-access-token', 'Carvago GitHub access token'),
    ('dev/carvago/gitlab-access-token', 'Carvago GitLab access token'),
    ('dev/phrase/strings-token', 'Phrase Strings access token'),
)
SECRET_ENV = (
    'BW_SESSION', 'BW_PASSWORD', 'BW_CLIENTID', 'BW_CLIENTSECRET',
    'VAULTWARDEN_POPUP_PASSWORD', 'VAULTWARDEN_SETUP_PASSWORD',
    'CARVAGO_GITHUB_ACCESS_TOKEN', 'CARVAGO_GITLAB_ACCESS_TOKEN', 'PHRASE_STRINGS_TOKEN',
    'BITWARDENCLI_DEBUG',
)
DIALOG = '''on run argv
activate
set response to display dialog (item 1 of argv) default answer "" with hidden answer buttons {"Cancel", "Continue"} default button "Continue" cancel button "Cancel" with title (item 2 of argv) giving up after 300
if gave up of response then error number -128
return text returned of response
end run
'''


class SetupError(Exception):
    """Only fixed, nonsecret messages may be used for this exception."""


def clean_environment():
    return {k: v for k, v in os.environ.items() if k not in SECRET_ENV}


def prompt(title, message):
    try:
        result = subprocess.run(['/usr/bin/osascript', '-', message, title],
                                input=DIALOG, text=True, capture_output=True,
                                env=clean_environment(), timeout=310)
    except subprocess.TimeoutExpired:
        raise SetupError('The password dialog timed out.') from None
    if result.returncode:
        raise SetupError('Setup cancelled or the password dialog could not open.')
    value = result.stdout.removesuffix('\n')
    if not value:
        raise SetupError('An empty value was entered; setup stopped.')
    return value


def fingerprint(profile):
    data = profile / 'data.json'
    return hashlib.sha256(data.read_bytes()).hexdigest() if data.exists() else None


def parse_client_id(text):
    value = text.strip()
    try:
        parsed = json.loads(value)
        value = parsed.get('client_id', '') if isinstance(parsed, dict) else parsed
    except ValueError:
        pass
    if not isinstance(value, str):
        raise SetupError('Copy client_id from the new account API key, beginning with user. followed by its UUID.')
    value = re.sub(r'''^["']?client_id["']?\s*[:=]\s*''', '', value.strip()).rstrip(',;').strip().strip('"\'')
    try:
        if not value.startswith('user.'):
            raise ValueError
        account_id = str(uuid.UUID(value.removeprefix('user.')))
    except ValueError:
        raise SetupError('Copy client_id from the new account API key, beginning with user. followed by its UUID.') from None
    return 'user.' + account_id, account_id


def promote_profile(staged, active, backup, expected_fingerprint):
    if active.is_symlink() or staged.is_symlink():
        raise SetupError('CLI profile directories must not be symlinks.')
    if backup.exists() or backup.is_symlink():
        raise SetupError('A previous CLI profile backup already exists; account switching stopped.')
    if fingerprint(active) != expected_fingerprint:
        raise SetupError('The original CLI profile changed during setup; account switching stopped.')
    moved_old = active.exists()
    if moved_old:
        active.rename(backup)
    try:
        staged.rename(active)
    except OSError:
        if moved_old and not active.exists():
            backup.rename(active)
        raise SetupError('Could not install the new CLI profile; its backup was preserved.') from None


class Setup:
    def __init__(self, profile, ca):
        self.profile = profile
        self.ca = ca
        self.session = ''

    def bw(self, *args, extra=None, stdin=None, session=False):
        env = clean_environment()
        env.update(BITWARDENCLI_APPDATA_DIR=str(self.profile),
                   NODE_EXTRA_CA_CERTS=str(self.ca), BW_NOINTERACTION='true')
        if session:
            if not self.session:
                raise SetupError('No unlocked session is available.')
            env['BW_SESSION'] = self.session
        if extra:
            env.update(extra)
        try:
            result = subprocess.run([BW, *args, '--nointeraction'], input=stdin,
                                    text=True, capture_output=True, env=env, timeout=90)
        except subprocess.TimeoutExpired:
            raise SetupError('A Vaultwarden request timed out; check the private-network connection.') from None
        if result.returncode:
            # Never print raw errors: a CLI response could contain credential data.
            diagnostic = (result.stderr + result.stdout).lower()
            if 'enotfound' in diagnostic or 'econn' in diagnostic:
                raise SetupError('Vaultwarden is unreachable; check NetBird and DNS.')
            if args[0] == 'login':
                raise SetupError('API login failed; check the new account client_id and client_secret.')
            if args[0] == 'unlock':
                if 'keyidbackfillerror' in diagnostic or 'user key id' in diagnostic or 'key_id_backfill' in diagnostic:
                    raise SetupError('Unlock hit an unsupported user-key migration; the CLI and Vaultwarden server need compatible versions.')
                if 'decryption operation failed' in diagnostic or 'cryptography error' in diagnostic:
                    raise SetupError('The CLI could not decrypt the new vault. Confirm the same master password works in the web vault; CLI compatibility may also need checking.')
                raise SetupError('Unlock failed; check the new account master password and CLI compatibility.')
            raise SetupError('A Vaultwarden operation failed; no credential response was printed.')
        return result.stdout.strip()

    def login(self, old_user_id):
        self.bw('config', 'server', SERVER)
        client_id, expected_id = parse_client_id(prompt('New account API client_id',
            'Paste client_id from the NEW account: Settings → Security → Keys → View API key.\n'
            'Expected: user.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx\n'
            'You may paste the quoted value or the API-key JSON block.\nServer: ' + SERVER))
        if expected_id == old_user_id:
            raise SetupError('Those API credentials identify the existing account. Use the new account API key.')
        client_secret = prompt('New Vaultwarden API key', 'Paste the NEW account client_secret. This is its API key, not the master password.')
        try:
            self.bw('login', '--apikey', extra={'BW_CLIENTID': client_id, 'BW_CLIENTSECRET': client_secret})
        finally:
            client_secret = ''
        status = json.loads(self.bw('status'))
        if status.get('userId') != expected_id or status.get('serverUrl', '').rstrip('/') != SERVER:
            raise SetupError('The authenticated account or server did not match the requested login.')
        self.unlock()

    def unlock(self):
        password = prompt('New account MASTER PASSWORD', 'Enter the same master password you used in the WEB VAULT to reveal the API key.\nThis is not client_secret. The setup script does not save the master password.')
        try:
            self.session = self.bw('unlock', '--raw', '--passwordenv', 'VAULTWARDEN_SETUP_PASSWORD',
                                   extra={'VAULTWARDEN_SETUP_PASSWORD': password})
        finally:
            password = ''
        if not self.session:
            raise SetupError('Unlock returned no session.')
        self.bw('sync', session=True)
        print('New account authenticated and unlocked.', flush=True)

    def add_tokens(self):
        pending = {}
        created = []
        try:
            # Collect every missing value before creating any remote items.
            for name, label in ITEMS:
                matches = [item for item in json.loads(self.bw('list', 'items', '--search', name, session=True))
                           if not item.get('deletedDate')]
                if matches:
                    if len(matches) != 1 or matches[0].get('name') != name or not (matches[0].get('login') or {}).get('password'):
                        raise SetupError('A required item name is ambiguous or has no password; existing items were not overwritten.')
                    continue
                pending[name] = prompt(label, 'Paste the ' + label + '.\nIt will be saved in your NEW vault as the Password field of:\n' + name)
            for name, value in pending.items():
                item = json.loads(self.bw('get', 'template', 'item', session=True))
                login = json.loads(self.bw('get', 'template', 'item.login', session=True))
                login.update(username='', password=value)
                item.update(type=1, name=name, login=login, organizationId=None, folderId=None)
                encoded = base64.b64encode(json.dumps(item).encode()).decode()
                try:
                    self.bw('create', 'item', stdin=encoded, session=True)
                finally:
                    login.clear()
                    item.clear()
                    encoded = ''
                created.append(name)
                print('Created vault item: ' + name, flush=True)
            self.bw('sync', session=True)
            for name, _ in ITEMS:
                token = self.bw('get', 'password', name, session=True)
                if not token or (name in pending and token != pending[name]):
                    raise SetupError('A required token could not be verified after saving.')
                token = ''
            return created
        finally:
            pending.clear()

    def lock(self):
        try:
            self.bw('lock')
        finally:
            self.session = ''


def resumable_profile(root, ca, old_user_id):
    candidates = sorted(root.glob('vaultwarden-account-*/new-cli-profile'), key=lambda p: p.stat().st_mtime, reverse=True)
    for profile in candidates:
        if profile.is_symlink() or profile.parent.is_symlink():
            continue
        status = json.loads(Setup(profile, ca).bw('status'))
        if status.get('status') == 'locked' and status.get('userId') and status['userId'] != old_user_id and status.get('serverUrl', '').rstrip('/') == SERVER:
            return profile
    raise SetupError('No authenticated new-account profile is available to resume.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--resume', action='store_true', help='Reuse a successful API login and prompt only for the master password and missing tokens.')
    args = parser.parse_args()
    os.umask(0o077)
    if os.environ.get('BITWARDENCLI_APPDATA_DIR'):
        raise SetupError('A custom CLI profile is configured; resolve that profile before switching the default account.')
    active = Path.home() / 'Library/Application Support/Bitwarden CLI'
    if active.is_symlink():
        raise SetupError('The default CLI profile is a symlink; account switching stopped.')
    ca = Path.home() / '.config/bitwarden/vaultwarden-ca.crt'
    if not ca.is_file():
        raise SetupError('The configured Vaultwarden CA certificate is missing.')
    old_status = json.loads(Setup(active, ca).bw('status'))
    baseline = fingerprint(active)
    root = Path.home() / '.local/state/nix-darwin'
    root.mkdir(parents=True, exist_ok=True)
    if args.resume:
        staged = resumable_profile(root, ca, old_status.get('userId'))
        work = staged.parent
    else:
        work = Path(tempfile.mkdtemp(prefix='vaultwarden-account-', dir=root))
        staged = work / 'new-cli-profile'
        staged.mkdir(mode=0o700)
    setup = Setup(staged, ca)
    installed = False
    try:
        if args.resume:
            print('Resuming the authenticated new account; API keys do not need to be entered again.', flush=True)
            setup.unlock()
        else:
            setup.login(old_status.get('userId'))
        created = setup.add_tokens()
        setup.lock()
        if json.loads(setup.bw('status')).get('status') != 'locked':
            raise SetupError('The new vault did not report locked; the original profile was preserved.')
        promote_profile(staged, active, work / 'previous-cli-profile', baseline)
        installed = True
        setup.profile = active
        report = {'status': 'passed', 'checked_at': datetime.datetime.now().astimezone().isoformat(),
                  'created_items': created, 'required_items_verified': 3, 'vault_locked': True,
                  'previous_profile_backup': str(work / 'previous-cli-profile')}
        (work / 'setup-verification.json').write_text(json.dumps(report, indent=2) + '\n')
        print('New account installed. Previous CLI profile preserved at: ' + str(work / 'previous-cli-profile'), flush=True)
        print('One final password popup will test the active command wrapper.', flush=True)
        env = clean_environment()
        env['TERM'] = 'xterm-256color'
        check = subprocess.run(['/bin/zsh', str(Path(__file__).with_name('check-secrets.zsh'))],
                               env=env, capture_output=True, text=True)
        if check.returncode:
            raise SetupError('The new account and three items are ready, but the final secret check did not pass. Run check-secrets.zsh again.')
        print('PASS: new account, three vault items, command-scoped injection, and cleanup verified.')
    except SetupError as error:
        (work / 'last-failure.json').write_text(json.dumps({'message': str(error), 'checked_at': datetime.datetime.now().astimezone().isoformat()}, indent=2) + '\n')
        raise
    finally:
        if not installed:
            try:
                setup.lock()
            except SetupError:
                pass
            print('The original CLI profile was preserved. Any items already created remain in the new vault.', flush=True)


if __name__ == '__main__':
    try:
        main()
    except (SetupError, OSError, ValueError) as error:
        # Unexpected OS/JSON failures may carry data; only deliberate messages
        # from SetupError are safe to display.
        print('STOP: ' + (str(error) if isinstance(error, SetupError) else 'Setup could not complete; no credential details were printed.'))
        raise SystemExit(1) from None
    except KeyboardInterrupt:
        print('STOP: Setup interrupted.')
        raise SystemExit(130) from None
