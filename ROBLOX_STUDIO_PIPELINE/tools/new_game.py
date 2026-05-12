from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.roblox_env import normalize_path

SLUG_RE = re.compile(r"^[a-z0-9][a-z0-9-]{1,48}[a-z0-9]$")


def main() -> None:
    parser = argparse.ArgumentParser(description="Create a new Roblox game project from the ClawdiaOS pipeline template.")
    parser.add_argument("slug", help="kebab-case game slug, e.g. dino-dash")
    parser.add_argument("--name", required=True, help="Public game name")
    parser.add_argument("--universe-id", required=True)
    parser.add_argument("--place-id", required=True)
    parser.add_argument("--api-key-env", required=True, help="Env key name in roblox api.txt")
    parser.add_argument("--out", default=r"D:\Openclaw")
    args = parser.parse_args()

    if not SLUG_RE.match(args.slug):
        raise SystemExit("Slug must be kebab-case, 3-50 chars, letters/numbers/hyphens only.")

    root = Path(__file__).resolve().parents[1]
    src = root / "templates" / "game-template"
    dest = normalize_path(args.out) / args.slug.upper().replace("-", "_")
    if dest.exists():
        raise SystemExit(f"Destination already exists: {dest}")
    shutil.copytree(src, dest)

    project = dest / "default.project.json"
    data = json.loads(project.read_text(encoding="utf-8"))
    data["name"] = args.name
    project.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")

    registry_path = root / "experiences.json"
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    registry.setdefault("targets", {})[args.slug] = {
        "name": args.name,
        "project_dir": str(dest),
        "universe_id": str(args.universe_id),
        "place_id": str(args.place_id),
        "api_key_env": args.api_key_env,
    }
    registry_path.write_text(json.dumps(registry, indent=2) + "\n", encoding="utf-8")

    print(f"Created project: {dest}")
    print(f"Registered target: {args.slug}")
    print("Next: add the API key value to your credentials file, then run dry-run publish.")


if __name__ == "__main__":
    main()
