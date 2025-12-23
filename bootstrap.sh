#!/usr/bin/env bash
set -euo pipefail

# Detects the host platform and returns a normalized label.
detect_platform() {
  local uname_out
  uname_out="$(uname -s)"
  case "$uname_out" in
    Darwin)
      echo "macos"
      ;;
    Linux)
      if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        local distro_id="${ID:-}"
        local distro_like="${ID_LIKE:-}"
        if [[ "$distro_id" == "arch" || "$distro_like" == *"arch"* ]]; then
          echo "arch"
          return
        fi
        if [[ "$distro_id" == "ubuntu" || "$distro_id" == "debian" || "$distro_like" == *"ubuntu"* || "$distro_like" == *"debian"* ]]; then
          echo "ubuntu"
          return
        fi
      fi
      ;;
  esac
  echo "Unsupported platform: $uname_out" >&2
  exit 1
}

install_macos_deps() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required for macOS setups." >&2
    echo "Install it from https://brew.sh/ and re-run this script." >&2
    exit 1
  fi

  local required_taps=(
    astral-sh/uv
    romkatv/powerlevel10k
  )

  for tap in "${required_taps[@]}"; do
    if ! brew tap | grep -qx "$tap"; then
      echo "==> Tapping $tap"
      brew tap "$tap"
    fi
  done

  local brew_packages=(
    chruby
    ruby-install
    volta
    eza
    zoxide
    uv
    powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    stow
  )

  for package in "${brew_packages[@]}"; do
    if brew list --versions "$package" >/dev/null 2>&1; then
      echo "==> $package already installed"
    else
      echo "==> Installing $package"
      brew install "$package"
    fi
  done
}

install_arch_packages() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman is required for Arch-based setups." >&2
    exit 1
  fi

  local arch_packages=(
    chruby
    ruby-install
    stow
    eza
    zoxide
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-theme-powerlevel10k
  )

  echo "==> Installing pacman packages (requires sudo)"
  sudo pacman -S --needed "${arch_packages[@]}"
}

install_ubuntu_packages() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get is required for Ubuntu-based setups." >&2
    exit 1
  fi

  local ubuntu_packages=(
    chruby
    ruby-install
    stow
    eza
    zoxide
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-theme-powerlevel10k
    curl
  )

  echo "==> Updating apt package metadata (requires sudo)"
  sudo apt-get update
  echo "==> Installing apt packages (requires sudo)"
  sudo apt-get install -y "${ubuntu_packages[@]}"
}

install_volta_from_upstream() {
  if command -v volta >/dev/null 2>&1; then
    echo "==> Volta already installed"
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to install Volta." >&2
    exit 1
  fi

  echo "==> Installing Volta (official installer)"
  curl https://get.volta.sh | bash -s -- --skip-setup
}

install_uv_from_upstream() {
  if command -v uv >/dev/null 2>&1; then
    echo "==> uv already installed"
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to install uv." >&2
    exit 1
  fi

  echo "==> Installing uv (official installer)"
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

main() {
  local platform
  platform="$(detect_platform)"
  echo "==> Detected platform: $platform"

  case "$platform" in
    macos)
      install_macos_deps
      ;;
    arch)
      install_arch_packages
      install_volta_from_upstream
      install_uv_from_upstream
      ;;
    ubuntu)
      install_ubuntu_packages
      install_volta_from_upstream
      install_uv_from_upstream
      ;;
  esac

  mkdir -p "$HOME/.cache"

  echo
  echo "All prerequisite tools are installed."
  echo "Next: run 'stow .' (or per-directory stow commands) from the dotfiles repo to symlink configs into $HOME."
}

main "$@"
