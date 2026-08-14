# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Joe Archer's personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow "package" whose contents mirror the layout they should have relative to `$HOME`. Stow symlinks the files into place rather than copying them.

## Repository layout

- `shell/` — stow package for shell config: `.bashrc`, `.bash_profile`, `.bash_aliases`, `.inputrc`
- `vim/` — stow package for `.vimrc`
- `senpai/` — stow package for the senpai IRC client: `.config/senpai/senpai.scfg`
- `foot/` — stow package for the foot terminal: `.config/foot/foot.ini`
- `install.sh` — the current installer (stow-based)
- `.stowrc` — default stow flags (`--target=$HOME --verbose=2`)

To add a new package (e.g. for tmux or git config), create a new top-level directory whose internal path structure mirrors `$HOME` (e.g. `git/.gitconfig`), then add the package name to the `PACKAGES` array in `install.sh`.

## Installing / applying changes

```bash
./install.sh
```

This backs up any existing non-symlinked files at the target paths into `~/.dotfiles_backup_<timestamp>/`, then runs `stow -R shell vim` to (re)create the symlinks in `$HOME`. It also offers to repeat the process for `/root` via `sudo` when not already run as root.

There is no build, lint, or test step — this is plain configuration. Validate changes by running `./install.sh` and opening a new shell (`bash -l`) or sourcing the affected file directly (e.g. `source ~/.bashrc`).

## Editing conventions

- Edit files under `shell/` or `vim/` in this repo, never the symlinked copies in `$HOME` — the symlinks point back here, but editing the repo copies keeps intent clear and history accurate.
- `shell/.bashrc` is only for interactive, non-login shells; `shell/.bash_profile` sources `.bashrc` and additionally manages `PATH` for login shells. Keep `PATH` additions in `.bash_profile` (login-shell-only setup) unless the addition genuinely needs to apply to every non-login shell too, in which case it belongs at the bottom of `.bashrc` alongside the existing `PATH` exports.
- `shell/.bashrc` has a hard requirement: the Ghostty shell-integration `source` block must remain the first substantive thing in the file (after the interactive-shell guard) — Ghostty's own docs require this ordering for cursor state to sync correctly.
- The `PS1` prompt in `.bashrc` uses bold *foreground* colors on the terminal's own background (no color blocks), so it stays legible in any ambient light and in both foot themes. The `@host` segment's color is hashed from `hostname` (`cksum`) into the accessible ANSI foreground set (bold `31`–`36`, bright `91`–`96`) — stable per-host, distinct across hosts; preserve this if touching the prompt. The exit code and prompt marker are green on success / red on failure via `EXIT_COLOR`, set once per prompt in `set_prompt()`.
- Aliases live in `.bash_aliases` (the bulk, plus `ls`/`grep` color setup with a macOS/BSD fallback). New aliases go there, not in `.bashrc`.
- `foot/.config/foot/foot.ini` has hand-tuned `[colors-light]` and `[colors-dark]` sections. The light ANSI palette is deliberately WCAG-legible (all 16 colors ≥4.5:1 on the cream background) — preserve that if you touch the colors. The default `foreground` is pure black (`000000`) on cream in light mode and pure white (`ffffff`) on black in dark mode, chosen for maximum contrast on a dimmed backlight; foot swaps the two on the `Ctrl+Shift+t` theme toggle, and typed input plus the bold prompt clock ride this foreground.
