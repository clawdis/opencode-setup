#!/usr/bin/env python3

from __future__ import annotations

import subprocess
import sys
from collections import OrderedDict
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class StatusEntry:
    status: str
    path: str


def run_git_command(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    return result.stdout


def require_repo_root() -> None:
    repo_root = run_git_command("rev-parse", "--show-toplevel").strip()
    current_dir = str(Path.cwd().resolve())
    if Path(repo_root).resolve() != Path(current_dir):
        raise SystemExit(
            "Run this helper from the repository root. "
            f"Expected: {repo_root} | Current: {current_dir}"
        )


def normalize_status(raw_status: str) -> str:
    if raw_status == "??":
        return raw_status
    stripped = raw_status.strip()
    return stripped or raw_status


def normalize_diff_path(raw_path: str) -> str:
    if " -> " in raw_path:
        return raw_path.split(" -> ", 1)[1]
    if " => " not in raw_path:
        return raw_path
    prefix, suffix = raw_path.split(" => ", 1)
    if "{" in prefix and "}" in suffix:
        before_brace, old_part = prefix.split("{", 1)
        new_part, after_brace = suffix.split("}", 1)
        return f"{before_brace}{new_part}{after_brace}"
    return suffix


def parse_status() -> "OrderedDict[str, StatusEntry]":
    entries: "OrderedDict[str, StatusEntry]" = OrderedDict()
    output = run_git_command("status", "--porcelain=v1", "--untracked-files=all")
    for line in output.splitlines():
        if not line:
            continue
        raw_status = line[:2]
        raw_path = line[3:]
        path = normalize_diff_path(raw_path)
        entries[path] = StatusEntry(status=normalize_status(raw_status), path=path)
    return entries


def parse_numstat() -> dict[str, tuple[str, str]]:
    entries: dict[str, tuple[str, str]] = {}
    output = run_git_command("diff", "--numstat", "HEAD")
    for line in output.splitlines():
        if not line:
            continue
        added, deleted, raw_path = line.split("\t", 2)
        entries[normalize_diff_path(raw_path)] = (added, deleted)
    return entries


def categorize_path(path: str) -> str:
    if path.startswith(".opencode/agent/"):
        return "agent"
    if path.startswith(".opencode/commands/"):
        return "command/template"
    if path.startswith(".opencode/skills/"):
        return "skill"
    if path.startswith("docs/"):
        return "docs"
    if path.endswith(".csproj"):
        return "project"
    if path.endswith(".cs"):
        return "code"
    return "other"


def iter_manifest_rows() -> list[tuple[str, str, str, str, str]]:
    status_entries = parse_status()
    numstat_entries = parse_numstat()

    for path in numstat_entries:
        if path not in status_entries:
            status_entries[path] = StatusEntry(status="M", path=path)

    rows: list[tuple[str, str, str, str, str]] = []
    for path, status_entry in status_entries.items():
        if status_entry.status == "??":
            added, deleted = "new", "new"
        else:
            added, deleted = numstat_entries.get(path, ("0", "0"))
        rows.append(
            (
                status_entry.status,
                categorize_path(path),
                added,
                deleted,
                path,
            )
        )
    return rows


def main() -> int:
    require_repo_root()
    print("STATUS\tCATEGORY\t+\t-\tPATH")
    for row in iter_manifest_rows():
        print("\t".join(row))
    return 0


if __name__ == "__main__":
    sys.exit(main())
