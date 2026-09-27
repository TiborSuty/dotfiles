# macOS application and Nix migration inventory

Snapshot: **2026-09-26 17:53 CEST** on an Apple Silicon Mac running macOS 15.7.3. See the [companion Homebrew inventory](homebrew-inventory-2026-09-26.md) for every installed formula and cask.

This is a machine-level inventory of application bundles, App Store receipts, background and login items, Homebrew, standalone executables, global JavaScript packages, and shell plugins. Project-local `node_modules`, CocoaPods, Composer, and Swift package locks are outside this scope. It records what is installed now; it does not imply that an application was launched or a Nix package was built successfully.

## Summary

- **28 primary third-party GUI apps**, excluding embedded helpers, Safari, and the Claude Code URL Handler.
- **3 Mac App Store receipts:** Xcode, WhatsApp, and Unzip - RAR ZIP 7Z Unarchiver.
- **46 requested Homebrew formulae**, 129 dependency formulae, and 5 casks. Compared with the [September 9 snapshot](application-inventory-2026-09-09.md), the new requested formulae are `binaryen`, `bitwarden-cli`, `node@24`, `nvm`, `pi-coding-agent`, `rustup`, and `wasm-pack`; OrbStack is the new cask and GUI app.
- At snapshot time, Nix and `darwin-rebuild` were absent and the [flake](flake.nix) was an unactivated 25.05 draft. The first nix-darwin generation was activated later on 2026-09-26. See the [current migration status](README.md) for package ownership after the snapshot.

### First bootstrap after the snapshot

Lix was installed and nix-darwin **26.05** generation 1 was activated at approximately 18:07 CEST with Neovim and tmux as the first Nix packages. A clean login shell found `nix` and `darwin-rebuild` under `/run/current-system/sw/bin`; the system managed Lix 2.94.2. The Nix daemon responded to `nix store ping`, and Homebrew's `brew missing` passed. Later generations migrated more commands and added declarative Homebrew and Mac App Store fallbacks; see the [current status](README.md).

## Primary GUI applications

Versions come from each app's `Contents/Info.plist`, not Homebrew cask receipts. “Running” means a process path was observed under that application bundle during this snapshot.

| Application | Bundle version | Installation or current evidence | Migration decision |
| --- | --- | --- | --- |
| Adobe Creative Cloud | 6.10.0.253 | Embedded app under `/Applications/Utilities`; background components running | Vendor managed; optionally bootstrap with a cask. |
| Adobe Lightroom | 9.5.1 | `/Applications/Adobe Lightroom CC` | Keep vendor managed through Creative Cloud. |
| Arc | 1.164.0 | `/Applications/Arc.app` | Cask or vendor install. |
| Beeper Desktop | 4.2.985 | Running; enabled background app registration | Recheck earlier Nix candidate on pinned nixpkgs. |
| ChatGPT Classic | 1.2026.184 | Running | Recheck earlier Nix candidate. |
| Claude Desktop | 1.49585.0 | `claude` cask installed | Keep cask or vendor install. |
| DataGrip | 2026.2.4 | `~/Applications`, installed by JetBrains Toolbox | Keep Toolbox managed. |
| Docker Desktop | 4.85.0 | Running, but Docker CLI currently selects OrbStack | Decide whether still needed before managing or removing it. |
| Firefox | 155.0.1 | `/Applications/Firefox.app` | Recheck earlier `firefox-bin` candidate. |
| Folx | 5.34 | Running | Cask or vendor install. |
| Ghostty | 1.3.0 | Running; Homebrew cask receipt remains 1.2.3 | Keep current installation until a Nix build is launch-tested, including signing and permissions. |
| Google Chrome | 154.0.8037.57 | Running | Recheck Nix candidate; cask keeps vendor updates. |
| JetBrains Toolbox | 3.8.0.87909 | `/Applications/JetBrains Toolbox.app` | Keep Toolbox for JetBrains IDEs; Nix candidate needs a launch test. |
| NetBird | 0.77.1 | Enabled background app registration and privileged helper | Preserve vendor installation until a replacement proves the helper and VPN workflow. |
| Obsidian | 1.11.7 | Running | Recheck earlier Nix candidate. |
| OpenCode Desktop | 1.2.22 | `/Applications/OpenCode.app` | Recheck Nix candidate alongside the CLI. |
| OrbStack | 2.2.3 | `orbstack` cask; `docker context show` returned `orbstack` | Keep its app, CLI links, and Docker context together. |
| Raycast | 1.104.29 | Running; enabled background app registration | Recheck Nix candidate and login behavior. |
| Slack | 4.51.185 | Running | Recheck earlier Nix candidate. |
| Spark Desktop | 3.27.9 | `/Applications/Spark Desktop.app` | Cask or vendor install. |
| Spotify | 1.3.0.277 | Running; enabled startup helper | Recheck earlier Nix candidate and startup behavior. |
| TickTick | 8.0.10 | `/Applications/TickTick.app` | Cask or vendor install. |
| Unzip - RAR ZIP 7Z Unarchiver | 2.5.1 | Mac App Store receipt | Keep App Store or use `programs.mas`. |
| VLC | 3.0.23 | Running | Cask or vendor install unless Nix support is revalidated. |
| WebStorm | 2025.3.3 | `~/Applications`, installed by JetBrains Toolbox | Keep Toolbox managed. |
| WhatsApp | 26.28.75 | Mac App Store receipt | Keep App Store or use `programs.mas`; choose one update channel. |
| Wispr Flow | 1.4.351 | `/Applications/Wispr Flow.app` | Cask or vendor install. |
| Xcode | 26.3 | Running; Mac App Store receipt | Keep App Store or use `programs.mas`; do not put Xcode in the Nix store. |

