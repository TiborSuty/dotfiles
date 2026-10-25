# Setup, backups, and recovery

This configuration targets an Apple Silicon Mac with the `tiborsuty` account
and the repository at `~/dotfiles`. The flake output is `m1pro`; it does not
require the computer's hostname to be `m1pro`. For a different account, change
`system.primaryUser`, the user declaration, and the Home Manager user in
`flake.nix` before activation.

## What can be reproduced

`flake.lock` pins Nix packages, nix-darwin, and Home Manager. Git records the
configuration, Neovim's plugin lockfile, and the tmux submodule revisions.
Home Manager links writable Neovim, tmux, Git, and Coder configuration to
`~/dotfiles`; that checkout must remain available at that location.

Homebrew and Mac App Store declarations describe the required applications,
not frozen versions. Vendor app updates, NVM runtimes, project dependencies,
Mason tools, application data, permissions, and account sign-ins have their own
state. A clean-checkout Nix build checks the committed configuration using the
existing Nix store and caches; it is not a test of reinstalling macOS.

## Fresh Mac setup

1. Create the intended macOS account. Install Apple's Command Line Tools with
   `xcode-select --install` if Git is unavailable. Sign into the Mac App Store
   account that owns Xcode, WhatsApp, and Unzip.
2. Install Homebrew in `/opt/homebrew` using its
   [official installation instructions](https://docs.brew.sh/Installation).
   Install Lix using the [official Lix installer](https://lix.systems/install/).
   Open a new terminal and check `nix --version` and `brew --version`.
3. Restore the audited repository to `~/dotfiles`. Use the local Git bundle
   described below, or a trusted remote containing the desired commit. The
   audit's changes are local until explicitly published.

   ```sh
   git clone --recurse-submodules https://github.com/TiborSuty/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   git submodule update --init --recursive
   git status --short
   ```

   With a bundle instead of a remote, replace the clone URL with the path to
   `dotfiles.bundle`. The seven submodules are separate repositories; their
   bundle backups can also be used if GitHub is unavailable.
4. Build before activation, without changing the lockfile:

   ```sh
   cd ~/dotfiles/nix
   nix build --extra-experimental-features 'nix-command flakes' \
     --no-update-lock-file .#darwinConfigurations.m1pro.system
   ```

5. Enable App Management for the terminal in macOS Privacy & Security settings
   if adopting existing apps. Apply the already-built nix-darwin tooling:

   ```sh
   sudo ./result/sw/bin/darwin-rebuild switch --flake .#m1pro
   ```

   This follows the [nix-darwin bootstrap model](https://github.com/nix-darwin/nix-darwin/blob/nix-darwin-26.05/README.md).
   Home Manager preserves conflicting existing files with a
   `.before-home-manager` suffix. If one of those backups already exists,
   inspect and preserve it before retrying; do not overwrite it blindly.
6. Open a new login shell. The NVM loader can initialize from the declared
   Homebrew NVM package when `~/.config/nvm/nvm.sh` is absent. Install the
   currently used runtime and enable its package-manager shims:

   ```sh
   nvm install 24.21.0
   nvm alias default 24
   nvm use 24
   corepack enable
   ```

   Keep each project's `packageManager` selection. The verified projects use
   pnpm 10.29.2 for Loky Planner and 10.33.2 for OpenDesign. Run `pnpm --version`
   inside the project before installing its dependencies.
7. Open Neovim and restore plugins from its committed lockfile with
   `:Lazy restore`. Initialize tmux's submodules before starting tmux; its TPM
   checkout is under `~/.config/tmux/plugins/tpm`. The `tv sesh` channel and
   Coder helper links are declared in Home Manager. The Coder update helper
   uploads files and restarts a remote workspace only when explicitly invoked;
   it is not part of setup or verification.
8. Configure Vaultwarden's server with `bw config server <your-server-url>` and
   authenticate with `bw login` or `bw login --apikey` as appropriate for the
   account. Restore access to the three referenced vault items. The public
   private-CA certificate is in the repository; tokens and account state are not.
   API-key login still requires a master-password unlock before reading vault
   data. See the [Bitwarden CLI documentation](https://bitwarden.com/help/cli/).

   ```sh
   zsh ~/dotfiles/nix/check-secrets.zsh
   ```

   This opens a macOS password popup, verifies command-scoped injection of three
   nonempty tokens, checks a deliberate child failure is propagated, and confirms the
   parent shell is clean and the vault reports locked. It prints no token or
   session values and does not save the password. Cancellation or a three-minute
   timeout stops the check. Results go to `~/.local/state/nix-darwin/secret-check.json`.
9. Restore project data, application data, SSH credentials, and vendor-managed
   apps from their separate backups. Grant application permissions as needed.
   These are outside the Nix store and are not recreated by a system switch.

## Verify an existing installation

```sh
darwin-rebuild --list-generations
readlink /run/current-system
readlink /nix/var/nix/profiles/system
brew missing
git -C ~/dotfiles submodule status --recursive
node --version
```

The active system and selected profile must resolve to the same store path.
A failed switch can select a new profile before finishing activation. Check
the switch exit status and its log as well as the generation number. Check
Ghostty with `ghostty +validate-config`, and test the editor, terminal shortcuts,
VPN, and private-network Coder workflows interactively.

## Backups and sensitive history

The original audit is under `~/.local/state/nix-darwin/recovery-audit-20261024/`.
The refreshed checkpoint, including the popup/account setup helpers, is under
`~/.local/state/nix-darwin/checkpoint-20261025/`. Its `backup/` directory contains
a parent Git bundle, bundles for all eight pinned plugin repositories (including
TPM's nested dependency), selected migration snapshots, and a checksum/commit
manifest. `recovery-backup.tar.gz` packages that directory; its checksum is in
`recovery-backup.sha256`. CLI authentication caches are outside this backup.

The checkpoint verifies an offline restore of the recorded commit and plugin
revisions into a separate directory. To repeat it, choose a new absolute path:

```sh
python3 ~/.local/state/nix-darwin/checkpoint-20261025/backup/restore.py \
  "$HOME/dotfiles-recovery-test"
```

This command does not activate the restored configuration. A fresh Mac should
restore the repository to `~/dotfiles` before following the setup steps above.
The recovery archive is a private local copy; an off-device copy is still needed.

Time Machine reported no configured destination during the audit. Set up an
encrypted off-device backup for the home directory and copy the recovery
archive to a destination you control. Include project data, SSH material,
vendor application data, NVM runtimes or their version inventory, and the
original Home Manager/preference snapshots. Keep Vaultwarden recovery access
and an encrypted vault backup separately.

The targeted current-tree secret scan found no token literals, but two older
`.zshrc` revisions contain development-token assignments. Git bundles include
that history and must be treated as sensitive. Confirm that the exposed tokens
have been revoked and replaced at their providers; moving them into a vault
does not revoke old copies. Historical cleanup and any force-push require a
separate coordinated decision. No history was rewritten or remote updated by
this audit. The live vault test does not prove historical tokens were rotated.

## Rollback

For an activation regression, inspect the available generations, then select
the known-good one explicitly:

```sh
darwin-rebuild --list-generations
sudo darwin-rebuild switch --switch-generation 11
```

Generation 11 is the verified system checkpoint, built from commit `ac54595`.
Generation 10 is the earlier checkpoint before the final bootstrap fixes.
The later standalone helper/documentation changes do not require activation.
Use `sudo darwin-rebuild switch --rollback` only when the immediately preceding
generation is the intended target. Compare the active and selected system
paths and check the activation log after rollback.

Nix rollback does not roll back Homebrew/vendor app versions, NVM/project
runtimes, application data, or mutable configuration linked to `~/dotfiles`.
Restore those files from Git or a backup separately. Removing a macOS defaults
declaration does not delete its persisted preference keys. The original
preference exports are under `preferences-migration-20261024`; restore only
the affected keys if needed rather than overwriting an entire live domain.

For Home Manager's first migration, the original links/files are under
`home-manager-migration-20261024-104516` and in `.before-home-manager` backups.
Keep them until recovery is verified. Retain the working Nix generations and
store closures while testing; package cleanup and garbage collection are
separate operations.
