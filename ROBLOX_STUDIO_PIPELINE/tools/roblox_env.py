from __future__ import annotations

import json
import os
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Mapping

SECRET_MARKERS = ("KEY", "TOKEN", "SECRET", "COOKIE", "PASSWORD")


def normalize_path(path: str | Path) -> Path:
    """Translate Windows drive paths to WSL paths when running on Linux; keep as-is on Windows."""
    import platform
    raw = str(path)
    if platform.system() != "Windows" and len(raw) >= 3 and raw[1] == ":" and raw[2] in {"\\", "/"}:
        drive = raw[0].lower()
        rest = raw[3:].replace("\\", "/")
        return Path(f"/mnt/{drive}/{rest}")
    return Path(raw)


def load_env_file(path: str | Path) -> dict[str, str]:
    """Parse a simple KEY=VALUE env file without printing or logging secrets."""
    env_path = Path(path)
    if not env_path.exists():
        raise FileNotFoundError(f"Credentials file not found: {env_path}")

    result: dict[str, str] = {}
    for raw_line in env_path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key:
            result[key] = value
    return result


def redact_env(data: Mapping[str, str]) -> dict[str, str]:
    redacted: dict[str, str] = {}
    for key, value in data.items():
        upper = key.upper()
        redacted[key] = "***REDACTED***" if any(marker in upper for marker in SECRET_MARKERS) else value
    return redacted


def require_keys(data: Mapping[str, str], keys: list[str]) -> None:
    missing = [key for key in keys if not data.get(key)]
    if missing:
        raise RuntimeError(f"Missing required credential values: {', '.join(missing)}")


def run_checked(args: list[str], *, cwd: Path | None = None, dry_run: bool = False) -> None:
    safe_args = ["***REDACTED***" if i > 0 and args[i - 1] in {"--api-key"} else part for i, part in enumerate(args)]
    print("Running:", " ".join(safe_args))
    if dry_run:
        return
    completed = subprocess.run(args, cwd=cwd, check=False)
    if completed.returncode != 0:
        raise SystemExit(completed.returncode)


@dataclass(frozen=True)
class RobloxTarget:
    slug: str
    name: str
    project_dir: Path
    universe_id: str
    place_id: str
    api_key_env: str


def load_registry(path: str | Path) -> dict[str, RobloxTarget]:
    registry_path = Path(path)
    data = json.loads(registry_path.read_text(encoding="utf-8"))
    targets: dict[str, RobloxTarget] = {}
    for slug, raw in data["targets"].items():
        targets[slug] = RobloxTarget(
            slug=slug,
            name=raw["name"],
            project_dir=Path(raw["project_dir"]),
            universe_id=str(raw["universe_id"]),
            place_id=str(raw["place_id"]),
            api_key_env=raw["api_key_env"],
        )
    return targets
