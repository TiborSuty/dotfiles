# macOS application and Nix migration inventory

Historical snapshot. See the [2026-09-26 application inventory](application-inventory-2026-09-26.md) for the refreshed list.

Snapshot taken on 2026-09-09 at 20:12 CEST on `aarch64-darwin`.

This is a machine-level inventory. It covers application bundles, currently running applications, login items, Homebrew, the Mac App Store, executables installed under `/usr/local/bin` and `~/.local/bin`, global npm/pnpm tools, JetBrains Toolbox launchers, and shell-managed plugins. Project-local dependencies such as `node_modules`, CocoaPods inside projects, PHP Composer dependencies, and Swift package locks are intentionally out of scope.

## What “available in Nix” means here

`Nix candidate` means the current nixpkgs unstable package metadata includes `aarch64-darwin`. Nix is not installed on this Mac, so these candidates have not yet been built and launched locally. GUI packages can still have macOS signing, permissions, updater, or privileged-helper issues that only appear during runtime validation.

The package checks used the official [NixOS package search](https://search.nixos.org/packages?channel=unstable&type=packages) backend on 2026-09-09. Current nix-darwin supports native Nix packages, declarative Homebrew formulae/casks, and Mac App Store packages; the latter two are not native Nix packages. See the official [nix-darwin options](https://nix-darwin.github.io/nix-darwin/manual/).

## Summary

- 27 primary GUI applications found, excluding embedded helper applications and the Claude Code URL handler.
- 17 primary applications were running during the process snapshot.
- 4 login items were reported: NetBird, Beeper Desktop, Raycast, and Freedom.
- 3 applications have Mac App Store receipts: Xcode, WhatsApp, and Unzip - RAR ZIP 7Z Unarchiver.
- 13 installed GUI applications have current native Nix candidates for Apple Silicon.
- Most command-line packages have native Nix equivalents.
- A small hybrid layer is still required for vendor-only applications unless those applications are installed manually.

## GUI applications

| Application | Installed version | Usage evidence | Native Nix status | Recommended management |
| --- | ---: | --- | --- | --- |
| Adobe Lightroom | 9.5.1 | Creative Cloud components running | No native package | Vendor-managed through Creative Cloud. The `adobe-creative-cloud` cask can bootstrap Creative Cloud, but Lightroom remains vendor-managed. |
| Adobe Creative Cloud | 6.10.0.253 | Running background components and launch agents | No native package | `homebrew.casks = [ "adobe-creative-cloud" ]`, or install manually if the goal is zero Homebrew. |
| Arc | 1.160.0 | Running | No current package; `arc-browser` was removed from nixpkgs | Keep as declarative cask `arc`, or manual install. |
| Beeper Desktop | 4.2.985 | Running and a login item | `pkgs.beeper` 4.3.73 | Nix candidate. |
| ChatGPT Classic | 1.2026.184 | Running | `pkgs.chatgpt-classic` 1.2026.184 | Nix candidate. |
| Claude Desktop | 1.49585.0 | Installed | No native desktop package found | Keep cask `claude`. |
| Docker Desktop | 4.85.0 | Running; supplies Docker-related `/usr/local/bin` links | Nix has Docker CLI, not Docker Desktop | Keep cask `docker-desktop`, or replace Desktop with `pkgs.colima` plus `pkgs.docker`. |
| Firefox | 155.0.1 | Installed | `pkgs.firefox-bin` 155.0.1 | Nix candidate; use the binary package to avoid a large local browser build. |
| Folx | 5.34 | Running | No native package found | Keep cask `folx`. |
| Ghostty | 1.3.0 | Running; Homebrew receipt still says 1.2.3 | `pkgs.ghostty-bin` 1.3.1 | Nix candidate, but keep cask `ghostty` until its recent Apple Silicon signing issue is validated locally. |
| Google Chrome | 152.0.7977.83 | Running | `pkgs.google-chrome` 152.0.7977.82 | Nix candidate; requires unfree packages. Cask remains the lower-risk updater path. |
| JetBrains Toolbox | 3.7.2.87231 | Running, login agent present | `pkgs.jetbrains-toolbox` 3.7.2.87231 | Nix candidate. |
| DataGrip | 2026.2.4 | Running | `pkgs.jetbrains.datagrip` does not advertise Apple Silicon Darwin support | Continue managing through JetBrains Toolbox. |
| WebStorm | 2025.3.3 | Installed | `pkgs.jetbrains.webstorm` does not advertise Apple Silicon Darwin support | Continue managing through JetBrains Toolbox. |
| NetBird | 0.77.1 | Running and a login item; privileged launch daemon present | `pkgs.netbird-ui` 0.78.1 | Nix candidate, but validate the privileged helper and first-run permission flow before removing the vendor installation. |
| Obsidian | 1.11.7 | Running | `pkgs.obsidian` 1.13.7 | Nix candidate. |
| OpenCode Desktop | 1.2.22 | Installed | `pkgs.opencode-desktop` 1.18.29 | Nix candidate; consolidate with `pkgs.opencode` for the CLI. |
| Raycast | 1.104.28 | Running and a login item | `pkgs.raycast` 2.2.0.0 | Nix candidate; requires unfree packages. |
| Slack | 4.51.185 | Running | `pkgs.slack` 4.51.180 | Nix candidate; nixpkgs is slightly behind the installed build. |
| Spark Desktop | 3.27.9 | Installed | No native package found | Keep cask `readdle-spark`. |
| Spotify | 1.2.94.583 | Running | `pkgs.spotify` 1.2.95.453 | Nix candidate; requires unfree packages. |
| TickTick | 8.0.10 | Installed | A nixpkgs package exists, but not for `aarch64-darwin` | Keep cask `ticktick`. |
| Unzip - RAR ZIP 7Z Unarchiver | 2.5.1 | Installed from Mac App Store | No matching native application package | Manage with `programs.mas.packages`, or replace with `pkgs.unar` and `pkgs.p7zip` if a CLI is sufficient. |
| VLC | 3.0.23 | Running | Current `vlc` and `vlc-bin` metadata do not support `aarch64-darwin` | Keep cask `vlc`. |
| WhatsApp | 26.28.75 | Installed from Mac App Store | `pkgs.whatsapp-for-mac` 2.26.31.27 | Prefer the existing App Store channel, or test the Nix candidate. Do not manage both. |
| Wispr Flow | 1.4.351 | Installed | No native package found | Keep cask `wispr-flow`. |
| Xcode | 26.3 | Running; Mac App Store receipt | Xcode itself cannot be installed as a normal Nix store package | Manage with `programs.mas.packages`; optionally use `pkgs.xcodes` to select/install versions. |

### App Store IDs

These IDs were resolved from Apple’s public App Store lookup API using each installed bundle identifier.

```nix
programs.mas = {
  enable = true;
  packages = {
    "Unzip - RAR ZIP 7Z Unarchiver" = 1537056818;
    WhatsApp = 310633997;
    Xcode = 497799835;
  };
};
```

If `pkgs.whatsapp-for-mac` is chosen instead, remove WhatsApp from this set.

### Minimal cask fallback

This remains Homebrew under the hood, although nix-darwin controls it declaratively.

```nix
homebrew = {
  enable = true;
  brews = [
    "vault-cli" # Apache Jackrabbit FileVault has no matching nixpkgs package
  ];
  casks = [
    "adobe-creative-cloud"
    "arc"
    "claude"
    "docker-desktop"
    "folx"
    "ghostty" # temporary fallback until the Nix build is validated
    "readdle-spark"
    "ticktick"
    "vlc"
    "wispr-flow"
  ];
};
```

If zero Homebrew is a hard requirement, these applications must remain vendor/manual installs or be replaced with alternatives. Nix cannot make an unavailable proprietary package reproducible by itself.

## Homebrew command-line formulae and native Nix equivalents

The corrected Homebrew total is 39 explicitly requested formulae. Homebrew 6 omitted `opencode` and HashiCorp `vault` from `brew leaves` because their taps are untrusted; their installation receipts show both were explicitly requested.

| Homebrew formula | Suggested Nix package | Status or decision |
| --- | --- | --- |
| `awscli` | `pkgs.awscli2` | Available for Apple Silicon. |
| `awscli@1` | `pkgs.awscli` | Available, but do not put v1 and v2 in the same system profile because both provide `aws`; use a project shell for v1 if still required. |
| `cilium-cli` | `pkgs.cilium-cli` | Available. |
| `cocoapods` | `pkgs.cocoapods` | Available. |
| `coder` | `pkgs.coder` | Available at 2.35.6, but the separate 2.36.3 CLI was previously needed to match the server. Pin/package 2.36.3 until server compatibility is rechecked. |
| `fd` | `pkgs.fd` | Available. |
| `fzf` | `pkgs.fzf` | Available. |
| `gh` | `pkgs.gh` | Available. |
| `glab` | `pkgs.glab` | Available, but current nixpkgs is behind the installed Homebrew build. |
| `terraform` | `pkgs.terraform` | Available; requires accepting its non-free license. Consider keeping only OpenTofu. |
| `helm` | `pkgs.kubernetes-helm` | Available. `pkgs.helm` is an unrelated synthesizer. |
| `herdr` | `pkgs.herdr` | Available. |
| `hunk` | `pkgs.hunk` | Available. |
| `kubernetes-cli` | `pkgs.kubectl` | Available. |
| `langgraph-cli` | `pkgs.langgraph-cli` | Available. |
| `lazygit` | `pkgs.lazygit` | Available. |
| `libimobiledevice` | `pkgs.libimobiledevice` | Available. |
| `neovim` | `pkgs.neovim` | Available; already present in the draft flake. |
| `netbird` | `pkgs.netbird-ui` or `pkgs.netbird` | Prefer the UI package for the current desktop workflow; validate privileged-helper behavior. |
| `node` | `pkgs.nodejs_26` | Available. Project dev shells may be safer when repositories require different Node versions. |
| `opencode` | `pkgs.opencode` | Available. |
| `opentofu` | `pkgs.opentofu` | Available. |
| `php` | `pkgs.php85` | Available and matches the currently installed major/minor version. |
| `pnpm` | `pkgs.pnpm_10` | Available and preserves the current major version. |
| `poppler` | `pkgs.poppler-utils` | Available; use the utility output for commands such as `pdftotext`. |
| `ripgrep` | `pkgs.ripgrep` | Available. |
| `rust` | `pkgs.rustc` and `pkgs.cargo`, or `pkgs.rustup` | Available. Prefer project-specific toolchains if versions vary. |
| `sesh` | `pkgs.sesh` | Available. |
| `starship` | `pkgs.starship` | Available. |
| `stow` | `pkgs.stow` | Available, though Home Manager can replace much of its dotfile role. |
| `talosctl` | `pkgs.talosctl` | Available. |
| `television` | `pkgs.television` | Available. |
| `tmux` | `pkgs.tmux` | Available; already present in the draft flake. |
| `vault` | `pkgs.vault-bin` | HashiCorp Vault is available, but current nixpkgs is a newer major version; verify compatibility before upgrading. |
| `vault-cli` | No matching nixpkgs package | This is Apache Jackrabbit FileVault, not HashiCorp Vault. Keep the formula or create a custom Java derivation if it is actually used. |
| `xcodegen` | `pkgs.xcodegen` | Available, but nixpkgs is behind the installed Homebrew version. |
| `yazi` | `pkgs.yazi-unwrapped` | Use the unwrapped package; the top-level `pkgs.yazi` metadata does not currently support Apple Silicon Darwin. |
| `zoxide` | `pkgs.zoxide` | Available. |
| `zsh` | macOS `/bin/zsh`, or `pkgs.zsh` | The current login shell is already `/bin/zsh`; omit the Nix package unless newer Zsh behavior is required. |

## Additional machine-level command-line installs

| Item | Current state | Migration |
| --- | --- | --- |
| Standalone AWS CLI in `/usr/local/aws-cli` | Broken Linux x86-64 ELF binary on this Apple Silicon Mac; Homebrew’s AWS CLI currently wins on `PATH` | Do not migrate this copy. After Nix AWS CLI is validated, remove the invalid standalone installation separately. |
| Standalone Coder in `/usr/local/bin/coder` | Version 2.36.3; Homebrew 2.35.6 currently wins on `PATH` | Preserve or package 2.36.3 until the live server version is rechecked. |
| Codecrafters in `/usr/local/bin/codecrafters` | Native arm64 binary | Replace with `pkgs.codecrafters-cli`. |
| Docker CLI links in `/usr/local/bin` | Supplied by Docker Desktop | Keep with Docker Desktop or replace with `pkgs.docker` plus `pkgs.colima`. |
| `cagent` link in `/usr/local/bin` | Broken link to a file no longer present in Docker Desktop | Remove later if unused, or replace with `pkgs.cagent`. |
| Docker-provided `kubectl` | Duplicate; Homebrew `kubectl` currently wins | Replace both with `pkgs.kubectl`. |
| NetBird-provided CLI | Duplicate; Homebrew `netbird` currently wins | Consolidate around `pkgs.netbird-ui` or `pkgs.netbird`. |
| Claude Code in `~/.local/share/claude` | Versions 2.1.196–2.1.198 retained; Homebrew cask 2.1.212 wins | Replace with `pkgs.claude-code` and remove old copies only after validation. |
| `uv` and `uvx` in `~/.local/bin` | Upstream installation | Replace with `pkgs.uv`. |
| `update-frontend-coder` in `~/.local/bin` | User-owned script | Manage through Home Manager, for example with `home.file` or `home.packages = [ (pkgs.writeShellApplication ...) ]`. |
| JetBrains `datagrip` and `webstorm` launchers | Generated by Toolbox | Leave Toolbox-managed. |

## Global JavaScript packages

- npm: `hunkdiff` 0.16.0, `npm` 11.17.0, and `nx` 22.4.5.
- pnpm: `loky-ui`, linked to `~/Documents/github/loky-ui`.

`npm` comes with the Node package. `nx`, `hunkdiff`, and the linked local package should preferably move to project-level `package.json`/pnpm configuration rather than become immutable system packages. Current nixpkgs does not expose direct `nx` or `hunkdiff` attributes.

## Shell-managed software

The current `.zshrc` bootstraps Zinit and loads:

- `zsh-users/zsh-syntax-highlighting`
- `zsh-users/zsh-completions`
- `zsh-users/zsh-autosuggestions`
- `Aloxaf/fzf-tab`
- Oh My Zsh library/plugin snippets for Git, sudo, Arch, AWS, kubectl, kubectx, and command-not-found
- shell integrations for fzf, zoxide, and Starship

These can be migrated to Home Manager. Doing so avoids network cloning during shell startup and lets Nix own plugin versions. The Homebrew `shellenv` blocks in `.zshrc` and `.zprofile` must remain until the final cask/formula migration is complete.

## Proposed native package set

This is a migration candidate, not yet an applied or locally built configuration. It intentionally excludes the fallback casks, App Store applications, AWS CLI v1, the Homebrew `vault-cli`, macOS-provided Zsh, Ghostty pending a runtime test, and Coder pending an exact server-compatible version pin.

```nix
nixpkgs.config.allowUnfree = true;

environment.systemPackages = with pkgs; [
  # GUI applications
  beeper
  chatgpt-classic
  firefox-bin
  google-chrome
  jetbrains-toolbox
  netbird-ui
  obsidian
  opencode-desktop
  raycast
  slack
  spotify
  whatsapp-for-mac

  # Development and operations CLI
  awscli2
  cilium-cli
  claude-code
  codecrafters-cli
  cocoapods
  codex
  docker
  fd
  fzf
  gh
  glab
  herdr
  hunk
  kubectl
  kubernetes-helm
  langgraph-cli
  lazygit
  libimobiledevice
  neovim
  nodejs_26
  opencode
  opentofu
  php85
  pnpm_10
  poppler-utils
  ripgrep
  rustc
  cargo
  sesh
  starship
  stow
  talosctl
  television
  terraform
  tmux
  uv
  vault-bin
  xcodegen
  yazi-unwrapped
  zoxide
];
```

Before using this set, decide whether Docker Desktop stays or is replaced by Colima, and pin the Coder version required by the server. Also expect collisions if old Homebrew binaries remain earlier on `PATH`.

## Stale or unresolved traces

- Freedom is configured as a login item and has data under `~/Library/Application Support`, but no application bundle or running process was found. Treat it as stale until confirmed otherwise.
- Application-support data remains for Brave, Microsoft Edge, Opera, Vivaldi, and Cypress, but no corresponding installed application bundle was found. These are not included in the migration set.
- The current dotfiles shell configuration contains hard-coded credentials. Do not interpolate secrets into Nix expressions or store-backed files; rotate valid credentials and load them from non-store runtime secret files.

## Recommended migration boundary

1. Refresh the dormant 25.05 flake to a supported nixpkgs/nix-darwin branch and install Nix.
2. Add and build command-line packages first while Homebrew remains available as fallback.
3. Resolve version-sensitive tools: Coder, Vault, glab, and XcodeGen.
4. Move supported GUI packages one at a time and launch-test signing, permissions, URL handlers, and auto-update behavior.
5. Move Xcode and the archive utility to `programs.mas.packages`.
6. Keep only the minimal cask list for unsupported proprietary applications.
7. Remove duplicate `/usr/local/bin`, `~/.local`, and Homebrew copies only after `type -a <command>` shows the intended Nix path and real workflows pass.
