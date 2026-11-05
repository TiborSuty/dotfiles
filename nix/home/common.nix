{ config, pkgs, ... }:

{
  imports = [ ./shell.nix ];

  home.packages = with pkgs; [
    fd
    fzf
    git
    lazygit
    neovim
    (callPackage ../packages/nx { })
    ripgrep
    tmux
    tree-sitter
  ];

  xdg.enable = true;

  # LazyVim updates lazy-lock.json here; keep the Git checkout writable.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/nvim";
}
