# Homebrew to nix-darwin inventory

Snapshot: **2026-09-26 17:53 CEST**, Apple Silicon (aarch64-darwin), Homebrew 7.0.6 at `/opt/homebrew`.

## Summary

- **175 formulae:** 46 explicitly requested according to their local installation receipts; 129 dependencies.
- **5 casks**, **3 third-party taps**, **0 pinned formulae**.
- No active Homebrew services; `brew missing` completed without missing dependencies.
- At snapshot time, Nix and `darwin-rebuild` were absent. Both became available in fresh login shells after the first nix-darwin activation later on 2026-09-26; the Homebrew package counts below are unchanged.
- The requested-package count is based on local `INSTALL_RECEIPT.json` files. `brew leaves` returned 43 entries and omitted `node`, `ripgrep`, and `vault`; `brew info --json=v2 --installed` omitted `vault` entirely.

For migration, declare packages you use directly. Nix will resolve dependencies; do not copy the 129 transitive formulae into `environment.systemPackages`.

## Explicitly requested formulae

| Formula | Installed version(s) | Tap |
| --- | --- | --- |
| `awscli` | 2.36.25 | `homebrew/core` |
| `awscli@1` | 1.46.0 | `homebrew/core` |
| `binaryen` | 132 | `homebrew/core` |
| `bitwarden-cli` | 2026.8.0 | `homebrew/core` |
| `cilium-cli` | 0.19.7 | `homebrew/core` |
| `cocoapods` | 1.16.2_2 | `homebrew/core` |
| `coder` | 2.35.6 | `homebrew/core` |
| `fd` | 10.4.2 | `homebrew/core` |
| `fzf` | 0.67.0 | `homebrew/core` |
| `gh` | 2.96.0 | `homebrew/core` |
| `glab` | 1.117.0 | `homebrew/core` |
| `helm` | 4.2.4 | `homebrew/core` |
| `herdr` | 0.9.0 | `homebrew/core` |
| `hunk` | 0.16.0 | `homebrew/core` |
| `kubernetes-cli` | 1.36.3 | `homebrew/core` |
| `langgraph-cli` | 0.4.31 | `homebrew/core` |
| `lazygit` | 0.59.0 | `homebrew/core` |
| `libimobiledevice` | 1.4.0 | `homebrew/core` |
| `neovim` | 0.11.6 | `homebrew/core` |
| `netbird` | 0.77.1 | `netbirdio/tap` |
| `node` | 26.4.0, 26.8.2 | `homebrew/core` |
| `node@24` | 24.21.0 | `homebrew/core` |
| `nvm` | 0.40.7 | `homebrew/core` |
| `opencode` | 1.18.32 | `anomalyco/tap` |
| `opentofu` | 1.12.6 | `homebrew/core` |
| `php` | 8.5.9 | `homebrew/core` |
| `pi-coding-agent` | 0.85.1 | `homebrew/core` |
| `pnpm` | 10.29.2 | `homebrew/core` |
| `poppler` | 26.04.0 | `homebrew/core` |
| `ripgrep` | 15.2.0 | `homebrew/core` |
| `rust` | 1.96.0 | `homebrew/core` |
| `rustup` | 1.29.1 | `homebrew/core` |
| `sesh` | 2.26.2 | `homebrew/core` |
| `starship` | 1.24.2 | `homebrew/core` |
| `stow` | 2.4.1 | `homebrew/core` |
| `talosctl` | 1.13.8 | `homebrew/core` |
| `television` | 0.15.9 | `homebrew/core` |
| `terraform` | 1.15.8 | `hashicorp/tap` |
| `tmux` | 3.6a | `homebrew/core` |
| `vault` | 1.21.1 | `hashicorp/tap` |
| `vault-cli` | 4.2.0 | `homebrew/core` |
| `wasm-pack` | 0.15.0 | `homebrew/core` |
| `xcodegen` | 2.46.0 | `homebrew/core` |
| `yazi` | 26.5.6 | `homebrew/core` |
| `zoxide` | 0.9.9 | `homebrew/core` |
| `zsh` | 5.9 | `homebrew/core` |

The `node` formula has both 26.4.0 and 26.8.2 in its Cellar; `/opt/homebrew/bin/node` points to 26.8.2. The current interactive shell resolves Node from NVM 24.21.0 first.

## Casks

| Cask | Receipt version |
| --- | --- |
| `claude` | `1.1.2321,495628f91fbfa276fabd6da835ba226fdf5ec68e` |
| `claude-code` | `2.1.236` |
| `codex` | `0.157.1` |
| `ghostty` | `1.2.3` |
| `orbstack` | `2.2.3,20963` |

## Third-party taps

- `anomalyco/tap`
- `hashicorp/tap`
- `netbirdio/tap`

## Transitive formulae

These 129 installed formulae are not marked as explicitly requested in their local receipts.

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

## Services and other package managers

- `php`: none
- `unbound`: none
- Active NVM Node: 24.21.0. NVM and Homebrew Node installations coexist.
- Global npm and pnpm packages, standalone binaries, GUI apps, and shell plugins are documented in [the companion application inventory](application-inventory-2026-09-26.md).

## Reproduce the Homebrew snapshot

```sh
brew list --formula --versions
brew list --cask --versions
brew leaves
brew tap
brew services list
brew list --pinned
brew missing
```

For requested/dependency status, inspect each `/opt/homebrew/Cellar/<formula>/<version>/INSTALL_RECEIPT.json`. Homebrew list commands alone undercounted requested packages on this machine.
