# Dotfiles

Clone this repo to a new computer and run the prerequisite installer before linking the dotfiles:

```bash
git clone git@github.com:eowusu14/dots.git ~/dotfiles
cd ~/dotfiles
chmod +x mac-terminal-bootstrap.sh
./mac-terminal-bootstrap.sh
```

That installs Homebrew packages and taps that `.zshrc` expects.

Afterward, use GNU Stow to symlink the dotfiles into `$HOME`:

```bash
stow .
```