Safari 18.6 is also present under `/Applications` as a macOS-provided app. The Claude Code URL Handler is under `~/Applications` and is part of Claude Code rather than a separate user app.

### Login and background item evidence

`sfltool dumpbtm` shows enabled app registrations for Beeper Desktop, NetBird, Raycast, and **Freedom**. Freedom's recorded URL is `/Applications/Freedom.app`, but that bundle is absent; treat this as a stale registration. Enabled helper login items include DockerHelper and Spotify's StartUpHelper. OrbStack and Docker also have background registrations. This is registration state, not proof that every item is currently running.

The direct process-path check found Beeper Desktop, ChatGPT Classic, Docker Desktop, Folx, Ghostty, Google Chrome, Obsidian, Raycast, Slack, Spotify, VLC, Xcode, and Adobe Creative Cloud components running. A process with a different executable path may not appear in this check.

## Standalone binaries and duplicate command paths

| Item | Current observation | Migration boundary |
| --- | --- | --- |
| AWS CLI | `aws` resolves to Homebrew first; `/usr/local/aws-cli/v2/current/bin/aws` is a Linux x86-64 ELF file | Do not use the invalid standalone copy. |
| Coder | Homebrew 2.35.6 resolves first; `/usr/local/bin/coder` is 2.36.3 | Check the live Coder server version before choosing one CLI. |
| CodeCrafters | `/usr/local/bin/codecrafters` is a native arm64 binary | Check the Nix candidate before replacing it. |
| Docker CLI | `/usr/local/bin/docker`, `docker-compose`, and `kubectl` point to OrbStack; Docker Desktop has separate remaining helpers | Keep the runtime and its CLI links consistent. |
| `cagent` | `/usr/local/bin/cagent` is a broken link into Docker Desktop | Remove only after deciding whether the command is still needed. |
| `kubectl` | Homebrew wins over `/usr/local/bin/kubectl` and `~/.orbstack/bin/kubectl` | Validate the chosen binary before removing duplicates. |
| NetBird CLI | Homebrew wins over `/usr/local/bin/netbird` | Preserve the working VPN helper and login. |
| Claude Code | Homebrew cask 2.1.236 wins over `~/.local/bin/claude` pointing to 2.1.198 | Validate the intended release and update path before cleanup. |
| `uv` and `uvx` | Upstream binaries under `~/.local/bin` | Nix candidates; `uv tool list` reports no global tools. |
| `update-frontend-coder` | User-owned symlink under `~/.local/bin` to dotfiles | Keep managed as a script if moving shell config to Home Manager. |
| JetBrains launchers | `datagrip` and `webstorm` come from Toolbox | Leave Toolbox managed. |

## Global package managers and shell tools

- The current shell uses NVM Node **24.21.0**, npm **11.19.0**, and a Corepack-provided pnpm **12.6.0**. Its global npm packages are Corepack 0.36.0 and npm 11.19.0; its pnpm global profile has no dependencies.
- Homebrew Node points to **26.8.2**. Its global npm prefix contains `hunkdiff` 0.16.0, npm 11.19.1, and `nx` 22.4.5. Homebrew pnpm is **10.29.2**.
- Homebrew pnpm's global profile still records `loky-ui` linked to `~/Documents/github/loky-ui`, but the expected top-level package link under its `node_modules` is absent. Treat the record as stale until the executable is checked.
- `rustup toolchain list` reports stable Apple Silicon and 1.96.0 toolchains. `cargo install --list` and `uv tool list` report no user-installed tools.
- `.zshrc` still bootstraps Zinit with syntax highlighting, completions, autosuggestions, `fzf-tab`, Oh My Zsh snippets, and fzf/zoxide/Starship integrations. Homebrew `shellenv` remains in `.zshrc` and `.zprofile`.

## Migration notes

The [September 9 inventory](application-inventory-2026-09-09.md) contains a detailed Nix package mapping and a proposed package set. Treat its package versions and Apple Silicon availability as **historical**. Later migrations checked candidates against the pinned nixpkgs release and built the packages in the current flake. The [current status](README.md) records the remaining boundaries.

New decisions since that inventory: `binaryen`, `bitwarden-cli`, `pi-coding-agent`, and `wasm-pack` are command-line migration candidates; `node@24` and `nvm` should be considered together with the existing NVM, Homebrew Node, and project runtime versions; `rust` and `rustup` overlap; OrbStack is the active Docker context while Docker Desktop remains installed. Keep Homebrew and vendor apps available until each replacement is tested.

The dotfiles shell configuration still contains credential assignments. Keep secret values out of Nix expressions and store-backed generated files; move them to protected runtime storage or command-scoped secret references before managing shell configuration declaratively.

## Refresh commands

```sh
brew list --formula --versions
brew list --cask --versions
brew services list
npm ls --global --depth=0
/opt/homebrew/bin/npm --prefix /opt/homebrew ls --global --depth=0
/opt/homebrew/bin/pnpm ls --global --depth=0
uv tool list
cargo install --list
rustup toolchain list
type -a aws coder kubectl netbird claude node npm pnpm
docker context show
sfltool dumpbtm
```
