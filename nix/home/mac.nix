{ config, lib, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  writableConfig = name:
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/${name}";
in
{
  imports = [ ./common.nix ];

  home.stateVersion = "26.05";

  # Homebrew, local project paths, NVM, and command-scoped secret helpers
  # remain Mac-specific, after the shared interactive shell configuration.
  programs.zsh = {
    profileExtra = builtins.readFile ../../.zprofile;
    initContent = lib.mkOrder 1100 (builtins.readFile ../../.zshrc);
  };

  home.file.".gitconfig".source = ../../.gitconfig;
  home.file.".local/bin/update-frontend-coder".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/coder/update-frontend-coder";

  xdg.configFile = {
    "bitwarden".source = ../../.config/bitwarden;
    "ghostty".source = ../../.config/ghostty;

    # TPM writes plugin state here. Keep the repository
    # writable while Home Manager owns the links. Git ignore is also updated
    # by local tools, so it follows the same policy.
    "tmux".source = writableConfig "tmux";
    "git".source = writableConfig "git";
    "coder".source = writableConfig "coder";
    "television/cable/sesh.toml".source = ../../.config/television/cable/sesh.toml;
  };
}
