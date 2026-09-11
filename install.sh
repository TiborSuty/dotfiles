#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
stow_dir="$repo_dir/.stow-packages"
package_name="coder"
package_dir="$stow_dir/$package_name"
target_dir="${DOTFILES_STOW_TARGET:-$HOME}"

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU Stow is required. The Coder template should install it before this script runs." >&2
  exit 1
fi

# Only these portable files are exposed to Coder. In particular, this excludes
# macOS application configuration, GitHub CLI state, shell history, and the
# current macOS-specific .zshrc.
managed_paths=(
  ".config/bitwarden/vaultwarden-ca.crt"
  ".config/git/ignore"
  ".config/nvim"
  ".config/starship/starship.toml"
  ".config/tmux"
)

# Remove links previously managed by this generated package before rebuilding
# the package, so removing an entry from managed_paths also removes its link.
if [[ -d "$package_dir" ]]; then
  stow \
    --dir="$stow_dir" \
    --target="$target_dir" \
    --delete \
    --no-folding \
    "$package_name"
fi

rm -rf -- "$package_dir"
mkdir -p -- "$package_dir"

for relative_path in "${managed_paths[@]}"; do
  source_path="$repo_dir/$relative_path"
  package_path="$package_dir/$relative_path"

  if [[ ! -e "$source_path" && ! -L "$source_path" ]]; then
    echo "Managed dotfile does not exist: $relative_path" >&2
    exit 1
  fi

  mkdir -p -- "$(dirname -- "$package_path")"
  relative_source="$(
    perl -MFile::Spec -e 'print File::Spec->abs2rel($ARGV[0], $ARGV[1])' \
      "$source_path" "$(dirname -- "$package_path")"
  )"
  ln -s -- "$relative_source" "$package_path"
done

stow \
  --dir="$stow_dir" \
  --target="$target_dir" \
  --stow \
  --no-folding \
  "$package_name"
