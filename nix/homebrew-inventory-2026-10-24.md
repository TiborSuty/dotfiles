# Homebrew cleanup after the nix-darwin migration

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
- The live shell, Rust compiler/Cargo, Node **24.21.0**, Loky Planner pnpm **10.29.2**, and OpenDesign pnpm **10.33.2** passed checks. Development credentials remain command-scoped.

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
