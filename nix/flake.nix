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
        pkgs.neovim
        pkgs.tmux
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
