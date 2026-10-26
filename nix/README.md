# Mac configuration

This flake manages the Apple Silicon Mac with Lix, nix-darwin 26.05, and
Home Manager 26.05. The
original machine inventory is in
[Homebrew inventory](homebrew-inventory-2026-09-26.md) and
[application inventory](application-inventory-2026-09-26.md). Those files are
dated snapshots; `flake.nix` is the package declaration. The
[current application inventory](application-inventory-2026-10-24.md) records
GUI app ownership and the cask adoption checks.
Fresh-Mac setup, local backups, and rollback are covered in
[Setup and recovery](RECOVERY.md).

## Apply and verify

```sh
cd ~/dotfiles/nix
darwin-rebuild build --flake .#m1pro
sudo darwin-rebuild switch --flake .#m1pro
brew missing
```

The switch runs Homebrew Bundle without package upgrades or automatic cleanup.
It also checks the declared Mac App Store apps. A fresh login shell is needed
after a switch to see all PATH changes. `sudo darwin-rebuild --list-generations`
lists rollback points; `sudo darwin-rebuild switch --rollback` activates the
previous generation.

## Current ownership

| Owner | Packages |
| --- | --- |
| Native Nix | The CLI tools in `environment.systemPackages`, including Neovim, tmux, Kubernetes and Talos tools, Rustup, uv, OpenTofu, CodeCrafters, and the shell utilities. Lix is the Nix implementation. |
| nix-darwin Homebrew Bundle | AWS CLI v1/v2, Coder, GitLab CLI, Node 26 and Node 24, NVM, Terraform, Vault, Apache Jackrabbit FileVault CLI, NetBird, and XcodeGen; the 21 casks declared in `flake.nix`, including 19 GUI apps plus Claude Code and Codex CLI. |
| nix-darwin Mac App Store declaration | Xcode, WhatsApp, and Unzip - RAR ZIP 7Z Unarchiver. |
| Home Manager | Zsh initialization and pinned shell plugins, Git settings, Starship, Ghostty, the Vaultwarden CA certificate, the Television sesh channel, and links to writable Neovim, tmux, Git ignore, and Coder configuration and its launcher. |
| nix-darwin macOS preferences | Existing Dock, Finder, typing, and trackpad settings in `preferences.nix`; active and verified in generation 11. |
| Existing vendor installation | Adobe Creative Cloud and Lightroom, Arc, ChatGPT Classic, Docker Desktop, NetBird GUI, and the JetBrains Toolbox-managed DataGrip and WebStorm installations. |
| User runtime | NVM's Node 24, npm, Corepack, project selected pnpm versions, Neovim and tmux plugin managers, and the global npm `nx` installation. |

The 33 Homebrew formulae already replaced by Nix and their 63 unused
dependencies were removed on 2026-10-24. Homebrew Zsh and its unused ncurses
dependency were removed on 2026-10-26. The 12 declared fallback formulae and
their 65 dependencies remain installed; `brew missing` and
`brew autoremove --dry-run` both pass with empty output. Exact removal lists
and verification are recorded in the
[current Homebrew inventory](homebrew-inventory-2026-10-24.md).
`homebrew.onActivation.cleanup = "none"` keeps system switches from performing
automatic cleanup. Homebrew's transitive libraries are deliberately not listed
in the flake.

