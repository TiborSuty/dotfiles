# Homebrew migration inventory

## Follow-up audit: 2026-10-26

### Zsh cleanup completed after the audit

- Removed the unlinked Homebrew **Zsh 5.9** installation and its declaration
  in `flake.nix`.
- Removed **ncurses 6.6** after Homebrew identified it as unused, receipts
  confirmed no remaining dependents, and no open files were found in its keg.
- **77 formulae remain: 12 explicitly installed fallbacks and 65 dependencies.**
  All other installation receipts are unchanged. `brew missing` and
  `brew autoremove --dry-run` pass with no output.
- Nix Zsh **5.9.1** and Apple's account login shell start successfully with a
  clean environment. Both select the Nix Zsh executable on PATH, NVM Node
  **24.21.0**, and Starship **1.25.1**. Nix Zsh was also checked in a PTY.
- The system build completed with only three small configuration derivations
  and no package compilation. **Generation 12 is active and selected**, matching
  the verified build at
  `/nix/store/25nidiwff18fbb90yvgdyi788bq5cahj-darwin-system-26.05.c3e90c8`.
  Its generated Brewfile declares 12 formulae and no longer includes Zsh.
- Coder connectivity and server-version checks are deferred at the user's
  request. No further Coder probes were run after that request.

Recovery archives for both removed kegs, the previous flake, receipt hashes,
and verification results are protected under
`~/.local/state/nix-darwin/zsh-cleanup-20261026-201427/`. The removed kegs
previously occupied 35.6 MiB of allocated Cellar space; the retained compressed
archives occupy about 6.5 MiB. These are not exact APFS free-space changes.

### Package-cache cleanup completed: 2026-10-26

Free space increased from **7.24 GiB to 22.48 GiB**, a measured gain of
**15.24 GiB**. Allocated sizes of the inspected cache directories decreased by
21.86 GiB; the filesystem free-space measurement is the actual recovered space.

- Cleared npm's package download cache through `npm cache clean --force`.
  The separate npx execution cache was preserved.
- Ran `pnpm store prune` against the discovered store. It reported removing
  168,186 files and 3,570 packages; the store retains about 45 MiB of indexes
  and remaining data. Project dependencies and NVM installations were outside
  the cleanup scope.
- Cleared Homebrew's download directory and its stale download symlinks.
  Installed kegs and API metadata were preserved.
- Cleared the two pnpm v11 metadata caches and two inactive dlx entries.
  The active dlx entry was preserved: all 80 recorded files retained their
  hashes and all four associated MCP processes remained running.
- Left the in-use uv cache, Nix store and all recorded system generations,
  OpenDesign recovery copy in Trash, and migration backups intact. Coder
  checks remain deferred.

Generation 12 and every Homebrew installation receipt are unchanged.
`brew missing` passes. Private before/after measurements, protected-file
hashes, and the exact cache-removal manifest are stored under
`~/.local/state/nix-darwin/disk-cleanup-20261026-202818/`.

### Audit baseline before the cleanup

Generation **11** was active and selected. Installation receipts confirmed
**79 formulae: 13 explicitly installed fallbacks and 66 dependencies**. Every
installed formula is reachable from those 13 roots through recorded runtime
dependencies. `brew info --json=v2 --installed` omitted the installed HashiCorp
Vault formula, so its count of 78 is incomplete. `merve` is an existing Node
dependency, not another standalone migration target.

This audit used the existing `aarch64-darwin` lockfile: stable nixpkgs
`5157396cfd0b4de9f1f83166c1f25e3ef45b180d` and unstable nixpkgs
`74435dcdae840e9770652a7bf7754c2ef7b257e1`. The version-comparison phase did not
update inputs, remove packages, switch systems, or start source builds.
The subsequent Zsh cleanup is recorded above. Development-token entry remains
deferred.

### Fallback decisions

