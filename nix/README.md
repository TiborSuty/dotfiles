# Mac configuration

This flake manages the Apple Silicon Mac with Lix, nix-darwin 26.05, and
Home Manager 26.05. The
original machine inventory is in
[Homebrew inventory](homebrew-inventory-2026-09-26.md) and
[application inventory](application-inventory-2026-09-26.md). Those files are
dated snapshots; `flake.nix` is the package declaration. The
[current application inventory](application-inventory-2026-10-24.md) records
GUI app ownership and the cask adoption checks.

## Apply and verify

```sh
cd ~/dotfiles/nix
darwin-rebuild build --flake .#m1pro
sudo darwin-rebuild switch --flake .#m1pro
brew missing
```

The switch runs Homebrew Bundle without package upgrades or automatic cleanup.
It also checks the declared Mac App Store apps. A fresh login shell is needed
after a switch to see all PATH changes. `darwin-rebuild --list-generations`
lists rollback points; `sudo darwin-rebuild switch --rollback` activates the
previous generation.

## Current ownership

| Owner | Packages |
| --- | --- |
| Native Nix | The CLI tools in `environment.systemPackages`, including Neovim, tmux, Kubernetes and Talos tools, Rustup, uv, OpenTofu, CodeCrafters, and the shell utilities. Lix is the Nix implementation. |
| nix-darwin Homebrew Bundle | AWS CLI v1/v2, Coder, GitLab CLI, Node 26 and Node 24, NVM, Terraform, Vault, Apache Jackrabbit FileVault CLI, NetBird, XcodeGen, and the old unlinked Homebrew Zsh; the 21 casks declared in `flake.nix`, including 19 GUI apps plus Claude Code and Codex CLI. |
| nix-darwin Mac App Store declaration | Xcode, WhatsApp, and Unzip - RAR ZIP 7Z Unarchiver. |
| Home Manager | Zsh initialization and pinned shell plugins, Git settings, Starship, Ghostty, the Vaultwarden CA certificate, and links to the writable Neovim, tmux, and Git ignore configuration. |
| Existing vendor installation | Adobe Creative Cloud and Lightroom, Arc, ChatGPT Classic, Docker Desktop, NetBird GUI, and the JetBrains Toolbox-managed DataGrip and WebStorm installations. |
| User runtime | NVM's Node 24, npm, Corepack, project selected pnpm versions, Neovim and tmux plugin managers, and the global npm `nx` installation. |

The 33 Homebrew formulae already replaced by Nix and their 63 unused
dependencies were removed on 2026-10-24. The 13 declared fallback formulae and
their 66 dependencies remain installed; `brew missing` and
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
the explicit exceptions. Six added casks are registered; ten remain blocked
at Homebrew's app-permissions step. The attempted switch
selected generation 8, but generation 7 remains active because activation
failed. Reapplying an existing app's group returned `Operation not permitted`
despite correct ownership and no immutable file flags. This points to macOS
App Management access for the terminal running Homebrew; an administrator
password alone may not resolve it. See the inventory's
[activation recovery steps](application-inventory-2026-10-24.md#finish-activation).

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

The NVM/Corepack setup still chooses project runtimes. Shell startup does not
download plugins or replace the project-selected Node/pnpm versions. The old
Zinit checkout is retained as a rollback copy.

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

- Coder's current server hostname does not resolve off the private network.
  The pinned Nix Coder 2.36.6 package also requires a Terraform source build;
  that build was stopped when available disk space fell to about 7 GiB. Keep
  the working Homebrew Coder 2.35.6 until a server test and more disk space are
  available.
- Pinned Nix AWS CLI, GitLab CLI, and XcodeGen are older than the installed
  Homebrew commands. Nix Terraform 1.16 is newer than the installed 1.15 and
  could affect project state. Nix Vault is a newer major release. NetBird
  uses a running privileged VPN helper. These remain explicit Homebrew
  fallbacks until each workflow can be tested.
- Node and pnpm are selected per project. `loky-planner` declares pnpm
  10.29.2; `open-design` declares 10.33.2. Replacing NVM/Corepack globally
  would override that selection. The Nix pnpm 10 package is available but
  does not win over the active NVM Corepack shim in interactive shells.
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
