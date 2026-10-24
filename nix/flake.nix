{
  description = "Tibor's MacBook Pro nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nix-darwin, nixpkgs-unstable, home-manager, ... }:
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
        unstable.codecrafters-cli
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
      system.primaryUser = "tiborsuty";
      users.users.tiborsuty.home = "/Users/tiborsuty";

      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = false;
          upgrade = false;
          cleanup = "none";
          extraEnv.HOMEBREW_NO_INSTALL_UPGRADE = "1";
        };
        taps = [
          { name = "anomalyco/tap"; trusted = true; }
          { name = "hashicorp/tap"; trusted = true; }
          { name = "netbirdio/tap"; trusted = true; }
        ];
        brews = [
          "awscli"
          { name = "awscli@1"; link = false; }
          "coder"
          "glab"
          "node"
          { name = "node@24"; link = false; }
          { name = "nvm"; link = false; }
          { name = "hashicorp/tap/terraform"; trusted = true; }
          { name = "hashicorp/tap/vault"; trusted = true; }
          "vault-cli"
          { name = "netbirdio/tap/netbird"; trusted = true; }
          "xcodegen"
          { name = "zsh"; link = false; }
        ];
        casks = [
          "claude"
          "claude-code"
          "codex"
          "ghostty"
          "orbstack"
        ];
        masApps = {
          "Unzip - RAR ZIP 7Z Unarchiver" = 1537056818;
          WhatsApp = 310633997;
          Xcode = 497799835;
        };
      };

      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."m1pro" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "before-home-manager";
          home-manager.users.tiborsuty = import ./home.nix;
        }
      ];
    };
  };
}
