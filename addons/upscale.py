#!/usr/bin/env python3
"""
upscale_2x.py
Doubles the resolution of a list of PNG files using nearest-neighbour upscaling.
Overwrites files in-place.

Usage:
    find asset/graphic/world/world_of_solaria_rural_village -name "*.png" | xargs python upscale_2x.py
    find asset/graphic/world/world_of_solaria_rural_village -name "*.png" -print0 | xargs -0 python upscale_2x.py

Optional flags:
    --dry-run   Print what would be processed without modifying any files
    --backup    Save a copy as <filename>.orig.png before overwriting
"""

import argparse
import sys
from pathlib import Path
from PIL import Image


def upscale(path: Path, backup: bool = False) -> tuple[int, int, int, int]:
    """Upscale a single PNG 2x with nearest-neighbour. Returns (old_w, old_h, new_w, new_h)."""
    with Image.open(path) as img:
        old_w, old_h = img.size
        new_w, new_h = old_w * 2, old_h * 2
        upscaled = img.resize((new_w, new_h), Image.NEAREST)

        if backup:
            backup_path = path.with_suffix(".orig.png")
            path.rename(backup_path)

        upscaled.save(path, format="PNG")
        return old_w, old_h, new_w, new_h


def main():
    parser = argparse.ArgumentParser(
        description="Double PNG resolution using nearest-neighbour upscaling."
    )
    parser.add_argument(
        "files",
        nargs="+",
        metavar="FILE",
        help="PNG files to upscale (typically piped in via xargs)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print files that would be processed without modifying them",
    )
    parser.add_argument(
        "--backup",
        action="store_true",
        help="Save original as <filename>.orig.png before overwriting",
    )
    args = parser.parse_args()

    files = [Path(f) for f in args.files]
    ok = 0
    skipped = 0
    errors = 0

    for path in files:
        if not path.exists():
            print(f"[SKIP]  {path}  (not found)")
            skipped += 1
            continue
        if path.suffix.lower() != ".png":
            print(f"[SKIP]  {path}  (not a .png)")
            skipped += 1
            continue

        if args.dry_run:
            print(f"[DRY]   {path}")
            ok += 1
            continue

        try:
            old_w, old_h, new_w, new_h = upscale(path, backup=args.backup)
            print(f"[OK]    {path}  ({old_w}x{old_h} -> {new_w}x{new_h})")
            ok += 1
        except Exception as e:
            print(f"[ERROR] {path}  {e}", file=sys.stderr)
            errors += 1

    print(f"\nDone: {ok} processed, {skipped} skipped, {errors} errors.")
    if errors:
        sys.exit(1)


if __name__ == "__main__":
    main()