# Homebrew to nix-darwin inventory

Historical snapshot. See the [2026-09-26 Homebrew inventory](homebrew-inventory-2026-09-26.md) for the refreshed list.

Snapshot taken on 2026-09-09 from an Apple Silicon Mac (`aarch64-darwin`) with Homebrew installed at `/opt/homebrew`.

## Summary

- 39 explicitly requested Homebrew formulae
- 129 Homebrew formulae installed as dependencies
- 4 Homebrew casks
- 3 third-party taps
- 0 pinned formulae
- 0 active Homebrew services
- No missing Homebrew dependencies (`brew missing` succeeded)
- Nix and `darwin-rebuild` are not currently available on `PATH`

For a nix-darwin migration, start with the explicitly requested formulae and casks. Do not manually copy the 129 transitive formulae into `environment.systemPackages`; Nix should resolve those dependencies from the packages you select.

## Top-level formulae

These are the formulae reported by `brew leaves`, plus `opencode` and `vault`. Homebrew 6 omitted those two untrusted-tap formulae from `brew leaves`, but both installation receipts record `installed_on_request: true` and `installed_as_dependency: false`.

| Homebrew formula | Version | Tap |
| --- | ---: | --- |
| `awscli` | 2.36.25 | `homebrew/core` |
| `awscli@1` | 1.46.0 | `homebrew/core` |
| `cilium-cli` | 0.19.7 | `homebrew/core` |
| `cocoapods` | 1.16.2_2 | `homebrew/core` |
| `coder` | 2.35.6 | `homebrew/core` |
| `fd` | 10.4.2 | `homebrew/core` |
| `fzf` | 0.67.0 | `homebrew/core` |
| `gh` | 2.96.0 | `homebrew/core` |
| `glab` | 1.117.0 | `homebrew/core` |
| `terraform` | 1.15.8 | `hashicorp/tap` |
| `helm` | 4.2.4 | `homebrew/core` |
| `herdr` | 0.7.1 | `homebrew/core` |
| `hunk` | 0.16.0 | `homebrew/core` |
| `kubernetes-cli` | 1.36.3 | `homebrew/core` |
| `langgraph-cli` | 0.4.31 | `homebrew/core` |
| `lazygit` | 0.59.0 | `homebrew/core` |
| `libimobiledevice` | 1.4.0 | `homebrew/core` |
| `neovim` | 0.11.6 | `homebrew/core` |
| `netbird` | 0.77.1 | `netbirdio/tap` |
| `node` | 26.4.0 | `homebrew/core` |
| `opencode` | 1.17.4 | `anomalyco/tap` |
| `opentofu` | 1.12.6 | `homebrew/core` |
| `php` | 8.5.9 | `homebrew/core` |
| `pnpm` | 10.29.2 | `homebrew/core` |
| `poppler` | 26.04.0 | `homebrew/core` |
| `ripgrep` | 15.1.0 | `homebrew/core` |
| `rust` | 1.96.0 | `homebrew/core` |
| `sesh` | 2.26.2 | `homebrew/core` |
| `starship` | 1.24.2 | `homebrew/core` |
| `stow` | 2.4.1 | `homebrew/core` |
| `talosctl` | 1.13.8 | `homebrew/core` |
| `television` | 0.15.9 | `homebrew/core` |
| `tmux` | 3.6a | `homebrew/core` |
| `vault` | 1.21.1 | `hashicorp/tap` |
| `vault-cli` | 4.2.0 | `homebrew/core` |
| `xcodegen` | 2.46.0 | `homebrew/core` |
| `yazi` | 26.5.6 | `homebrew/core` |
| `zoxide` | 0.9.9 | `homebrew/core` |
| `zsh` | 5.9 | `homebrew/core` |

## Homebrew casks

| Cask | Installed version |
| --- | ---: |
| `claude` | 1.1.2321 |
| `claude-code` | 2.1.212 |
| `codex` | 0.153.4 |
| `ghostty` | 1.2.3 |

## Third-party taps

- `anomalyco/tap`
- `hashicorp/tap`
- `netbirdio/tap`

