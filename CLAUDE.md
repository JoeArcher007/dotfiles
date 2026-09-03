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
- `check-contrast.py` — verifies foot's ANSI palettes still meet WCAG AAA (see below)
- `.stowrc` — default stow flags (`--target=$HOME --verbose=2`)

To add a new package (e.g. for tmux or git config), create a new top-level directory whose internal path structure mirrors `$HOME` (e.g. `git/.gitconfig`), then add the package name to the `PACKAGES` array in `install.sh`.

## Installing / applying changes

```bash
./install.sh
```

This backs up any existing non-symlinked files at the target paths into `~/.dotfiles_backup_<timestamp>/`, then runs `stow -R shell vim` to (re)create the symlinks in `$HOME`. It also offers to repeat the process for `/root` via `sudo` when not already run as root.

Validate changes by running `./install.sh` and opening a new shell (`bash -l`) or sourcing the affected file directly (e.g. `source ~/.bashrc`). Foot's config can be syntax-checked without launching it:

```bash
foot --check-config -c foot/.config/foot/foot.ini
```

There is otherwise no build or lint step — this is plain configuration — but colour changes do have a test:

```bash
./check-contrast.py          # or --quiet to show only failures
```

It measures every ANSI slot in `foot.ini` against its background and exits non-zero if any drops below WCAG AAA (7:1), so a regression is caught rather than assumed. Run it after touching either `[colors-*]` section. If a slot is deliberately allowed to sit below AAA, add it to `EXCEPTIONS` in the script with a reason — don't lower the threshold.

## Editing conventions

- Edit files under `shell/` or `vim/` in this repo, never the symlinked copies in `$HOME` — the symlinks point back here, but editing the repo copies keeps intent clear and history accurate.
- `shell/.bashrc` is only for interactive, non-login shells; `shell/.bash_profile` sources `.bashrc` and additionally manages `PATH` for login shells. Keep `PATH` additions in `.bash_profile` (login-shell-only setup) unless the addition genuinely needs to apply to every non-login shell too, in which case it belongs at the bottom of `.bashrc` alongside the existing `PATH` exports.
- `shell/.bashrc` has a hard requirement: the Ghostty shell-integration `source` block must remain the first substantive thing in the file (after the interactive-shell guard) — Ghostty's own docs require this ordering for cursor state to sync correctly.
- The `PS1` prompt in `.bashrc` uses bold *foreground* colors on the terminal's own background (no color blocks), so it stays legible in any ambient light and in both foot themes. The `@host` segment's color is hashed from `hostname` (`cksum`) into the accessible ANSI foreground set (bold `31`–`36`, bright `91`–`96`) — stable per-host, distinct across hosts; preserve this if touching the prompt. The exit code and prompt marker are green on success / red on failure via `EXIT_COLOR`, set once per prompt in `set_prompt()`.
- Aliases live in `.bash_aliases` (the bulk, plus `ls`/`grep` color setup with a macOS/BSD fallback). New aliases go there, not in `.bashrc`.
- `foot/.config/foot/foot.ini` carries the **Modus** palettes (Protesilaos Stavrou): `[colors-light]` is Modus Operandi Tinted on cream (`fbf7f0`), `[colors-dark]` is Modus Vivendi on pure black (`000000`). Modus is built to **WCAG AAA** (≥7:1), and this config holds that: every ANSI slot rendered as text measures ≥7:1 against its background — worst case 7.02:1 in light, 7.03:1 in dark. **Preserve that if you touch the colors.** Two rules matter most:
    - Use the *tinted* Modus values for the light theme, not the plain Modus Operandi ones. Plain Operandi is tuned for a `#ffffff` background and drops to ~6.6:1 on this cream, i.e. AA not AAA. Source of truth is `modus-themes.el` (`modus-themes-operandi-tinted-palette` / `modus-themes-vivendi-palette`).
    - `regular0` in `[colors-dark]` (`1e1e1e`) is the one deliberate exception at 1.26:1. It is Modus's `bg-dim`, a background colour; "black" text on a black background cannot be legible without ceasing to be black. TUIs paint backgrounds with it, not glyphs.
- Modus ships no official 16-colour terminal mapping — Prot [declined to make one](https://protesilaos.com/codelog/2022-01-23-base16-modus-themes/), arguing 16 slots can't carry the themes' context-specific intent — so the ANSI mapping here is ours: `regular` = Modus's base colour, `bright` = its `-cooler` variant (`-warmer` for yellow). On a light background both members of a pair must clear 7:1, leaving no lightness headroom to separate them, so **the pairs are distinguished by hue, not lightness**. The four grey slots are hand-picked because 7:1 admits only `#000000`–`#545454` on cream and `#959595`–`#ffffff` on black; slot 8 is load-bearing dim-text (senpai's status colour, tmux's pane borders) and is held at 7:1 rather than allowed to fade.
- The default `foreground` is pure black (`000000`) on cream in light mode and pure white (`ffffff`) on black in dark mode, chosen for maximum contrast on a dimmed backlight; foot swaps the two on the `Ctrl+Shift+t` theme toggle, and typed input plus the bold prompt clock ride this foreground.
- Everything else inherits those 16 colors rather than hardcoding RGB — vim (`termguicolors` deliberately off), the tmux status bar (reverse video), the `PS1` prompt (bold foreground indices), senpai, and `LESS_TERMCAP`. This is why retuning one file re-themes the whole setup, and it is worth keeping: **never hardcode a hex colour outside `foot.ini`.** In particular `LESS_TERMCAP` must not encode a fg/bg colour pair — the old `103;30` (black on bright yellow) measured 1.61:1 in light mode, because an AAA palette forces bright yellow to be dark; it now uses reverse video (`\e[7m`), which is theme-agnostic.
- Man pages are coloured by `MANPAGER` (in `.bashrc`), not by `LESS_TERMCAP`. groff 1.23 emits SGR escapes directly rather than the overstrike encoding `less` needs in order to apply `LESS_TERMCAP_md`/`us`, so those never fire for `man`; `MANPAGER` rewrites groff's `ESC[1m`/`ESC[4m` into coloured equivalents instead. Don't "simplify" this to `GROFF_NO_SGR=1` — that restores overstrike but strips the OSC-8 hyperlinks groff embeds, which foot renders (`osc8-underline`). `LESS_TERMCAP_so` is still live either way: `less` uses standout for its status line and search-match highlighting regardless of input encoding.
