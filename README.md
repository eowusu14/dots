# Dotfiles

Clone this repo to a new computer and run the prerequisite installer before linking the dotfiles:

```bash
git clone git@github.com:eowusu14/dots.git ~/dotfiles
cd ~/dotfiles
chmod +x bootstrap.sh
./bootstrap.sh
```

The bootstrap script auto-detects the host platform:

- On macOS it ensures the required Homebrew taps and packages exist.
- On Arch-based Linux it installs the same tools with `pacman` plus the upstream installers for Volta and `uv`. Keep `sudo` available so `pacman` can elevate as needed.
- Other platforms are currently unsupported, but the script is small if you need to add another package manager.

Afterward, use GNU Stow to symlink the dotfiles into `$HOME`:

```bash
stow .
```