## Formulae installed as dependencies

The following 129 formulae are transitive dependencies after correcting for the two untrusted-tap omissions described above.

```text
ada-url
aom
apr
apr-util
argon2
autoconf
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
certifi
curl
dav1d
fmt
fontconfig
freetds
freetype
gd
gettext
giflib
glib
gmp
gnupg
gnutls
gpgme
gpgmepp
graphite2
harfbuzz
hdrhistogram_c
icu4c@78
jpeg-turbo
json-c
krb5
libassuan
libavif
libevent
libffi
libgcrypt
libgit2
libgpg-error
libidn2
libimobiledevice-glue
libksba
libnghttp2
libnghttp3
libngtcp2
libplist
libpng
libpq
libpsl
libsodium
libssh2
libtasn1
libtatsu
libtiff
libtool
libunistring
libusb
libusbmuxd
libuv
libvmaf
libx11
libxau
libxcb
libxdmcp
libxext
libxrender
libyaml
libzip
little-cms2
llhttp
llvm
lpeg
luajit
luv
lz4
lzo
m4
merve
mpdecimal
nbytes
ncurses
net-snmp
nettle
npth
nspr
nss
oniguruma
openjdk
openjpeg
openldap
openssl@3
p11-kit
pcre2
pinentry
pixman
pkgconf
pydantic
python@3.14
readline
ruby
s2n
simdjson
simdutf
sqlite
tidy-html5
tree-sitter@0.25
unbound
unibilium
unixodbc
utf8proc
uvwasi
webp
xorgproto
xxhash
xz
z3
zstd
```

## Global packages outside Homebrew

These are not Homebrew formulae, but they need a migration decision if the goal is a reproducible development machine.

### npm global packages

- `hunkdiff` 0.16.0
- `npm` 11.17.0
- `nx` 22.4.5

### pnpm global packages

- `loky-ui`, linked from `~/Documents/github/loky-ui`

`uv tool list` and `cargo install --list` reported no globally installed tools. The Ruby installation contains its standard/default gems; no separate gem inventory is included here.

## Existing Nix configuration

The existing `nix/flake.nix` is currently a dormant draft because neither `nix` nor `darwin-rebuild` is on `PATH`. It declares:

- `alacritty`
- `mkalias`
- `neovim`
- `tmux`

Of the Homebrew leaves, only `neovim` and `tmux` are already represented in that draft. It is pinned to the 25.05 nix-darwin/nixpkgs branches and should be refreshed before activation.

The current login shell is `/bin/zsh`; Homebrew's `zsh` resolves to `/opt/homebrew/bin/zsh` only after Homebrew modifies `PATH`. Decide whether the macOS-provided shell is sufficient before migrating the Homebrew `zsh` package.

## Items to rationalize during migration

- `awscli` and `awscli@1`: keep both only if a project still requires AWS CLI v1.
- `terraform` and `opentofu`: keep both only if both workflows are still used.
- `node`, global `npm`, and `pnpm`: decide whether to manage a system-wide runtime or use per-project dev shells.
- `rust`: consider a per-project toolchain if projects require different compiler versions.
- `php`, `cocoapods`, `xcodegen`, and `libimobiledevice`: these may be better scoped to the projects that need them.
- `claude-code` and `codex`: choose whether they remain casks, become Nix packages, or are installed by their upstream-supported mechanism.
- `opencode`: replace both the explicitly installed CLI and separately installed desktop application with native Nix packages if both interfaces are still wanted.
- Homebrew services `herdr`, `php`, and `unbound` are all stopped, so there is no running service state to reproduce.

## Security note

The current shell configuration contains hard-coded access tokens. Do not place secrets directly in a Nix expression or the Nix store. Rotate exposed credentials and move them to a secret manager or a non-store runtime file before migrating the shell configuration.

## Reproduce the inventory

```sh
brew leaves
brew list --formula --versions
brew list --cask --versions
brew tap
brew services list
brew list --pinned
brew missing
npm ls --global --depth=0
pnpm ls --global --depth=0
uv tool list
cargo install --list
```