The additional GUI casks adopt the existing app bundles. Their vendor updaters
remain available, and activation still disables upgrades and cleanup. App
versions can therefore differ from Homebrew's cask receipts; this declares
installation ownership, not exact GUI versions. Firefox, Obsidian, and VLC use
`args.no_binaries = true` to avoid adding CLI wrappers or helper links. See the
[application inventory](application-inventory-2026-10-24.md) for each app and
the explicit exceptions. All 16 added casks are now registered, for 21 casks
in total. GUI adoption completed in generation 9; Homebrew Bundle also passed
during generation 10 activation. Adoption checks confirmed that all 16 app
bundles retained their original identities, versions, and file contents. The inventory
records the [activation and permission recovery](application-inventory-2026-10-24.md#activation-and-recovery).

## macOS preferences

`preferences.nix` captures the existing Dock, Finder, typing, and trackpad
settings. It preserves the left, auto-hiding Dock; minimization into app icons;
the Quick Note hot corner; Finder list view and desktop disk visibility;
automatic capitalization and periods; and the existing trackpad behavior.
Keyboard repeat and other unset preferences remain controlled by macOS.

Built-in and Bluetooth trackpads retain their separate scopes. Two click
preferences are written with `defaults -currentHost` because the existing
values are host-specific. Future changes to declared preferences belong in
`preferences.nix`; a switch reapplies them and briefly restarts Dock.

Generation 12 is active and matches the selected system profile. The preference
audit performed on generation 11 found all 51 managed entries matching the
saved settings, and all 24 checked unmanaged settings retained their original
values or absence. The
[preference inventory](preferences-inventory-2026-10-24.md) records the saved
snapshot, successful activation log, and read-only verification command.

## Managed dotfiles

`home.nix` declares the user configuration. Edit the source in `~/dotfiles`,
then build and switch with the commands above. Home Manager generates the live
Zsh files; the repository `.zshrc` is the custom initialization fragment, not a
standalone replacement for the generated file.

| Configuration | Source and behavior |
| --- | --- |
| Zsh | `.zshrc`, `.zprofile`, and `nix/home.nix`. NVM initialization, aliases, key bindings, and the Vaultwarden wrapper are preserved. |
| Shell plugins | Completions, autosuggestions, syntax highlighting, fzf-tab, and the selected Oh My Zsh snippets come from the pinned Nix packages. Zinit and the old Powerlevel10k bootstrap are no longer loaded. |
| Git identity | `.gitconfig`, copied from the existing local configuration. |
| Starship, Ghostty, Vaultwarden CA | The corresponding `.config` directories are linked to snapshots in the Nix store. Edit the repository copies and rebuild. |
| Neovim, tmux, Git ignore | Home Manager owns links to the existing repository directories. These stay writable for LazyVim lockfiles, TPM plugins, and tools that update Git ignore rules. Edits take effect directly; their exact contents are tracked by Git rather than frozen in each Nix generation. |
| Coder helper | `.config/coder` and the `~/.local/bin/update-frontend-coder` link are declared in Home Manager. The helper runs only on explicit invocation. |
| Television sesh channel | `.config/television/cable/sesh.toml` supplies the tmux popup's channel. Other Television channels retain their current ownership. |

The NVM/Corepack setup still chooses project runtimes. Shell startup does not
download plugins or replace the project-selected Node/pnpm versions. The old
Zinit checkout is retained as a rollback copy.

The final audit records the existing Neovim lockfile and tmux submodule URLs,
preserves the current key bindings, and ignores the local `.nvimlog` file.
Ghostty uses the bundled `Catppuccin Mocha` theme and a declared FiraCode Nerd
Font package. Shell startup adds the local binary path directly and can load
NVM from Homebrew on a fresh account. These final bootstrap fixes were activated
and verified in generation 11, built from commit `ac54595`.

The 2026-10-25 checkpoint adds standalone Vaultwarden setup/check helpers and
their tests. These run directly from the checkout and require no system switch.
Its clean-checkout build and recovery artifacts are recorded under
`~/.local/state/nix-darwin/checkpoint-20261025/`. Token entry into the new account
is deferred; an authenticated, locked profile is available for `--resume`.

The first migration saves the original files and link manifest under
`~/.local/state/nix-darwin/home-manager-migration-20261024-104516/`.
Home Manager also preserves replaced regular files with a
`.before-home-manager` suffix. No existing backup is overwritten.

Future nix-darwin switches and rollbacks include Home Manager. Rolling back to
a system generation from before Home Manager was introduced does not restore
the old home files automatically; use the saved originals and link manifest
for that first-migration rollback. Keep the backups until the new setup has
been verified in your normal terminal and applications.

## Remaining migration boundaries

The [2026-10-26 fallback audit](homebrew-inventory-2026-10-24.md#follow-up-audit-2026-10-26)
records installed versions, both pinned Nix alternatives, and the remaining
checks. After removing Homebrew Zsh and its unused ncurses dependency,
**12 Homebrew fallback formulae** remain.

- Homebrew Zsh was uninstalled and removed from `flake.nix`. Nix Zsh 5.9.1
  and the account's Apple Zsh both pass login-shell startup checks.
  Generation 12 is active with the updated Brewfile and 12 fallback formulae.
- Coder connectivity and server-version checks are deferred at the user's
  request. The earlier 2026-10-26 audit found an expired NetBird login and
  failed Coder hostname resolution. Keep the existing Coder CLI and NetBird
  integration; revisit those checks only when this work is resumed.
- The output build plans require source builds for unstable Coder 2.36.6
  with Terraform 1.16.3, stable Vault 1.21.4, and stable Node 24.21.0.
  Package-cache cleanup on 2026-10-26 increased free space from 7.2 to
  22.5 GiB. Builds and workflow checks remain pending; run them one at a time.
  Coder checks and HashiCorp Vault migration remain deferred.
- Pinned Nix AWS CLI, GitLab CLI, and XcodeGen are older than the installed
  commands. Terraform is either older on stable or a newer minor version
  on unstable. Stable Vault 1.21.4 is a same-minor candidate for installed
  1.21.1, but Vault remains on Homebrew by choice. The
  separate Homebrew `vault-cli` is Apache Jackrabbit FileVault (`vlt`), for
  which no matching package was found in the inspected Nix definitions.
- Preserve project runtime selection through NVM/Corepack. A clean login
  shell selects Node 24.21.0, but an inherited PATH can select Homebrew
  Node 26.8.2 while pnpm still resolves through NVM. Verify the commands in
  the actual project shell before replacing either runtime.
- Homebrew 7.0.10 permits adoption of existing self-updating app bundles even
  when versions differ. The selected casks use that path and preserve the app
  contents. Adobe's installer, NetBird's privileged VPN integration, Docker's
  CLI/helper setup, the differently named ChatGPT Classic bundle, and Arc's
  deprecated cask remain exceptions. JetBrains Toolbox continues to manage
  DataGrip and WebStorm. Native Nix replacements would still need launch,
  permissions, helper, and workflow tests before replacing these apps.

Check the active command with `type -a <command>` in a fresh interactive login
shell. `brew list --formula --versions`, `brew list --cask --versions`, and
`mas list` (available through `nix shell nixpkgs#mas --command mas list`) refresh
the external package inventory.

## Development secrets

The shell stores Vaultwarden item references only. Run commands that need the
Carvago GitHub, Carvago GitLab, and Phrase tokens through:

```sh
with_dev_secrets <command> [args...]
```

The wrapper unlocks and synchronizes Vaultwarden, then reads the password fields
of `dev/carvago/github-access-token`, `dev/carvago/gitlab-access-token`, and
`dev/phrase/strings-token`. It exports the tokens only to the command and its
children, preserves the command's exit status, and locks the vault afterward.
It stops if unlocking, synchronization, or a lookup fails, or if a required
password is empty. Shell tracing is disabled inside the wrapper.

The Bitwarden CLI must already be logged in. The existing private CA is loaded
from `~/.config/bitwarden/vaultwarden-ca.crt`, unless overridden by
`VAULTWARDEN_CA_FILE` or `NODE_EXTRA_CA_CERTS`.

After removing old global token exports, clear them from any existing terminal
and start a fresh login shell:

```sh
unset CARVAGO_GITHUB_ACCESS_TOKEN CARVAGO_GITLAB_ACCESS_TOKEN PHRASE_STRINGS_TOKEN
exec zsh -l
```

Already-running applications retain their inherited environment until restarted.
Keep token values out of dotfiles and Nix expressions; Nix store files are
readable by other local users.

Run `zsh ~/dotfiles/nix/check-secrets.zsh` for a live check that prints only
pass/fail results. It opens a macOS password popup and passes the password only
to the unlock process, without saving it to a file or Keychain. Cancellation
or a three-minute timeout stops the check. This script change takes effect
without a Nix rebuild; normal `with_dev_secrets` commands retain their existing
terminal prompt. The recovery guide also records the historical-token finding
and the off-device backup boundary.

For a new account on the same homelab server, run:

```sh
python3 ~/dotfiles/nix/setup-vaultwarden.py
```

The popups ask for the new account's personal API `client_id` and `client_secret`
(web vault: Settings → Security → Keys → View API key), its master password,
and any missing development tokens. The setup creates Login items with the
required names and stores each token in its Password field. It preserves
existing items and stops on ambiguous or empty entries.

Authentication is staged in a private CLI profile. Only after all three items
are verified and the vault is locked does it replace the default CLI profile,
preserving the previous profile under `~/.local/state/nix-darwin/`. The CLI keeps
its normal authentication cache and encrypted vault data; no credential values
are written to dotfiles or printed. A final popup runs the command-scoped check.
If API login succeeds but setup stops before the account switch, use
`python3 ~/dotfiles/nix/setup-vaultwarden.py --resume` to continue with the
authenticated profile without entering the API credentials again.

Run the helper tests without opening dialogs or contacting a real vault:

```sh
cd ~/dotfiles
python3 -B -m unittest discover -s nix/tests -p 'test_*.py'
```
