#!/usr/bin/env python3
"""Verify foot's ANSI palettes meet WCAG AAA (>=7:1) contrast.

The palettes in foot/.config/foot/foot.ini are the Modus themes, which are
built to WCAG AAA. Every other package in this repo inherits those 16 colours
rather than hardcoding RGB (vim runs with termguicolors off, tmux uses reverse
video, PS1 uses bold foreground indices), so this one file governs the
legibility of the whole setup -- and this script is how that claim stays
checkable instead of merely asserted.

Usage:
    ./check-contrast.py                 # check the palettes in this repo
    ./check-contrast.py path/to/foot.ini
    ./check-contrast.py --quiet         # only report failures

Exits non-zero if any slot regresses below AAA, so it can gate a commit.
"""

import re
import sys

AAA = 7.0
AA = 4.5

# Slots allowed to sit below AAA, with the reason. These are Modus *background*
# colours occupying the ANSI "black" slot: TUIs paint backgrounds with them
# rather than drawing glyphs, and black-on-black cannot be made legible without
# ceasing to be black. Every slot that is actually rendered as text must pass.
EXCEPTIONS = {
    ("colors-dark", "regular0"): "Modus bg-dim; background slot, never text",
}


def luminance(hexcolour):
    """WCAG 2.x relative luminance."""
    h = hexcolour.strip().lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))

    def linear(c):
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    r, g, b = linear(r), linear(g), linear(b)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(fg, bg):
    """WCAG 2.x contrast ratio between two colours, 1.0 to 21.0."""
    a, b = luminance(fg), luminance(bg)
    hi, lo = max(a, b), min(a, b)
    return (hi + 0.05) / (lo + 0.05)


def grade(ratio):
    if ratio >= AAA:
        return "AAA"
    if ratio >= AA:
        return "AA"
    if ratio >= 3.0:
        return "AA-large"
    return "FAIL"


def parse_section(text, name):
    """Pull one [section] out of a foot.ini as an ordered key -> value dict."""
    match = re.search(r"^\[" + re.escape(name) + r"\]\n(.*?)(?=^\[|\Z)",
                      text, re.S | re.M)
    if not match:
        return {}
    values = {}
    for line in match.group(1).splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.split("#")[0].strip()
    return values


def check_section(text, name, quiet):
    """Check every colour in one [colors-*] section. Returns a failure list."""
    palette = parse_section(text, name)
    if not palette:
        print(f"  !! no [{name}] section found")
        return [(name, "<section>", "missing")]

    background = palette.get("background")
    if not background:
        print(f"  !! [{name}] has no background")
        return [(name, "background", "missing")]

    slots = ["foreground"]
    slots += [f"{prefix}{i}" for prefix in ("regular", "bright") for i in range(8)]

    failures = []
    if not quiet:
        print(f"\n[{name}]  background #{background}")

    for slot in slots:
        if slot not in palette:
            continue
        ratio = contrast(palette[slot], background)
        excused = EXCEPTIONS.get((name, slot))
        passed = ratio >= AAA or excused is not None

        if not passed:
            failures.append((name, slot, f"{ratio:.2f}:1"))

        if quiet and passed:
            continue

        note = ""
        if excused and ratio < AAA:
            note = f"   (allowed: {excused})"
        elif ratio < AAA:
            note = "   <-- BELOW AAA"
        print(f"  {slot:<12} #{palette[slot]}  {ratio:6.2f}:1  "
              f"{grade(ratio):<8}{note}")

    # Selected text has to stay readable on the selection block too.
    sel_bg = palette.get("selection-background")
    sel_fg = palette.get("selection-foreground")
    if sel_bg and sel_fg:
        ratio = contrast(sel_fg, sel_bg)
        if ratio < AAA:
            failures.append((name, "selection", f"{ratio:.2f}:1"))
        if not quiet or ratio < AAA:
            note = "   <-- BELOW AAA" if ratio < AAA else ""
            print(f"  {'selection':<12} #{sel_fg} on #{sel_bg}  {ratio:6.2f}:1  "
                  f"{grade(ratio):<8}{note}")

    return failures


def main():
    args = [a for a in sys.argv[1:] if a not in ("--quiet", "-q")]
    quiet = len(args) != len(sys.argv[1:])
    path = args[0] if args else "foot/.config/foot/foot.ini"

    try:
        text = open(path).read()
    except OSError as exc:
        print(f"cannot read {path}: {exc}", file=sys.stderr)
        return 2

    print(f"Checking {path} against WCAG AAA (>={AAA}:1)")

    failures = []
    for name in ("colors-light", "colors-dark"):
        failures += check_section(text, name, quiet)

    print()
    if failures:
        print(f"FAIL: {len(failures)} slot(s) below AAA")
        for name, slot, ratio in failures:
            print(f"  [{name}] {slot} at {ratio}")
        print("\nIf a change here is deliberate, add it to EXCEPTIONS with a "
              "reason\nrather than lowering the threshold.")
        return 1

    print("PASS: every colour rendered as text meets WCAG AAA.")
    for (name, slot), reason in EXCEPTIONS.items():
        print(f"  (excepted: [{name}] {slot} -- {reason})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
