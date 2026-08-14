# Joe's dotfiles

My personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a Stow **package** whose internal structure mirrors
the layout it should have under `$HOME`. Stow **symlinks** the files into place
rather than copying them, so any edit made in this repo takes effect immediately
— the file in `$HOME` *is* the file in the repo.

## How it works

Every package directory (e.g. `shell/`) contains files laid out exactly as they
belong under your home directory. Running the installer creates symlinks so that,
for example, `~/.bashrc → dotfiles/shell/.bashrc`.

Stow behaviour is pinned in [`.stowrc`](.stowrc):

| Flag | Effect |
|------|--------|
| `--target=$HOME` | Symlinks are created under `$HOME`. |
| `--verbose=2` | Prints each link/unlink as it happens. |
| `--no-folding` | Never symlink a whole directory — always create real directories and one symlink **per file**. This keeps every file individually linked and makes re-runs safe. |

## Repository layout

| Package | Links into | Contents |
|---------|-----------|----------|
| `shell/` | `~/` | Bash config: `.bashrc` (interactive non-login shells), `.bash_profile` (login shells + `PATH`), `.bash_aliases`, `.inputrc` (readline) |
| `vim/` | `~/` | `.vimrc` |
| `senpai/` | `~/.config/senpai/` | Config for the [senpai](https://sr.ht/~taiite/senpai/) IRC client (`senpai.scfg`) |
| `foot/` | `~/.config/foot/` | Config for the [foot](https://codeberg.org/dnkl/foot) terminal (`foot.ini`), with tuned light/dark themes |

Supporting files: [`install.sh`](install.sh) (the installer), [`.stowrc`](.stowrc)
(Stow defaults), and `.gitignore` (keeps editor swap files and machine-local
notes out of the repo).

## Prerequisites

- **[GNU Stow](https://www.gnu.org/software/stow/)** — the only hard requirement.
  Fedora: `sudo dnf install stow` · Debian/Ubuntu: `sudo apt install stow` ·
  Arch: `sudo pacman -S stow` · macOS: `brew install stow`.
- The programs each package configures (`bash`, `vim`, `senpai`, `foot`) only
  matter if you actually use that package — an unused config just sits there
  harmlessly.

## Install

Clone the repo (anywhere; `~/dotfiles` is typical) and run the installer:

```bash
git clone https://github.com/JoeArcher007/dotfiles.git
cd dotfiles
./install.sh
```

The installer:

1. **Backs up** any existing, *non-symlinked* file at a target path into
   `~/.dotfiles_backup_<timestamp>/`, preserving its relative path — so your old
   configs are never lost, just moved aside.
2. Runs `stow -R` (restow) to (re)create the symlinks in `$HOME`.

Then open a new login shell (`bash -l`) or source the affected file
(e.g. `source ~/.bashrc`) to pick up the changes.

## Updating / re-applying

After editing anything in the repo, or after `git pull` on another machine,
just re-run:

```bash
./install.sh
```

It is **idempotent and safe to run repeatedly** — including from automation such
as Ansible. Files this repo already owns are detected and left untouched; only
genuine, unmanaged files at a target path are backed up. (Re-running also
converts any older whole-directory symlinks to the per-file `--no-folding`
layout.)

## Root / system-wide install

Run the installer **as root** and it will additionally stow the packages into
`/root`:

```bash
sudo ./install.sh
```

Run as a normal user, it stows only into your `$HOME` and prints the exact
`sudo` command to use if you also want the root copy.

## Adding a package

1. Create a new top-level directory whose internal structure mirrors `$HOME`
   (e.g. `git/.gitconfig`, or `tmux/.config/tmux/tmux.conf`).
2. Add its name to the `PACKAGES` array in [`install.sh`](install.sh).
3. Run `./install.sh`.

## Removing a package

Unstow (remove the symlinks for) a package with Stow directly:

```bash
cd ~/dotfiles
stow -D <package>      # e.g. stow -D vim
```

The files remain in the repo; only the symlinks in `$HOME` are removed. To stop
managing it entirely, also drop its name from the `PACKAGES` array.
