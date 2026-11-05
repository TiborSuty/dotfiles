{ config, lib, pkgs, ... }:

let
  ohMyZsh = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
in
{
  home.packages = [ pkgs.starship pkgs.zoxide ];
  xdg.configFile."starship".source = ../../.config/starship;

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
      (builtins.readFile ./shell-init.zsh)
    ];
  };
}
