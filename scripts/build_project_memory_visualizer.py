from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


EDGE_TYPES = {
    "contains",
    "blocked_by",
    "constrained_by",
    "derived_from",
    "points_to",
    "conflicts_with",
}


def read_utf8(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8-sig")


def write_json_utf8(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)


def strip_citations(text: str) -> str:
    text = re.sub(r"\[[^\]]+\]", "", text)
    return re.sub(r"\s+", " ", text).strip()


def truncate(text: str, limit: int) -> str:
    text = strip_citations(text)
    return text if len(text) <= limit else text[: limit - 1] + "…"


def first_heading(text: str) -> str:
    for line in text.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return ""


def first_paragraph(text: str) -> str:
    for chunk in re.split(r"\n\s*\n", text):
        cleaned = strip_citations(chunk)
        if cleaned:
            return cleaned
    return ""


def extract_section(text: str, heading: str) -> str:
    lines = text.splitlines()
    in_section = False
    out: list[str] = []
    for line in lines:
        if line.startswith("## "):
            if in_section:
                break
            in_section = line[3:].strip() == heading
            continue
        if in_section:
            out.append(line)
    return "\n".join(out).strip()


def bullet_items(text: str) -> list[str]:
    items: list[str] = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("- "):
            cleaned = strip_citations(stripped[2:])
            if cleaned:
                items.append(cleaned)
    return items


class Builder:
    def __init__(self, project_root: Path, memory_root: Path, vault_root: Path, output_dir: Path) -> None:
        self.project_root = project_root.resolve()
        self.memory_root = memory_root.resolve()
        self.vault_root = vault_root.resolve()
        self.output_dir = output_dir.resolve()
        self.nodes: list[dict] = []
        self.edges: list[dict] = []
        self.files: list[dict] = []
        self.sources: list[dict] = []
        self.warnings: list[dict] = []
        self.file_node_ids: dict[str, str] = {}
        self.semantic_targets: dict[str, list[str]] = {}
        self.node_seq = 0
        self.edge_seq = 0

    def next_id(self, prefix: str) -> str:
        self.node_seq += 1
        return f"{prefix}{self.node_seq}"

    def add_edge(self, src: str, dst: str, edge_type: str, label: str) -> None:
        if edge_type not in EDGE_TYPES:
            raise ValueError(f"unsupported edge type: {edge_type}")
        self.edge_seq += 1
        self.edges.append(
            {
                "id": f"e{self.edge_seq}",
                "from": src,
                "to": dst,
                "type": edge_type,
                "label": label,
            }
        )

    def vault_relative(self, target: Path) -> str:
        return target.resolve().relative_to(self.vault_root).as_posix()

    def add_file_node(self, target: Path, role: str, label: str | None = None) -> str:
        target = target.resolve()
        if not target.exists():
            raise FileNotFoundError(target)
        rel = self.vault_relative(target)
        if rel in self.file_node_ids:
            return self.file_node_ids[rel]
        node_id = self.next_id("F")
        self.file_node_ids[rel] = node_id
        human_label = label or target.name
        self.nodes.append(
            {
                "id": node_id,
                "type": "file",
                "label": human_label,
                "human_label": human_label,
                "summary": role,
                "status": "active",
                "priority": 3,
                "file": rel,
                "sources": [rel],
                "warnings": [],
            }
        )
        size_chars = len(read_utf8(target))
        self.files.append(
            {
                "path": target.relative_to(self.memory_root).as_posix(),
                "role": role,
                "default_read": True,
                "size_chars": size_chars,
                "status": "present",
            }
        )
        self.sources.append(
            {
                "id": rel,
                "type": "file",
                "path": target.relative_to(self.memory_root).as_posix(),
                "related_nodes": [node_id],
                "projected": True,
                "has_conflict": False,
            }
        )
        return node_id

    def add_semantic_node(
        self,
        *,
        label: str,
        node_type: str,
        summary: str,
        target_files: list[Path],
        status: str = "active",
        priority: int = 2,
    ) -> str:
        if "???" in label or "???" in summary:
            raise ValueError(f"invalid placeholder in semantic node: {label}")
        node_id = self.next_id("S")
        files_rel = [target.relative_to(self.memory_root).as_posix() for target in target_files]
        self.nodes.append(
            {
                "id": node_id,
                "type": node_type,
                "label": label,
                "human_label": label,
                "summary": truncate(summary, 80),
                "status": status,
                "priority": priority,
                "file": files_rel[0] if files_rel else None,
                "sources": files_rel,
                "warnings": [],
            }
        )
        self.semantic_targets[node_id] = files_rel
        for target in target_files:
            file_node_id = self.add_file_node(target, role=node_type)
            self.add_edge(node_id, file_node_id, "points_to", "打开文件")
        return node_id

    def build(self) -> tuple[dict, dict]:
        runtime_snapshot = self.memory_root / "runtime" / "01_current_snapshot.md"
        open_questions = self.memory_root / "runtime" / "02_open_questions.md"
        recent_actions = self.memory_root / "runtime" / "03_recent_actions.md"
        next_steps = self.memory_root / "runtime" / "05_next_mainline_tasks.md"
        thread_index = self.memory_root / "evidence" / "00_thread_index.md"

        anchor_facts = self.memory_root / "anchors" / "01_anchor_facts.md"
        constraints = self.memory_root / "anchors" / "02_key_constraints.md"
        decisions = self.memory_root / "anchors" / "03_active_decisions.md"
        conflicts = self.memory_root / "anchors" / "04_conflicts_to_keep.md"

        w_index = self.memory_root / "workstreams" / "_index.md"
        w1 = self.memory_root / "workstreams" / "W1_EA_EC_flux.md"
        w2 = self.memory_root / "workstreams" / "W2_morning_peak_workflow.md"
        w3 = self.memory_root / "workstreams" / "W3_fixed_tower_annual_nee_estimation.md"

        snapshot_text = read_utf8(runtime_snapshot)
        questions_text = read_utf8(open_questions)
        next_steps_text = read_utf8(next_steps)
        constraints_text = read_utf8(constraints)
        conflicts_text = read_utf8(conflicts)
        w1_text = read_utf8(w1)
        w2_text = read_utf8(w2)
        w3_text = read_utf8(w3)

        current_state_id = self.add_semantic_node(
            label="当前项目状态",
            node_type="runtime_state",
            summary=first_paragraph(snapshot_text) or first_heading(snapshot_text),
            target_files=[runtime_snapshot, recent_actions],
            priority=1,
        )

        anchors_id = self.add_semantic_node(
            label="稳定事实",
            node_type="anchor",
            summary=first_paragraph(read_utf8(anchor_facts)) or "项目长期稳定事实入口。",
            target_files=[anchor_facts],
        )
        constraints_id = self.add_semantic_node(
            label="关键约束",
            node_type="constraint",
            summary=first_paragraph(constraints_text) or "项目当前关键约束入口。",
            target_files=[constraints],
        )
        decisions_id = self.add_semantic_node(
            label="当前决策",
            node_type="decision",
            summary=first_paragraph(read_utf8(decisions)) or "当前仍生效的决策入口。",
            target_files=[decisions],
        )
        conflicts_id = self.add_semantic_node(
            label="保留冲突",
            node_type="conflict",
            summary=first_paragraph(conflicts_text) or "需要持续保留和核对的冲突入口。",
            target_files=[conflicts],
        )

        workstreams_id = self.add_semantic_node(
            label="工作流索引",
            node_type="workstream",
            summary=first_paragraph(read_utf8(w_index)) or "当前工作流总入口。",
            target_files=[w_index],
            priority=1,
        )
        w1_id = self.add_semantic_node(
            label="W1 EA/EC 通量主线",
            node_type="workstream",
            summary=first_paragraph(extract_section(w1_text, "目标")) or first_paragraph(w1_text),
            target_files=[w1],
            priority=1,
        )
        w2_id = self.add_semantic_node(
            label="W2 晨间 CO2 peak",
            node_type="workstream",
            summary=first_paragraph(extract_section(w2_text, "目标")) or first_paragraph(w2_text),
            target_files=[w2],
            priority=1,
        )
        w3_id = self.add_semantic_node(
            label="W3 固定塔年 NEE 估算",
            node_type="workstream",
            summary=first_paragraph(extract_section(w3_text, "目标")) or first_paragraph(w3_text),
            target_files=[w3],
            priority=1,
        )

        question_ids: list[str] = []
        for item in bullet_items(questions_text)[:6]:
            label = truncate(item, 24)
            question_ids.append(
                self.add_semantic_node(
                    label=label,
                    node_type="open_question",
                    summary=item,
                    target_files=[open_questions],
                )
            )

        next_step_id = self.add_semantic_node(
            label="下一最小步",
            node_type="next_step",
            summary=first_paragraph(next_steps_text) or "下一最小步入口。",
            target_files=[next_steps],
            priority=1,
        )
        evidence_id = self.add_semantic_node(
            label="线程索引",
            node_type="evidence",
            summary=first_paragraph(read_utf8(thread_index)) or "evidence 线程索引入口。",
            target_files=[thread_index],
        )

        self.add_edge(current_state_id, workstreams_id, "contains", "当前主线")
        self.add_edge(workstreams_id, w1_id, "contains", "工作流")
        self.add_edge(workstreams_id, w2_id, "contains", "工作流")
        self.add_edge(workstreams_id, w3_id, "contains", "工作流")

        self.add_edge(w1_id, constraints_id, "constrained_by", "受约束")
        self.add_edge(w2_id, constraints_id, "constrained_by", "受约束")
        self.add_edge(w3_id, constraints_id, "constrained_by", "受约束")
        self.add_edge(w1_id, decisions_id, "derived_from", "遵循当前决策")
        self.add_edge(w2_id, decisions_id, "derived_from", "遵循当前决策")
        self.add_edge(w3_id, decisions_id, "derived_from", "遵循当前决策")
        self.add_edge(current_state_id, anchors_id, "derived_from", "基于稳定事实")
        self.add_edge(current_state_id, conflicts_id, "conflicts_with", "仍有保留冲突")
        self.add_edge(next_step_id, current_state_id, "derived_from", "来自当前状态")
        self.add_edge(evidence_id, current_state_id, "derived_from", "追溯来源")

        if question_ids:
            self.add_edge(w2_id, question_ids[0], "blocked_by", "规则待冻结")
        if len(question_ids) > 1:
            self.add_edge(w3_id, question_ids[1], "blocked_by", "目录映射待确认")
        for question_id in question_ids:
            self.add_edge(question_id, current_state_id, "derived_from", "来自当前快照")

        project = {
            "name": "06 EA project memory",
            "root": "project_memory",
            "current_state": first_heading(snapshot_text) or "当前项目快照",
            "next_step": truncate(first_paragraph(next_steps_text), 100) or "查看下一最小步文件",
            "updated_at": "2026-07-07",
        }
        memory_graph = {
            "schema_version": "1.0",
            "project": project,
            "nodes": self.nodes,
            "edges": [{"from": e["from"], "to": e["to"], "type": e["type"], "label": e["label"]} for e in self.edges],
            "files": self.files,
            "sources": self.sources,
            "warnings": self.warnings,
        }
        canvas = self.build_canvas()
        self.validate(canvas)
        return memory_graph, canvas

    def build_canvas(self) -> dict:
        left_x = 0
        center_x = 520
        right_x = 1080
        bottom_x = 520

        layouts: dict[str, tuple[int, int, int, int]] = {}

        semantic_order = [
            ("稳定事实", left_x, 0),
            ("关键约束", left_x, 180),
            ("当前决策", left_x, 360),
            ("当前项目状态", center_x, 0),
            ("工作流索引", center_x, 180),
            ("W1 EA/EC 通量主线", center_x, 360),
            ("W2 晨间 CO2 peak", center_x, 560),
            ("W3 固定塔年 NEE 估算", center_x, 760),
            ("保留冲突", right_x, 0),
            ("下一最小步", right_x, 180),
            ("线程索引", bottom_x, 1040),
        ]
        open_question_y = 380
        for label, x, y in semantic_order:
            layouts[label] = (x, y, 280, 120)
        for node in self.nodes:
            if node["type"] == "open_question":
                layouts[node["label"]] = (right_x, open_question_y, 320, 120)
                open_question_y += 160

        file_columns = {
            "anchors/": left_x + 300,
            "runtime/": center_x + 320,
            "workstreams/": center_x + 320,
            "evidence/": bottom_x + 320,
        }
        file_y: dict[str, int] = {
            "anchors/": 0,
            "runtime/": 0,
            "workstreams/": 220,
            "evidence/": 1040,
        }

        canvas_nodes: list[dict] = []
        for node in self.nodes:
            if node["type"] == "file":
                rel = node["file"]
                prefix = next((p for p in file_columns if rel.startswith(p)), "runtime/")
                x = file_columns[prefix]
                y = file_y[prefix]
                file_y[prefix] += 160
                canvas_nodes.append(
                    {
                        "id": node["id"],
                        "type": "file",
                        "file": rel,
                        "x": x,
                        "y": y,
                        "width": 340,
                        "height": 100,
                    }
                )
            else:
                x, y, width, height = layouts.get(node["label"], (center_x, 0, 300, 120))
                canvas_nodes.append(
                    {
                        "id": node["id"],
                        "type": "text",
                        "text": f"{node['label']}\n{node['summary']}",
                        "x": x,
                        "y": y,
                        "width": width,
                        "height": height,
                    }
                )

        canvas_edges = []
        for edge in self.edges:
            canvas_edges.append(
                {
                    "id": edge["id"],
                    "fromNode": edge["from"],
                    "toNode": edge["to"],
                    "fromSide": "right",
                    "toSide": "left",
                    "label": edge["label"],
                }
            )
        return {"nodes": canvas_nodes, "edges": canvas_edges}

    def validate(self, canvas: dict) -> None:
        file_paths_seen: dict[str, str] = {}
        file_node_ids = {node["id"] for node in self.nodes if node["type"] == "file"}
        for node in canvas["nodes"]:
            if node["type"] == "file":
                rel = node["file"]
                if "???" in rel:
                    raise ValueError(f"invalid file path placeholder: {rel}")
                if rel in file_paths_seen:
                    raise ValueError(f"duplicate file node path: {rel}")
                file_paths_seen[rel] = node["id"]
                target = self.vault_root / Path(rel)
                if not target.exists():
                    raise FileNotFoundError(f"canvas file node does not exist: {rel}")
            if node["type"] == "text" and "???" in node["text"]:
                raise ValueError(f"invalid text placeholder: {node['text']}")

        for edge in self.edges:
            if "???" in edge["label"]:
                raise ValueError(f"invalid edge label placeholder: {edge['label']}")
            if edge["type"] not in EDGE_TYPES:
                raise ValueError(f"invalid edge type: {edge['type']}")

        for node in self.nodes:
            if node["type"] == "file":
                continue
            targets = [
                edge["to"]
                for edge in self.edges
                if edge["from"] == node["id"] and edge["type"] in {"points_to", "derived_from"}
            ]
            if not any(target in file_node_ids for target in targets):
                raise ValueError(f"semantic node missing file/source pointer: {node['label']}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build project memory graph and Obsidian canvas.")
    parser.add_argument("--project-root", type=Path, default=Path.cwd())
    parser.add_argument("--memory-root", type=Path)
    parser.add_argument("--vault-root", type=Path)
    parser.add_argument("--output-dir", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project_root = args.project_root.resolve()
    memory_root = (args.memory_root or (project_root / "project_memory")).resolve()
    vault_root = (args.vault_root or project_root).resolve()
    output_dir = (args.output_dir or (memory_root / "runtime" / "visual")).resolve()

    builder = Builder(
        project_root=project_root,
        memory_root=memory_root,
        vault_root=vault_root,
        output_dir=output_dir,
    )
    memory_graph, canvas = builder.build()
    write_json_utf8(output_dir / "memory_graph.json", memory_graph)
    write_json_utf8(output_dir / "project_memory.canvas", canvas)
    print(output_dir / "memory_graph.json")
    print(output_dir / "project_memory.canvas")


if __name__ == "__main__":
    main()