Versions below are evaluated from these pins, not the latest upstream releases.
All listed Nix packages report support for `aarch64-darwin` and are not marked
broken; that metadata does not establish runtime compatibility.

| Homebrew formula | Installed version(s) | Pinned stable Nix | Pinned unstable Nix | Decision |
| --- | --- | --- | --- | --- |
| `awscli` | 2.36.25 | `awscli2` 2.34.24 | `awscli2` 2.35.11 | Keep: both replacements are older; an authenticated workflow has not been tested. |
| `awscli@1` | 1.46.0, unlinked | `awscli` 1.44.21 | `awscli` 1.44.21 | Keep: older replacement; determine which workflow still needs v1 before removing it. |
| `coder` | 2.35.6 | 2.28.6 | 2.36.6 | Keep: server hostname fails to resolve, and the unstable package brings a Terraform source build. |
| `glab` | 1.117.0 | 1.99.0 | 1.114.0 | Keep: both replacements are older; GitLab workflow test remains pending. |
| `netbird` | CLI 0.77.1; separate daemon 0.81.3 | 0.71.4 | 0.79.0 | Keep vendor integration: login has expired; replacing the CLI does not validate the privileged daemon. |
| `node` | 26.4.0, 26.8.2; latter linked | `nodejs_26` 26.10.0 | `nodejs_26` 26.10.0 | Keep while runtime selection and consumers of the system Node are assessed. |
| `node@24` | 24.21.0, unlinked | `nodejs_24` 24.21.0 | `nodejs_24` 24.20.0 | Stable version matches, but requires a source build; preserve NVM/Corepack selection. |
| `nvm` | 0.40.7, unlinked | No `nvm` attribute | No `nvm` attribute | Keep the fallback; shell currently loads the separate installation in `~/.config/nvm`. |
| `terraform` | 1.15.8 | 1.15.3 | 1.16.3 | Keep: stable is older and unstable changes minor version; project compatibility remains untested. |
| `vault` | 1.21.1 | 1.21.4 | 2.0.3 | Keep on Homebrew: migration is deferred by choice. Stable remains a same-minor candidate if that decision changes. |
| `vault-cli` | 4.2.0 | No `vault-cli` attribute | No `vault-cli` attribute | Keep: this is Apache Jackrabbit FileVault (`vlt`), a different tool from HashiCorp Vault. |
| `xcodegen` | 2.46.0 | 2.44.1 | 2.44.1 | Keep: replacement is older; project generation/build comparison remains pending. |
| `zsh` | 5.9, unlinked at audit time | 5.9.1, already active on PATH | 5.9.2 | Removed after the audit; Nix Zsh and account-shell startup checks pass. |

