#!/usr/bin/env python
"""Build a lightweight REgov workstream dashboard from project_memory folders."""

from __future__ import annotations

import argparse
import datetime as dt
import html
from pathlib import Path
from typing import Iterable


def read_text(path: Path) -> str:
    if not path.exists():
        return ""
    for encoding in ("utf-8-sig", "utf-8", "gb18030"):
        try:
            return path.read_text(encoding=encoding)
        except UnicodeDecodeError:
            continue
    return path.read_text(errors="replace")


def clean_label(text: str, max_len: int = 90) -> str:
    text = " ".join(text.strip().replace("|", "/").split())
    if len(text) > max_len:
        text = text[: max_len - 1] + "..."
    return text or "未命名"


def mermaid_label(text: str) -> str:
    return html.escape(clean_label(text)).replace('"', "'")


def find_project_memory(path: Path) -> Path | None:
    if (path / "anchors").exists() and (path / "runtime").exists():
        return path
    if (path / "project_memory").exists():
        return path / "project_memory"
    return None


def extract_first_bullets(text: str, limit: int = 4) -> list[str]:
    bullets: list[str] = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("- "):
            bullets.append(clean_label(stripped[2:], 110))
        if len(bullets) >= limit:
            break
    return bullets


def extract_section_after(text: str, heading: str, limit: int = 3) -> list[str]:
    lines = text.splitlines()
    capture = False
    found: list[str] = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("#"):
            if capture:
                break
            if heading in stripped:
                capture = True
            continue
        if capture and stripped:
            if stripped.startswith("- "):
                found.append(clean_label(stripped[2:], 110))
            elif not found:
                found.append(clean_label(stripped, 110))
        if len(found) >= limit:
            break
    return found


def discover_projects(root: Path, explicit: list[str]) -> list[tuple[str, Path | None, str]]:
    projects: list[tuple[str, Path | None, str]] = []
    for item in explicit:
        if "=" not in item:
            projects.append((item, None, "project argument must be NAME=PATH"))
            continue
        name, raw_path = item.split("=", 1)
        memory = find_project_memory(Path(raw_path).expanduser())
        if memory:
            projects.append((name.strip(), memory, "ok"))
        else:
            projects.append((name.strip(), None, f"unresolved path: {raw_path}"))

    if not projects:
        memory = find_project_memory(root)
        if memory:
            projects.append((root.name or "Current project", memory, "ok"))

    return projects


def workstream_files(memory: Path) -> list[Path]:
    workstreams = memory / "workstreams"
    if not workstreams.exists():
        return []
    files = [p for p in workstreams.glob("*.md") if p.name != "_index.md"]
    return sorted(files)


def count_open_questions(memory: Path) -> int:
    text = read_text(memory / "runtime" / "02_open_questions.md")
    return sum(1 for line in text.splitlines() if line.strip().startswith("- "))


def project_summary(memory: Path) -> dict[str, object]:
    snapshot = read_text(memory / "runtime" / "01_current_snapshot.md")
    next_tasks = read_text(memory / "runtime" / "05_next_mainline_tasks.md")
    workstreams = workstream_files(memory)
    return {
        "focus": extract_section_after(snapshot, "当前重点", 2) or extract_first_bullets(snapshot, 2),
        "next": extract_section_after(snapshot, "下一最小步", 2)
        or extract_section_after(next_tasks, "优先任务", 2),
        "open_count": count_open_questions(memory),
        "workstreams": workstreams,
    }


def render_dashboard(projects: list[tuple[str, Path | None, str]]) -> str:
    now = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    lines: list[str] = [
        "# REgov Workstream Dashboard",
        "",
        f"Generated: {now}",
        "",
        "```mermaid",
        "flowchart TD",
        '  R["REgov"]',
    ]

    tables: list[str] = [
        "",
        "## Project Table",
        "",
        "| Project | Status | Project memory | Workstreams | Open questions |",
        "|---|---|---|---:|---:|",
    ]
    details: list[str] = ["", "## Workstream Details", ""]

    for index, (name, memory, status) in enumerate(projects):
        project_id = f"P{index}"
        lines.append(f'  R --> {project_id}["{mermaid_label(name)}"]')
        if memory is None:
            unresolved_id = f"{project_id}U"
            lines.append(f'  {project_id} --> {unresolved_id}["UNRESOLVED: {mermaid_label(status)}"]')
            tables.append(f"| {name} | {status} | unresolved | 0 | 0 |")
            continue

        summary = project_summary(memory)
        workstreams = summary["workstreams"]
        open_count = summary["open_count"]
        focus_items = summary["focus"]
        next_items = summary["next"]

        focus_id = f"{project_id}F"
        next_id = f"{project_id}N"
        open_id = f"{project_id}Q"
        lines.append(f'  {project_id} --> {focus_id}["当前重点"]')
        lines.append(f'  {project_id} --> {next_id}["下一步"]')
        lines.append(f'  {project_id} --> {open_id}["开放问题: {open_count}"]')

        for j, item in enumerate(focus_items):
            lines.append(f'  {focus_id} --> {project_id}F{j}["{mermaid_label(item)}"]')
        for j, item in enumerate(next_items):
            lines.append(f'  {next_id} --> {project_id}N{j}["{mermaid_label(item)}"]')

        for j, ws in enumerate(workstreams):
            ws_id = f"{project_id}W{j}"
            label = ws.stem.replace("_", " ")
            lines.append(f'  {project_id} --> {ws_id}["{mermaid_label(label)}"]')

        tables.append(
            f"| {name} | ok | `{memory}` | {len(workstreams)} | {open_count} |"
        )

        details.append(f"### {name}")
        details.append("")
        details.append(f"- Project memory: `{memory}`")
        if focus_items:
            details.append("- Current focus:")
            details.extend(f"  - {item}" for item in focus_items)
        if next_items:
            details.append("- Next step:")
            details.extend(f"  - {item}" for item in next_items)
        if workstreams:
            details.append("- Workstreams:")
            for ws in workstreams:
                ws_text = read_text(ws)
                bullets = extract_first_bullets(ws_text, 2)
                details.append(f"  - `{ws.name}`")
                details.extend(f"    - {bullet}" for bullet in bullets)
        details.append("")

    lines.append("```")
    return "\n".join(lines + tables + details) + "\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".", help="Workspace root to inspect.")
    parser.add_argument(
        "--project",
        action="append",
        default=[],
        help='Explicit project mapping as "NAME=PATH". Repeatable.',
    )
    parser.add_argument(
        "--output",
        default="regov_dashboard/workstream_map.md",
        help="Output Markdown dashboard path.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    projects = discover_projects(root, args.project)
    output = Path(args.output)
    if not output.is_absolute():
        output = root / output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render_dashboard(projects), encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
