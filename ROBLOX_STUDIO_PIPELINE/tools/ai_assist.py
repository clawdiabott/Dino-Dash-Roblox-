from __future__ import annotations

"""Anthropic API backup assistant for the ClawdiaOS/Hermes pipeline.

Usage:
    py tools\ai_assist.py "Write a Luau module that tracks player eggs"
    py tools\ai_assist.py --file src/server/Main.server.lua "Explain what this does"
    py tools\ai_assist.py --stdin   # reads prompt from stdin

API key is read from the ANTHROPIC_API_KEY environment variable, or from the
credentials file at D:\Openclaw\roblox credentials\roblox api.txt as
ANTHROPIC_API_KEY=<value>.

Models (in order of preference):
    Primary:  claude-opus-4-7  (most capable)
    Fallback: claude-sonnet-4-6
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.roblox_env import load_env_file, normalize_path

CREDENTIALS_DEFAULT = r"D:\Openclaw\roblox credentials\roblox api.txt"
API_URL = "https://api.anthropic.com/v1/messages"
PRIMARY_MODEL = "claude-opus-4-7"
FALLBACK_MODEL = "claude-sonnet-4-6"
MAX_TOKENS = 4096

SYSTEM_PROMPT = (
    "You are Hermes, the ClawdiaOS Roblox game development assistant. "
    "You write strict Luau (--!strict), follow Rojo project conventions, "
    "and keep all game logic server-authoritative. "
    "Be concise and output working code when asked."
)


def load_api_key(credentials_path: str) -> str:
    key = os.environ.get("ANTHROPIC_API_KEY", "").strip()
    if key:
        return key
    try:
        creds = load_env_file(normalize_path(credentials_path))
        key = creds.get("ANTHROPIC_API_KEY", "").strip()
        if key:
            return key
    except FileNotFoundError:
        pass
    raise RuntimeError(
        "ANTHROPIC_API_KEY not found.\n"
        "Set it as an environment variable or add it to your credentials file:\n"
        f"  {credentials_path}\n"
        "as:  ANTHROPIC_API_KEY=sk-ant-..."
    )


def call_api(api_key: str, model: str, prompt: str) -> str:
    payload = json.dumps({
        "model": model,
        "max_tokens": MAX_TOKENS,
        "system": SYSTEM_PROMPT,
        "messages": [{"role": "user", "content": prompt}],
    }).encode()

    req = urllib.request.Request(
        API_URL,
        data=payload,
        headers={
            "x-api-key": api_key,
            "anthropic-version": "2023-06-01",
            "content-type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read())
            return data["content"][0]["text"]
    except urllib.error.HTTPError as exc:
        body = exc.read().decode(errors="replace")
        raise RuntimeError(f"API error {exc.code}: {body}") from exc


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Anthropic API backup assistant for the Hermes pipeline."
    )
    parser.add_argument("prompt", nargs="?", help="Prompt text (or omit with --stdin)")
    parser.add_argument("--stdin", action="store_true", help="Read prompt from stdin")
    parser.add_argument(
        "--file",
        help="Attach file contents to the prompt (e.g. a Lua script)",
    )
    parser.add_argument(
        "--model",
        default=PRIMARY_MODEL,
        choices=[PRIMARY_MODEL, FALLBACK_MODEL],
        help=f"Model to use (default: {PRIMARY_MODEL})",
    )
    parser.add_argument(
        "--credentials",
        default=CREDENTIALS_DEFAULT,
        help="Path to credentials file containing ANTHROPIC_API_KEY",
    )
    args = parser.parse_args()

    if args.stdin:
        prompt_text = sys.stdin.read().strip()
    elif args.prompt:
        prompt_text = args.prompt.strip()
    else:
        parser.error("Provide a prompt argument or use --stdin")

    if args.file:
        file_path = Path(args.file)
        if not file_path.exists():
            sys.exit(f"File not found: {file_path}")
        file_contents = file_path.read_text(encoding="utf-8", errors="replace")
        prompt_text = f"File: {file_path.name}\n```\n{file_contents}\n```\n\n{prompt_text}"

    try:
        api_key = load_api_key(args.credentials)
    except RuntimeError as exc:
        sys.exit(str(exc))

    model = args.model
    print(f"[Hermes AI] Using {model}...\n", file=sys.stderr)

    try:
        response = call_api(api_key, model, prompt_text)
    except RuntimeError as exc:
        if model == PRIMARY_MODEL:
            print(f"[Hermes AI] {PRIMARY_MODEL} failed, trying {FALLBACK_MODEL}...", file=sys.stderr)
            try:
                response = call_api(api_key, FALLBACK_MODEL, prompt_text)
            except RuntimeError as exc2:
                sys.exit(f"Both models failed.\n{exc}\n{exc2}")
        else:
            sys.exit(str(exc))

    print(response)


if __name__ == "__main__":
    main()
