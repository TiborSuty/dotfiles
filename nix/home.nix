# Compatibility entry point for existing nix-darwin imports.
{ ... }:
{
  imports = [ ./home/mac.nix ];
}
