{
  description = "Tibor's MacBook Pro nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nix-darwin, ... }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.cocoapods
        pkgs.fd
        pkgs.fzf
        pkgs.gh
        pkgs.kubectl
        pkgs.lazygit
        pkgs.libimobiledevice
        pkgs.neovim
        pkgs.php85
        pkgs.poppler-utils
        pkgs.ripgrep
        pkgs.sesh
        pkgs.starship
        pkgs.stow
        pkgs.talosctl
        pkgs.tmux
        pkgs.wasm-pack
        pkgs.yazi-unwrapped
        pkgs.zoxide
      ];

      nix.package = pkgs.lix;
      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."m1pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
