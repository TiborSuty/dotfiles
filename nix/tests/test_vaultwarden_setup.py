import base64
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('vaultwarden_setup', Path(__file__).resolve().parents[1] / 'setup-vaultwarden.py')
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


class SetupTests(unittest.TestCase):
    def test_accepts_copied_api_key_formats_without_exposing_secret(self):
        account_id = '00000000-0000-4000-8000-000000000001'
        client_id = 'user.' + account_id
        for value in (client_id, json.dumps(client_id), 'client_id: "' + client_id + '",',
                      json.dumps({'client_id': client_id, 'client_secret': 'fixture-secret'})):
            self.assertEqual(setup.parse_client_id(value), (client_id, account_id))
        with self.assertRaises(setup.SetupError) as caught:
            setup.parse_client_id('fixture-secret')
        self.assertNotIn('fixture-secret', str(caught.exception))

    def test_process_uses_stdin_and_scoped_environment(self):
        client = setup.Setup(Path('/fixture/profile'), Path('/fixture/ca'))
        client.session = 'fixture-session'
        with patch.dict(setup.os.environ, {'BW_CLIENTSECRET': 'inherited-key', 'CARVAGO_GITHUB_ACCESS_TOKEN': 'inherited-token'}), patch.object(setup.subprocess, 'run') as run:
            run.return_value = subprocess.CompletedProcess([], 0, '{}', '')
            client.bw('create', 'item', stdin='fixture-payload', session=True)
            args, kwargs = run.call_args
            self.assertEqual(args[0], [setup.BW, 'create', 'item', '--nointeraction'])
            self.assertEqual(kwargs['input'], 'fixture-payload')
            self.assertEqual(kwargs['env']['BW_SESSION'], 'fixture-session')
            self.assertNotIn('BW_CLIENTSECRET', kwargs['env'])
            self.assertNotIn('CARVAGO_GITHUB_ACCESS_TOKEN', kwargs['env'])
            client.bw('status')
            self.assertNotIn('BW_SESSION', run.call_args.kwargs['env'])

    def test_raw_cli_error_is_not_exposed(self):
        client = setup.Setup(Path('/fixture/profile'), Path('/fixture/ca'))
        with patch.object(setup.subprocess, 'run', return_value=subprocess.CompletedProcess([], 1, 'fixture-secret', 'fixture-secret')):
            with self.assertRaises(setup.SetupError) as caught:
                client.bw('login', '--apikey')
            self.assertNotIn('fixture-secret', str(caught.exception))

    def test_incompatible_key_migration_is_not_reported_as_wrong_password(self):
        client = setup.Setup(Path('/fixture/profile'), Path('/fixture/ca'))
        with patch.object(setup.subprocess, 'run', return_value=subprocess.CompletedProcess([], 1, '', 'KeyIdBackfillError fixture-secret')):
            with self.assertRaises(setup.SetupError) as caught:
                client.bw('unlock', '--raw')
            self.assertIn('compatible versions', str(caught.exception))
            self.assertNotIn('fixture-secret', str(caught.exception))

    def test_login_credentials_are_scoped_to_each_operation(self):
        new_id = '00000000-0000-4000-8000-000000000001'
        calls = []

        def fake_bw(*args, **kwargs):
            calls.append((args, kwargs))
            if args == ('status',):
                return json.dumps({'userId': new_id, 'serverUrl': setup.SERVER})
            return 'fixture-session' if args[0] == 'unlock' else ''

        client = setup.Setup(Path('/fixture/profile'), Path('/fixture/ca'))
        client.bw = fake_bw
        with patch.object(setup, 'prompt', side_effect=['user.' + new_id, 'fixture-api-key', 'fixture-master-password']), contextlib.redirect_stdout(io.StringIO()):
            client.login('previous-user-id')
        for args, kwargs in calls:
            self.assertFalse(any('fixture-' in arg for arg in args))
            extra = kwargs.get('extra', {})
            if args[0] == 'login':
                self.assertEqual(extra['BW_CLIENTSECRET'], 'fixture-api-key')
                self.assertNotIn('VAULTWARDEN_SETUP_PASSWORD', extra)
            elif args[0] == 'unlock':
                self.assertEqual(extra, {'VAULTWARDEN_SETUP_PASSWORD': 'fixture-master-password'})
            else:
                self.assertFalse(extra)

    def token_client(self):
        client = setup.Setup(Path('/fixture/profile'), Path('/fixture/ca'))
        client.session = 'fixture-session'
        items = {}
        creates = []

        def fake_bw(*args, **kwargs):
            if args[:2] == ('list', 'items'):
                return json.dumps([items[args[3]]] if args[3] in items else [])
            if args[:2] == ('get', 'template'):
                return '{}'
            if args[:2] == ('create', 'item'):
                self.assertEqual(len(args), 2)
                self.assertTrue(kwargs['session'])
                item = json.loads(base64.b64decode(kwargs['stdin']))
                items[item['name']] = item
                creates.append(item['name'])
                return '{}'
            if args[:2] == ('get', 'password'):
                return items[args[2]]['login']['password']
            if args == ('sync',):
                return ''
            raise AssertionError('Unexpected mocked CLI command')

        client.bw = fake_bw
        return client, items, creates

    def test_creates_three_password_fields_without_overwriting_on_retry(self):
        client, items, creates = self.token_client()
        with patch.object(setup, 'prompt', side_effect=['fixture-github', 'fixture-gitlab', 'fixture-phrase']), contextlib.redirect_stdout(io.StringIO()):
            client.add_tokens()
        self.assertEqual(creates, [name for name, _ in setup.ITEMS])
        self.assertTrue(all(item['type'] == 1 for item in items.values()))
        with patch.object(setup, 'prompt') as prompt, contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(client.add_tokens(), [])
            prompt.assert_not_called()

    def test_cancel_during_collection_creates_nothing(self):
        client, items, creates = self.token_client()
        with patch.object(setup, 'prompt', side_effect=['fixture-github', setup.SetupError('Cancelled')]):
            with self.assertRaises(setup.SetupError):
                client.add_tokens()
        self.assertFalse(items)
        self.assertFalse(creates)

    def test_empty_existing_item_is_not_overwritten(self):
        client, items, creates = self.token_client()
        name = setup.ITEMS[0][0]
        items[name] = {'name': name, 'login': {'password': ''}}
        with patch.object(setup, 'prompt') as prompt:
            with self.assertRaises(setup.SetupError):
                client.add_tokens()
            prompt.assert_not_called()
        self.assertFalse(creates)

    def test_profile_switch_preserves_previous_data(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            active, staged, backup = (root / name for name in ('active', 'staged', 'backup'))
            for path, contents in ((active, 'old-profile'), (staged, 'new-profile')):
                path.mkdir()
                (path / 'data.json').write_text(contents)
            setup.promote_profile(staged, active, backup, setup.fingerprint(active))
            self.assertEqual((active / 'data.json').read_text(), 'new-profile')
            self.assertEqual((backup / 'data.json').read_text(), 'old-profile')

    def test_profile_change_aborts_before_switching(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            active, staged, backup = (root / name for name in ('active', 'staged', 'backup'))
            active.mkdir()
            staged.mkdir()
            (active / 'data.json').write_text('old-profile')
            fingerprint = setup.fingerprint(active)
            (active / 'data.json').write_text('changed-profile')
            with self.assertRaises(setup.SetupError):
                setup.promote_profile(staged, active, backup, fingerprint)
            self.assertFalse(backup.exists())
            self.assertEqual((active / 'data.json').read_text(), 'changed-profile')

    def test_existing_backup_is_never_replaced(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            active, staged, backup = (root / name for name in ('active', 'staged', 'backup'))
            for path in (active, staged, backup):
                path.mkdir()
            (active / 'data.json').write_text('old-profile')
            with self.assertRaises(setup.SetupError):
                setup.promote_profile(staged, active, backup, setup.fingerprint(active))
            self.assertEqual((active / 'data.json').read_text(), 'old-profile')
            self.assertEqual(list(backup.iterdir()), [])

    def test_install_failure_restores_previous_profile(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            active, staged, backup = (root / name for name in ('active', 'staged', 'backup'))
            for path, contents in ((active, 'old-profile'), (staged, 'new-profile')):
                path.mkdir()
                (path / 'data.json').write_text(contents)
            original_rename = Path.rename

            def rename(path, target):
                if path == staged:
                    raise OSError('Simulated installation failure')
                return original_rename(path, target)

            with patch.object(Path, 'rename', rename), self.assertRaises(setup.SetupError):
                setup.promote_profile(staged, active, backup, setup.fingerprint(active))
            self.assertEqual((active / 'data.json').read_text(), 'old-profile')
            self.assertEqual((staged / 'data.json').read_text(), 'new-profile')
            self.assertFalse(backup.exists())


if __name__ == '__main__':
    unittest.main()