The FileVault distinction is also documented by Apache's
[Vault Console Tool reference](https://jackrabbit.apache.org/filevault/usage.html).
No Jackrabbit FileVault package was found in the inspected package definitions.

### Runtime and build checks

- All 10 version checks passed: AWS v1/v2, Coder, glab, NetBird CLI, Terraform,
  HashiCorp Vault, FileVault, XcodeGen, and Nix Zsh. These checks establish local
  startup only. `brew missing` and `brew autoremove --dry-run` both returned
  successfully with no output.
- Nix Zsh resolves through `/run/current-system/sw/bin/zsh` and reports 5.9.1.
  The account login shell remains Apple's `/bin/zsh`. Targeted checks of shell
  startup files, Ghostty, dotfiles, and user LaunchAgents found no active
  reference to the Brew Zsh executable; the only exact-path match was an old
  inventory. Removing Brew Zsh does not require changing the account shell.
- Starting a login shell with a clean PATH selects NVM Node **24.21.0** and its
  pnpm shim. A shell inheriting this agent's PATH instead selects Brew Node
  **26.8.2**, while pnpm still resolves through NVM. Check `command -v node`,
  `node --version`, and `nvm current` in the actual terminal/project before
  deciding a runtime can be removed. No project runtime pins were changed.
- NetBird's management and signal connections are disconnected. Management
  reports an expired peer login. Reauthenticate through the installed NetBird
  app before repeating private-network checks; this is the documented
  [session-expiration behavior](https://docs.netbird.io/manage/settings/enforce-periodic-user-authentication).
  `coder list --output json` currently fails at DNS resolution, so server
  compatibility remains unknown. Coder documents a
  [deployment-provided CLI](https://coder.com/docs/install/cli) for matching the
  control-plane version; check that version before choosing the Nix package.
- Only **6.2 GiB** was available. Dry runs for the actual derivation outputs
  confirmed source builds for stable Vault **1.21.4**, stable Node **24.21.0**,
  and unstable Coder **2.36.6** plus Terraform **1.16.3**. Advertised download
  sizes exclude source-build workspace requirements. No builds were started.

### Next actions

1. Project-scoped Node 24 is an optional next step when its workflow can be
   exercised. Package-cache cleanup left 22.5 GiB available; run source builds
   one at a time and monitor free space.
2. Retain the version-sensitive and vendor-integrated fallbacks until their
   replacement checks pass. Coder checks, HashiCorp Vault migration, and deferred
   token entry are not part of these steps. The Zsh cleanup and system activation
   are complete. An additional recovery checkpoint is not planned.

Private machine evidence is stored in
`~/.local/state/nix-darwin/homebrew-fallback-audit-20261026/`: installation
receipts, package evaluations, startup checks, redacted connection status,
shell-selection checks, and build dry runs. The directory is mode `0700` and
its JSON files are mode `0600`.

## Cleanup completed: 2026-10-24

Completed: **2026-10-24 11:05 CEST**, Apple Silicon. nix-darwin **generation 7** remains active. Home Manager migration commit: **`95da53d`**.

## Result

| Batch | Formulae removed | Previous allocated Cellar space |
| --- | ---: | ---: |
| Duplicate packages replaced by Nix | 33 | 1.78 GiB |
| Unused dependencies confirmed by Homebrew | 63 | 2.17 GiB |
| **Total** | **96** | **3.95 GiB** |

- Installed formulae decreased from **175 to 79**: **13 declared fallback formulae** and **66 dependencies** remain.
- All retained formula receipts and all **5 casks** were verified unchanged.
- Both `brew missing` and `brew autoremove --dry-run` exit successfully with empty output.
- All **32 Nix replacement commands** and **13 retained tools** passed their version/startup checks.
- The live shell, Rust compiler/Cargo, Node **24.21.0**, and Loky Planner pnpm **10.29.2** passed checks. Development credentials remain command-scoped.

Sizes were measured with `du -sk` before deletion, across every installed version. They describe removed allocated data, not an exact change in APFS free space. Cache directories, casks, Nix generations, NVM runtimes, standalone binaries, and retained configuration files were outside the cleanup scope.

## Removed duplicate formulae

Each formula was unlinked, absent from the declared Homebrew fallback list, and had a working replacement. Homebrew dependency checks remained enabled.

| Formula | Removed version(s) | Previous allocated MiB |
| --- | --- | ---: |
| `binaryen` | 132 | 67.4 |
| `bitwarden-cli` | 2026.8.0 | 84.3 |
| `cilium-cli` | 0.19.7 | 154.9 |
| `cocoapods` | 1.16.2_2 | 72.3 |
| `fd` | 10.4.2 | 3.0 |
| `fzf` | 0.67.0 | 4.7 |
| `gh` | 2.96.0 | 37.5 |
| `helm` | 4.2.4 | 59.3 |
| `herdr` | 0.9.0 | 21.4 |
| `hunk` | 0.16.0 | 75.3 |
| `kubernetes-cli` | 1.36.3 | 60.1 |
| `langgraph-cli` | 0.4.31 | 15.5 |
| `lazygit` | 0.59.0 | 20.0 |
| `libimobiledevice` | 1.4.0 | 2.7 |
| `neovim` | 0.11.6 | 32.0 |
| `opencode` | 1.18.32 | 137.9 |
| `opentofu` | 1.12.6 | 101.6 |
| `php` | 8.5.9 | 125.1 |
| `pi-coding-agent` | 0.85.1 | 153.9 |
| `pnpm` | 10.29.2 | 18.6 |
| `poppler` | 26.04.0 | 33.3 |
| `ripgrep` | 15.2.0 | 6.5 |
| `rust` | 1.96.0 | 368.5 |
| `rustup` | 1.29.1 | 11.3 |
| `sesh` | 2.26.2 | 7.2 |
| `starship` | 1.24.2 | 8.4 |
| `stow` | 2.4.1 | 1.0 |
| `talosctl` | 1.13.8 | 104.5 |
| `television` | 0.15.9 | 8.2 |
| `tmux` | 3.6a | 1.3 |
| `wasm-pack` | 0.15.0 | 5.8 |
| `yazi` | 26.5.6 | 19.2 |
| `zoxide` | 0.9.9 | 1.0 |

**Total: 1,823.5 MiB (1.78 GiB).**

## Removed unused dependencies

The actual Homebrew dry-run list matched the earlier dependency-graph estimate exactly. Before removal, none of the retained formulae had a recorded runtime dependency on these packages, and no visible process had an open file in their keg directories. Both installed versions of `libssh2` were removed.

| Formula | Removed version(s) | Previous allocated MiB |
| --- | --- | ---: |
| `aom` | 3.14.1 | 10.4 |
| `apr` | 1.7.6 | 1.5 |
| `apr-util` | 1.6.5 | 1.0 |
| `argon2` | 20190702_1 | 0.7 |
| `autoconf` | 2.73 | 3.8 |
| `certifi` | 2026.7.22 | 0.1 |
| `curl` | 8.21.0 | 5.7 |
| `dav1d` | 1.5.4 | 1.0 |
| `freetds` | 1.5.19 | 31.5 |
| `gd` | 2.3.3_6 | 1.4 |
| `gmp` | 6.3.0 | 3.3 |
| `gnupg` | 2.5.18 | 15.7 |
| `gnutls` | 3.8.12 | 14.6 |
| `gpgme` | 2.0.1 | 2.7 |
| `gpgmepp` | 2.0.0 | 0.9 |
| `krb5` | 1.22.2 | 5.2 |
| `libassuan` | 3.0.2 | 0.6 |
| `libavif` | 1.4.2 | 1.1 |
| `libevent` | 2.1.12_1 | 2.3 |
| `libgcrypt` | 1.12.1 | 4.0 |
| `libgit2` | 1.9.4 | 5.0 |
| `libgpg-error` | 1.59 | 1.9 |
| `libidn2` | 2.3.8 | 1.1 |
| `libimobiledevice-glue` | 1.3.2 | 0.3 |
| `libksba` | 1.6.8 | 0.6 |
| `libplist` | 2.7.0 | 0.7 |
| `libpq` | 18.6 | 38.8 |
| `libpsl` | 0.23.3 | 0.3 |
| `libsodium` | 1.0.22 | 1.2 |
| `libssh2` | 1.11.1_1, 1.11.1_4 | 3.6 |
| `libtasn1` | 4.21.0 | 0.8 |
| `libtatsu` | 1.0.5 | 0.2 |
| `libtool` | 2.6.2 | 4.2 |
| `libusb` | 1.0.29 | 0.7 |
| `libusbmuxd` | 2.1.1 | 0.3 |
| `libvmaf` | 3.2.0 | 8.4 |
| `libzip` | 1.11.4_1 | 1.1 |
| `llvm` | 22.1.8 | 1,791.8 |
| `lpeg` | 1.1.0 | 0.3 |
| `luajit` | 2.1.1767980792 | 2.2 |
| `luv` | 1.51.0-2 | 0.9 |
| `m4` | 1.4.21 | 0.8 |
| `net-snmp` | 5.9.5.2 | 16.0 |
| `nettle` | 3.10.2 | 2.9 |
| `npth` | 1.8 | 0.2 |
| `nspr` | 4.38.2 | 1.4 |
| `nss` | 3.122 | 20.2 |
| `oniguruma` | 6.9.10 | 1.5 |
| `openjpeg` | 2.5.4 | 15.0 |
| `openldap` | 2.7.0 | 9.2 |
| `p11-kit` | 0.26.2 | 4.7 |
| `pinentry` | 1.3.2 | 0.5 |
| `pkgconf` | 2.5.1 | 0.6 |
| `pydantic` | 2.13.4 | 13.8 |
| `ruby` | 4.0.5 | 119.3 |
| `tidy-html5` | 5.8.0 | 3.1 |
| `tree-sitter@0.25` | 0.25.10 | 0.5 |
| `unbound` | 1.24.2 | 6.4 |
| `unibilium` | 2.1.2 | 0.4 |
| `unixodbc` | 2.3.14 | 2.2 |
| `utf8proc` | 2.11.3 | 0.5 |
| `xxhash` | 0.8.3 | 0.6 |
| `z3` | 4.16.0 | 32.5 |

**Total: 2,224.1 MiB (2.17 GiB).**

## Retained fallback formulae

These 13 packages remain explicitly declared in `flake.nix`. Their version/startup commands passed after both cleanup batches.

| Formula | Installed version(s) |
| --- | --- |
| `awscli` | 2.36.25 |
| `awscli@1` | 1.46.0 |
| `coder` | 2.35.6 |
| `glab` | 1.117.0 |
| `netbird` | 0.77.1 |
| `node` | 26.4.0, 26.8.2 |
| `node@24` | 24.21.0 |
| `nvm` | 0.40.7 |
| `terraform` | 1.15.8 |
| `vault` | 1.21.1 |
| `vault-cli` | 4.2.0 |
| `xcodegen` | 2.46.0 |
| `zsh` | 5.9 |

Retained casks: `claude`, `claude-code`, `codex`, `ghostty`, and `orbstack`.

## Retained dependencies

These 66 formulae remain required by the retained Homebrew packages.

```text
ada-url
aws-c-auth
aws-c-cal
aws-c-common
aws-c-compression
aws-c-event-stream
aws-c-http
aws-c-io
aws-c-mqtt
aws-c-s3
aws-c-sdkutils
aws-checksums
brotli
c-ares
ca-certificates
cairo
fmt
fontconfig
freetype
gettext
giflib
glib
graphite2
harfbuzz
hdrhistogram_c
icu4c@78
jpeg-turbo
json-c
libffi
libnghttp2
libnghttp3
libngtcp2
libpng
libtiff
libunistring
libuv
libx11
libxau
libxcb
libxdmcp
libxext
libxrender
libyaml
little-cms2
llhttp
lz4
lzo
merve
mpdecimal
nbytes
ncurses
openjdk
openssl@3
pcre2
pixman
python@3.14
readline
s2n
simdjson
simdutf
sqlite
uvwasi
webp
xorgproto
xz
zstd
```

## Verification and evidence

No missing Homebrew dependencies or further autoremove candidates remain. The command checks verify local startup/version reporting; they do not exercise authenticated AWS, Coder, Terraform, Vault, or VPN workflows.

Raw preflight data, exact removal lists, Homebrew logs, protected-receipt hashes, and verification results are stored under `~/.local/state/nix-darwin/homebrew-cleanup-audit-20261024/`. The original installation snapshot is [2026-09-26](homebrew-inventory-2026-09-26.md).

The cleanup records are separate from the unrelated application-configuration edits in the working tree.
