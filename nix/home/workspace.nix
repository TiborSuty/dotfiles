{ ... }:

{
  imports = [ ./common.nix ];

  home.username = "dev";
  home.homeDirectory = "/workspace/home";
  home.stateVersion = "26.05";

  # The container supplies Bash and project toolchains. Do not take ownership
  # of the persistent .bashrc/.bash_profile or the user's Git identity.
  targets.genericLinux.enable = true;
}
