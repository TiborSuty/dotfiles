{
  description = "Tibor's MacBook Pro nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nix-darwin, nixpkgs-unstable, ... }:
  let
    unstable = import nixpkgs-unstable {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
    configuration = { pkgs, ... }: {
      environment.systemPackages = [
        unstable.binaryen
        unstable.bitwarden-cli
        unstable.cilium-cli
        pkgs.cocoapods
        pkgs.fd
        pkgs.fzf
        pkgs.gh
        unstable.herdr
        unstable.hunk
        pkgs.kubectl
        unstable.kubernetes-helm
        unstable.langgraph-cli
        pkgs.lazygit
        pkgs.libimobiledevice
        pkgs.neovim
        unstable.opencode
        unstable.opentofu
        pkgs.php85
        unstable.pi-coding-agent
        unstable.pnpm_10
        pkgs.poppler-utils
        pkgs.ripgrep
        unstable.rustup
        pkgs.sesh
        pkgs.starship
        pkgs.stow
        pkgs.talosctl
        unstable.television
        pkgs.tmux
        unstable.uv
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
