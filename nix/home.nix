{ config, lib, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  writableConfig = name:
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/${name}";
  ohMyZsh = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
in
{
  home.stateVersion = "26.05";
  xdg.enable = true;

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 5000;
      save = 5000;
      append = true;
      share = true;
      ignoreSpace = true;
      ignoreDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
      findNoDups = true;
    };
    profileExtra = builtins.readFile ../.zprofile;
    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)
      '')
      (lib.mkOrder 600 ''
        # Load the same useful Oh My Zsh snippets without a runtime downloader.
        source ${ohMyZsh}/lib/git.zsh
        source ${ohMyZsh}/plugins/git/git.plugin.zsh
        source ${ohMyZsh}/plugins/sudo/sudo.plugin.zsh
        source ${ohMyZsh}/plugins/aws/aws.plugin.zsh
        source ${ohMyZsh}/plugins/kubectl/kubectl.plugin.zsh
        source ${ohMyZsh}/plugins/kubectx/kubectx.plugin.zsh
        source ${ohMyZsh}/plugins/command-not-found/command-not-found.plugin.zsh
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      '')
      (builtins.readFile ../.zshrc)
    ];
  };

  home.file.".gitconfig".source = ../.gitconfig;

  xdg.configFile = {
    "bitwarden".source = ../.config/bitwarden;
    "ghostty".source = ../.config/ghostty;
    "starship".source = ../.config/starship;

    # LazyVim and TPM write lockfiles/plugin state here. Keep the repository
    # writable while Home Manager owns the links. Git ignore is also updated
    # by local tools, so it follows the same policy.
    "nvim".source = writableConfig "nvim";
    "tmux".source = writableConfig "tmux";
    "git".source = writableConfig "git";
  };
}
