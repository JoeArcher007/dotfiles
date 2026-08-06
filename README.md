# Joe's dotfiles

My personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a "package" whose contents mirror the layout they should have under `$HOME`. Stow symlinks the files into place rather than copying them, so edits made in this repo take effect immediately.

## Packages

- `shell/` — bash config: `.bashrc`, `.bash_profile`, `.bash_aliases`, `.inputrc`
- `vim/` — `.vimrc`
- `senpai/` — the [senpai](https://sr.ht/~taiite/senpai/) IRC client (`.config/senpai/senpai.scfg`)
- `foot/` — the [foot](https://codeberg.org/dnkl/foot) terminal (`.config/foot/foot.ini`)

## Install

Requires `stow`. Clone the repo (anywhere; `~/dotfiles` is typical) and run the installer:

```bash
git clone https://github.com/JoeArcher007/dotfiles.git
cd dotfiles
./install.sh
```

The installer backs up any existing, non-symlinked files at the target paths into `~/.dotfiles_backup_<timestamp>/`, then runs `stow -R` to (re)create the symlinks in `$HOME`. It also offers to repeat the process for `/root` via `sudo`.

Open a new login shell (`bash -l`) or source the affected file (e.g. `source ~/.bashrc`) to pick up changes.

## Adding a package

Create a new top-level directory whose internal structure mirrors `$HOME` (e.g. `git/.gitconfig`), then add its name to the `PACKAGES` array in `install.sh`.
