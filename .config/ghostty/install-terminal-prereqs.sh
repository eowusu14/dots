#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required for this setup script." >&2
  exit 1
fi

required_taps=(
  astral-sh/uv
  romkatv/powerlevel10k
)

for tap in "${required_taps[@]}"; do
  if ! brew tap | grep -qx "$tap"; then
    echo "==> Tapping $tap"
    brew tap "$tap"
  fi
done

brew_packages=(
  chruby
  ruby-install
  volta
  nvm
  eza
  zoxide
  uv
  powerlevel10k
  zsh-autosuggestions
  zsh-syntax-highlighting
)

for package in "${brew_packages[@]}"; do
  if brew list --versions "$package" >/dev/null 2>&1; then
    echo "==> $package already installed"
  else
    echo "==> Installing $package"
    brew install "$package"
  fi
done

mkdir -p "$HOME/.nvm"
mkdir -p "$HOME/.cache"

echo
echo "All prerequisite tools are installed."
echo "Verify ~/.zshrc references the installed paths under /opt/homebrew/share as in your dotfiles."
