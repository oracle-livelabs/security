#!/usr/bin/env python3
"""Validate a lesson content pack without starting Flask or connecting to Oracle."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys

from content_loader import ContentValidationError, load_lesson


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    default_manifest = script_dir / "content" / "deep_data_security" / "lab.yaml"
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "manifest",
        nargs="?",
        type=Path,
        default=default_manifest,
        help=f"manifest to validate (default: {default_manifest})",
    )
    args = parser.parse_args()

    try:
        lesson = load_lesson(args.manifest)
    except ContentValidationError as exc:
        print("Content validation failed:", file=sys.stderr)
        for error in exc.errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    script_count = sum(len(action.scripts) for action in lesson.actions.values())
    print(f"Content validation passed: {lesson.id}")
    print(f"  manifest: {lesson.source_path}")
    print(f"  pages: {len(lesson.pages)}")
    print(f"  steps: {len(lesson.steps)}")
    print(f"  actions: {len(lesson.actions)}")
    print(f"  scripts: {script_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
