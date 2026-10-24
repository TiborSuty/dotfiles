# GUI application declarations and adoption status

Snapshot: **2026-10-24**, Apple Silicon, macOS **15.7.3**, Homebrew **7.0.10**.
Versions below come from installed app `Info.plist` files, not cask receipts.
The [flake](flake.nix) is the package declaration.

## Ownership

The declarations cover **30 primary third-party GUI apps**: 19 GUI casks,
3 Mac App Store apps, and 8 explicit vendor-managed exceptions. The flake
also declares Claude Code and Codex CLI, for **21 casks** in total.

**Activation is pending.** Six of the 16 added casks were adopted successfully.
Ten need local administrator authentication for Homebrew's app-permissions
step. There are currently 11 registered casks, including the five existing
ones; nix-darwin generation 7 remains active.
Safari is supplied by macOS; the Claude Code URL Handler is a helper rather
than an independent application.

| Application | Installed version | Installation owner | Decision |
| --- | --- | --- | --- |
| Adobe Creative Cloud | 6.11.0.479 | Vendor / existing installer | Adobe installer and background services; retain vendor ownership. |
| Adobe Lightroom | 9.6 | Vendor / existing installer | Installed and updated through Adobe Creative Cloud. |
| Arc | 1.164.0 | Vendor / existing installer | Homebrew marks the cask deprecated because the upstream app is discontinued; retain the existing install. |
| Beeper Desktop | 4.3.229 | `beeper` cask | Existing bundle adopted. |
| ChatGPT Classic | 1.2026.184 | Vendor / existing installer | The current ChatGPT cask targets a different bundle (`ChatGPT.app`); preserve Classic. |
| Claude | 1.49585.0 | `claude` cask | Previously declared; retained. |
| DataGrip | 2026.2.4 | Vendor / existing installer | Managed by JetBrains Toolbox; do not add a second IDE owner. |
| Docker | 4.85.0 | Vendor / existing installer | Keep the current Docker Desktop helpers and CLI setup; OrbStack remains the active Docker context. |
| Firefox | 155.0.1 | `firefox` cask | Existing bundle adopted. CLI artifacts disabled. |
| Folx | 5.34 | `folx` cask | Existing bundle adopted. |
| Ghostty | 1.3.0 | `ghostty` cask | Previously declared; retained. |
| Google Chrome | 155.0.8059.86 | `google-chrome` cask declaration | Adoption pending administrator authentication. |
| JetBrains Toolbox | 3.9.0.88839 | `jetbrains-toolbox` cask declaration | Adoption pending administrator authentication. |
| Microsoft Edge | 156.0.4314.42 | `microsoft-edge` cask | Existing bundle adopted. |
| NetBird | 0.81.3 | Vendor / existing installer | Keep the vendor GUI and privileged VPN integration; the CLI remains a declared Homebrew fallback. |
| Obsidian | 1.11.7 | `obsidian` cask declaration | Adoption pending administrator authentication. CLI artifacts disabled. |
| OpenCode | 1.2.22 | `opencode-desktop` cask | Existing bundle adopted. |
| OrbStack | 2.2.3 | `orbstack` cask | Previously declared; retained. |
| Raycast | 1.104.31 | `raycast` cask declaration | Adoption pending administrator authentication. |
| RescueTime | 3.2.12.3 | `rescuetime` cask declaration | Adoption pending administrator authentication. |
| Slack | 4.52.182 | `slack` cask declaration | Adoption pending administrator authentication. |
| Spark Desktop | 3.27.9 | `readdle-spark` cask declaration | Adoption pending administrator authentication. |
| Spotify | 1.3.6.1921 | `spotify` cask | Existing bundle adopted. |
| TickTick | 8.0.10 | `ticktick` cask declaration | Adoption pending administrator authentication. |
| Unzip - RAR ZIP 7Z Unarchiver | 2.5.1 | Mac App Store | Existing receipt matches the declared app ID. |
| VLC | 3.0.23 | `vlc` cask declaration | Adoption pending administrator authentication. CLI artifacts disabled. |
| WebStorm | 2025.3.3 | Vendor / existing installer | Managed by JetBrains Toolbox; do not add a second IDE owner. |
| WhatsApp | 26.28.75 | Mac App Store | Existing receipt matches the declared app ID. |
| Wispr Flow | 1.4.351 | `wispr-flow` cask declaration | Adoption pending administrator authentication. |
| Xcode | 26.3 | Mac App Store | Existing receipt matches the declared app ID. |

## Adoption behavior

Sixteen existing apps were selected for `brew install --cask --adopt`. Each
selected cask declares `auto_updates true`, targets the installed app path,
and has no package installer or installation flight steps. The installed
Homebrew implementation skips version comparison for these self-updating
apps, removes the downloaded staging copy, and registers the original app.
It does not replace the original bundle. Homebrew also normalizes app file
permissions/group ownership and may add Finder alternate-name metadata.
Those permission operations can require local administrator authentication,
even when the bundle contents are preserved.

Firefox, Obsidian, and VLC use `args.no_binaries = true` in the flake and
`--no-binaries` during adoption. This avoids additional CLI wrappers and avoids
linking the newer Obsidian cask's CLI into an older existing app that lacks it.
The `readdle-spark` cask targets Spark Desktop; the similarly named `spark`
alias resolves to an unrelated launcher and is not used.

Homebrew receipts record the downloaded cask version, which can differ from
the preserved app's version. GUI installation ownership is declarative;
versions remain under the apps' existing update mechanisms. System switches
keep `autoUpdate = false`, `upgrade = false`, and `cleanup = "none"`.
No force installation, app removal, cache cleanup, or app-data cleanup is
part of this migration.

## Verification

- The nix-darwin build passed; its generated Brewfile contains all 21 casks,
  the existing 13 formula declarations, and the 3 Mac App Store apps.
- All **16 original bundle inodes, bundle IDs, versions, and 9,618 file/link
  entries** match the pre-adoption snapshot. The file contents total about
  6.80 GiB. Failed registration attempts left the original app contents in place.
- The five pre-existing cask receipts are unchanged; `brew missing` passes.
- `brew bundle check --no-upgrade --verbose` reports exactly the ten casks
  marked pending above; every other Brewfile entry is satisfied.
- The three App Store receipts match the declared IDs. Docker still selects
  the `orbstack` context.
- Apps were not relaunched. This verifies registration and preserved bundle
  contents, not interactive app workflows or the pending system activation.

Raw inventory, cask metadata, per-app installation logs, file/link fingerprints,
and verification results are saved locally under
`~/.local/state/nix-darwin/gui-migration-20261024/`.

## Finish activation

Run in a local terminal with administrator authentication:

```sh
sudo /run/current-system/sw/bin/darwin-rebuild switch --flake /Users/tiborsuty/dotfiles/nix#m1pro
```

Homebrew Bundle uses adoption for the remaining installed app bundles. Then
rerun the bundle-content and dependency verification:

```sh
python3 ~/.local/state/nix-darwin/gui-migration-20261024/verify-adoption.py
```

The final check must report no pending casks and a successful Brewfile check.
Confirm the new active generation before treating activation as complete.
