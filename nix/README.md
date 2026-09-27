# Mac package management

This flake manages the Apple Silicon Mac with Lix and nix-darwin 26.05. The
original machine inventory is in
[Homebrew inventory](homebrew-inventory-2026-09-26.md) and
[application inventory](application-inventory-2026-09-26.md). Those files are
dated snapshots; `flake.nix` is the package declaration.

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
| nix-darwin Homebrew Bundle | AWS CLI v1/v2, Coder, GitLab CLI, Node 26 and Node 24, NVM, Terraform, Vault, Apache Jackrabbit FileVault CLI, NetBird, XcodeGen, and the old unlinked Homebrew Zsh; Claude, Claude Code, Codex, Ghostty, and OrbStack casks. |
| nix-darwin Mac App Store declaration | Xcode, WhatsApp, and Unzip - RAR ZIP 7Z Unarchiver. |
| Existing vendor or app updater | Adobe Creative Cloud and Lightroom, Arc, Beeper, ChatGPT Classic, Docker Desktop, Firefox, Folx, Chrome, JetBrains Toolbox and its IDEs, NetBird GUI, Obsidian, OpenCode Desktop, Raycast, Slack, Spark, Spotify, TickTick, VLC, and Wispr Flow. |
| User runtime | NVM's Node 24, npm, Corepack, project selected pnpm versions, Zinit shell plugins, and the global npm `nx` installation. |

Homebrew formulae already replaced by native Nix are unlinked but still
installed as rollback copies. `homebrew.onActivation.cleanup = "none"` means a
switch will not delete them. Homebrew's transitive libraries are deliberately
not listed in the flake.

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
- Existing GUI apps have vendor updater state, login items, permissions, and
  sometimes privileged helpers. Homebrew's cask `--adopt` only accepts
  identical existing app artifacts. Declaring the rest as casks now could
  trigger downloads and replacement of running apps. Available disk space is
  too low to duplicate the larger apps for native Nix launch testing.
- `.zshrc` contains credential assignments. Move those credentials to
  protected runtime storage before managing the shell file through Nix;
  values placed in a Nix expression can become readable in the Nix store.

Check the active command with `type -a <command>` in a fresh interactive login
shell. `brew list --formula --versions`, `brew list --cask --versions`, and
`mas list` (available through `nix shell nixpkgs#mas --command mas list`) refresh
the external package inventory.
