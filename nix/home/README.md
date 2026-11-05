# Shared development tools

`common.nix` installs Neovim, Git, lazygit, tmux, ripgrep, fd, fzf, and the
Tree-sitter CLI, and
links Neovim to the writable `~/dotfiles/.config/nvim` checkout. Keep Lua
configuration and `lazy-lock.json` there; Nix does not replace LazyVim's
plugin manager.

Nx 23.2.1 is installed globally through `../packages/nx`, using a pinned
release tarball and npm runtime lockfile on both platforms. Its global CLI
defers to a repository's local Nx installation. Project dependencies and
lockfiles remain managed by the project. Linux native bindings are patched
for the Nix library paths; installation does not run networked npm scripts.

Tree-sitter is installed through Nix because Mason's Linux binary expects a
system dynamic loader that the minimal workspace image does not provide.

`shell.nix` provides Zsh, autosuggestions, syntax highlighting, history,
Oh My Zsh snippets, fzf-tab, fzf, zoxide, and the shared Starship theme.
Portable initialization lives in `shell-init.zsh`. The Mac's root `.zshrc`
retains Homebrew/local paths, NVM, and command-scoped secret helpers.

`mac.nix` imports the shared module and retains the Mac's Git identity,
application configuration, and other writable dotfile links. `../home.nix`
remains its compatibility entry point for nix-darwin.

`workspace.nix` imports the same module for `dev` at `/workspace/home`. It
manages Zsh and reads the existing `.config/nix-workspace/fullstack.sh` for
project toolchain paths. It does not manage `.bashrc`, `.bash_profile`, project
runtimes, or Git identity. The workspace image sets Zsh as the SSH login shell;
Bash remains available for scripts and `bash -l` fallback.
The homelab workspace image imports this module from a revision pinned in
its own flake lock, builds its Home Manager activation package, and bundles
an offline Git checkout for new persistent homes.

## Applying changes

On the Mac, build and switch `.#m1pro` from `~/dotfiles/nix` using the
commands in the parent README. New Nix files must be added to Git before a
Git-backed flake can see them.

For workspaces, publish the dotfiles changes, then run from the homelab repo:

```sh
nix flake update --flake ./infrastructure/nix-workspaces/image dotfiles
```

Build and smoke-test the image, publish it, and update the workspace image
digest through GitOps. Existing workspace checkouts are never reset or
automatically pulled. Review local changes with `git -C ~/dotfiles status`
before synchronizing their configuration through Git. New homes start at
the image's locked revision. The startup script applies the image's Home
Manager generation without fetching packages or Git objects.

Neovim plugin installation still needs network access on first use. Use
`:Lazy restore` to restore the checked-in plugin lockfile. Project language
servers and runtimes remain separate from these shared editor tools.

Both consumers use the same package declarations, but retain their existing
Nixpkgs pins. Package versions can differ between macOS and Linux.

The workspace imports `workspace-vaultwarden.nix`. It provides a `bw` wrapper
with the internal Vaultwarden HTTPS endpoint's CA and a dedicated persistent
`~/.local/share/bitwarden-workspace` state directory. Activation configures a
fresh state directory and refuses to replace an existing different server.
`with_dev_secrets` is available as an executable in every shell, using the
Mac helper's command-scoped GitHub/GitLab lookup and lock-after-command
behavior from `vaultwarden.zsh`. Phrase remains disabled. The image flake
supplies the same separately pinned Bitwarden package set as the Mac.
Credentials and unlocked sessions are never included in Nix source or images;
run `bw login` interactively after deployment.
