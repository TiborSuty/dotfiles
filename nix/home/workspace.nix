{ ... }:

{
  imports = [ ./common.nix ];

  home.username = "dev";
  home.homeDirectory = "/workspace/home";
  home.stateVersion = "26.05";

  # Preserve the existing fullstack toolchain paths for interactive Zsh and
  # non-interactive SSH commands without sourcing Bash-only configuration.
  programs.zsh.envExtra = ''
    if [[ -r "$HOME/.config/nix-workspace/fullstack.sh" ]]; then
      source "$HOME/.config/nix-workspace/fullstack.sh"
    fi
  '';

  # Bash remains available for scripts and fallback. Do not take ownership
  # of the persistent .bashrc/.bash_profile or the user's Git identity.
  targets.genericLinux.enable = true;
}
