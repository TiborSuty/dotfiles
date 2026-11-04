# Shared development tools

`common.nix` installs Neovim, Git, lazygit, tmux, ripgrep, fd, and fzf, and
links Neovim to the writable `~/dotfiles/.config/nvim` checkout. Keep Lua
configuration and `lazy-lock.json` there; Nix does not replace LazyVim's
plugin manager.

`mac.nix` imports the shared module and retains the Mac's Zsh, Git identity,
application configuration, and other writable dotfile links. `../home.nix`
remains its compatibility entry point for nix-darwin.

`workspace.nix` imports the same module for `dev` at `/workspace/home`. It
does not manage `.bashrc`, `.bash_profile`, project runtimes, or Git identity.
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
