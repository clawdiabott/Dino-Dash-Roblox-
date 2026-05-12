from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.roblox_env import load_env_file, load_registry, normalize_path, require_keys, run_checked


def main() -> None:
    parser = argparse.ArgumentParser(description="Build and publish a Roblox place through Rojo + rbxcloud.")
    parser.add_argument("target", help="Target slug from experiences.json, e.g. claw-machine")
    parser.add_argument("--registry", default="experiences.json")
    parser.add_argument("--credentials", default=r"D:\Openclaw\roblox credentials\roblox api.txt")
    parser.add_argument("--rbxcloud", default=os.getenv("RBXCLOUD_BIN", "rbxcloud"))
    parser.add_argument("--rojo", default=os.getenv("ROJO_BIN", "rojo"))
    parser.add_argument("--file", help="Existing .rbxlx/.rbxl to publish instead of building")
    parser.add_argument("--version-type", choices=("saved", "published"), default="saved")
    parser.add_argument("--yes", action="store_true", help="Skip PUBLISH confirmation")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    targets = load_registry(root / args.registry)
    if args.target not in targets:
        raise SystemExit(f"Unknown target '{args.target}'. Known: {', '.join(sorted(targets))}")
    target = targets[args.target]

    project_dir = normalize_path(target.project_dir)
    credentials_path = normalize_path(args.credentials)
    build_dir = project_dir / "build"
    build_dir.mkdir(parents=True, exist_ok=True)
    build_file = Path(args.file) if args.file else build_dir / f"{target.slug}.rbxlx"

    print(f"Target: {target.slug} / {target.name}")
    print(f"Project: {project_dir}")
    print(f"UniverseId: {target.universe_id}")
    print(f"PlaceId: {target.place_id}")
    print(f"VersionType: {args.version_type}")
    print(f"BuildFile: {build_file}")

    if not args.file:
        run_checked([args.rojo, "build", "default.project.json", "--output", str(build_file)], cwd=project_dir, dry_run=args.dry_run)

    api_key = os.environ.get(target.api_key_env, "")
    if not api_key:
        try:
            env = load_env_file(credentials_path)
            api_key = env.get(target.api_key_env, "")
        except FileNotFoundError:
            pass
    if not api_key:
        raise SystemExit(
            f"API key '{target.api_key_env}' not found.\n"
            f"Set it as an environment variable or add it to: {credentials_path}"
        )

    if not args.yes and not args.dry_run:
        answer = input("Type PUBLISH to upload this place version to Roblox: ")
        if answer != "PUBLISH":
            raise SystemExit("Cancelled.")

    run_checked(
        [
            args.rbxcloud,
            "experience",
            "publish",
            "--filename", str(build_file),
            "--place-id", target.place_id,
            "--universe-id", target.universe_id,
            "--version-type", args.version_type,
            "--api-key", api_key,
            "--pretty",
        ],
        cwd=project_dir,
        dry_run=args.dry_run,
    )


if __name__ == "__main__":
    main()
