{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    fzf
    git
    lazygit
    neovim
    ripgrep
    tmux
  ];

  xdg.enable = true;

  # LazyVim updates lazy-lock.json here; keep the Git checkout writable.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/.config/nvim";
}
