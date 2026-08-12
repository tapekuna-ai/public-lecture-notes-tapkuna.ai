"""Build the static JupyterLite site identically in CI and locally."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", default="dist")
    args = parser.parse_args()

    content_dir = ROOT / "content"
    output_dir = ROOT / args.output_dir
    content_readme = content_dir / "README.md"
    previous_readme = content_readme.read_bytes() if content_readme.exists() else None
    shutil.copy2(ROOT / "README.md", content_readme)

    command = [
        sys.executable,
        "-m",
        "jupyter",
        "lite",
        "build",
        "--contents",
        str(content_dir),
        "--output-dir",
        str(output_dir),
    ]
    print("Building JupyterLite:", " ".join(command), flush=True)
    try:
        subprocess.run(command, cwd=ROOT, check=True)
    finally:
        if previous_readme is None:
            content_readme.unlink(missing_ok=True)
        else:
            content_readme.write_bytes(previous_readme)

    expected = output_dir / "lab" / "index.html"
    if not expected.is_file():
        raise RuntimeError(f"Build completed without expected file: {expected}")

    print(f"JupyterLite build ready: {expected}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
