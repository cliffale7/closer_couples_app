"""Command line for baseline builds and approved-book dry runs."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from book_ingest.activate import activate_pack, gate_for, load_active_pack
from book_ingest.book_project import EDITION_ID, build_book_project_pack, copy_staged_art
from book_ingest.catalog import load_catalog
from book_ingest.common import EditionRejected, IngestError, write_json
from book_ingest.diff_engine import classify_impact, diff_packs, prepare_successor, render_diff_markdown
from book_ingest.extract import audit_manuscript, extract_docx, parse_markdown_chapter
from book_ingest.inbox import find_approved_editions
from book_ingest.pack import build_baseline_pack, empty_metadata, structural_errors
from book_ingest.reports import write_baseline_intake, write_chapter_status, write_reconciliation_csv


def repo_root_from(start: Path | None = None) -> Path:
    current = (start or Path.cwd()).resolve()
    for candidate in [current, *current.parents]:
        if (candidate / "CURSOR_ANDROID_MASTER_WORK_ORDER.md").exists():
            return candidate
    return current


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Sync an approved Closer Project book edition.")
    parser.add_argument("--inbox", default="book_inbox")
    parser.add_argument("--repo-root", default=None)
    parser.add_argument("--edition", default=None, help="Explicit edition directory. Approval is still required.")
    parser.add_argument("--baseline", action="store_true", help="Build the v0.1 inventory pack.")
    parser.add_argument(
        "--book-project",
        default=None,
        help="Path to The Closer Project markdown tree. Imports a copyedited draft and does not approve it.",
    )
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--report", action="store_true")
    parser.add_argument(
        "--approved",
        action="store_true",
        help="Owner confirms this invocation. Does not override a manifest that is explicitly unapproved.",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    root = Path(args.repo_root).resolve() if args.repo_root else repo_root_from()
    try:
        if args.book_project:
            return _book_project(root, Path(args.book_project), apply=args.apply, report=args.report or args.apply)
        if args.baseline:
            return _baseline(root, apply=args.apply, report=args.report or args.apply)
        return _inbox(root, args)
    except IngestError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1


def _baseline(root: Path, *, apply: bool, report: bool) -> int:
    catalog = root / "source" / "book_baseline" / "experience_catalog.json"
    manuscript = root / "source" / "book_baseline" / "The_Closer_Project_Working_Manuscript_v0.1.docx"
    briefs = root / "source" / "book_baseline" / "ORIGINAL_IDEAS_EXPANDED.md"
    pack = build_baseline_pack(catalog, manuscript_path=manuscript, briefs_path=briefs)
    audit = None
    if manuscript.exists():
        extraction = extract_docx(manuscript)
        titles = {item["stable_id"]: item["title"] for item in pack["experiences"]}
        audit = audit_manuscript(extraction, titles)
    print(
        json.dumps(
            {
                "edition_id": pack["edition"]["edition_id"],
                "approval_state": pack["edition"]["approval_state"],
                "publication_gate": "BLOCKED_PENDING_APPROVED_BOOK",
                "experiences": len(pack["experiences"]),
                "signatures": len(pack["signatures"]),
                "checksum": pack["edition"]["checksum"],
                "apply": apply,
            },
            indent=2,
        )
    )
    if report:
        write_baseline_intake(root, pack=pack, manuscript_audit=audit, catalog_errors=[])
    if not apply:
        return 0
    relative = f"content/canonical/{pack['edition']['edition_id']}"
    activate_pack(root, pack, relative_dir=relative, publication_gate=gate_for(pack))
    write_reconciliation_csv(root, pack)
    write_chapter_status(root, pack)
    return 0


def _book_project(root: Path, project: Path, *, apply: bool, report: bool) -> int:
    """Import a copyedited draft. --approved cannot promote this path."""

    if not project.is_absolute():
        project = root / project
    catalog = load_catalog(root / "source" / "book_baseline" / "experience_catalog.json")
    pack = build_book_project_pack(project, catalog, require_complete=True)
    previous = load_active_pack(root)
    diff = diff_packs(previous, pack)
    prepared = prepare_successor(previous, pack, diff)
    impact = classify_impact(diff)
    gate = gate_for(prepared)
    summary = {
        "edition_id": prepared["edition"]["edition_id"],
        "approval_state": prepared["edition"]["approval_state"],
        "completeness": prepared["edition"]["completeness"],
        "publication_gate": gate,
        "experiences": len(prepared["experiences"]),
        "signatures": len(prepared["signatures"]),
        "front_matter": len(prepared.get("front_matter") or []),
        "assets": len(prepared.get("assets") or []),
        "text_changed": len(diff["text_changed"]),
        "metadata_changed": len(diff["metadata_changed"]),
        "artwork_changed": len(diff["artwork_changed"]),
        "apply": apply,
        "note": "Draft import. The publication gate stays blocked until a manifest says owner_approved.",
    }
    print(json.dumps(summary, indent=2))
    if report:
        report_dir = root / "planning" / "updates" / f"{diff.get('from_edition') or 'none'}_to_{EDITION_ID}"
        report_dir.mkdir(parents=True, exist_ok=True)
        (report_dir / "DIFF.md").write_text(render_diff_markdown(diff, impact), encoding="utf-8")
        write_json(report_dir / "impact.json", {"diff_counts": summary, "impact": impact})
        intake = root / "planning" / "intake" / "EDITION_v1-draft.md"
        intake.parent.mkdir(parents=True, exist_ok=True)
        intake.write_text(
            "\n".join(
                [
                    "# v1 draft intake",
                    "",
                    f"- Source: `{project}`",
                    f"- Edition: `{prepared['edition']['edition_id']}` `{prepared['edition']['version']}`",
                    f"- Approval: `{prepared['edition']['approval_state']}`",
                    f"- Completeness: `{prepared['edition']['completeness']}`",
                    f"- Publication gate: `{gate}`",
                    f"- Chapters: {len(prepared['experiences'])}",
                    f"- Signatures: {len(prepared['signatures'])}",
                    f"- Front matter: {len(prepared.get('front_matter') or [])}",
                    f"- Artwork records: {len(prepared.get('assets') or [])}",
                    "- Private journals were not read.",
                    "- This draft is not the owner-approved release.",
                    "",
                ]
            ),
            encoding="utf-8",
        )
    if not apply:
        return 0
    art_dir = root / "content" / "canonical" / EDITION_ID / "art"
    copied = copy_staged_art(prepared, project, art_dir)
    pointer = activate_pack(
        root,
        prepared,
        relative_dir=f"content/canonical/{EDITION_ID}",
        publication_gate=gate,
    )
    write_reconciliation_csv(root, prepared)
    write_chapter_status(
        root,
        prepared,
        content_mapped="copyedited_draft",
        art_ready=True,
        note="Copyedited v1 draft is loaded. book_validated stays false until the owner approves the edition.",
    )
    print(json.dumps({"activated": pointer["edition_id"], "artwork_copied": copied, "checksum": pointer["checksum"], "publication_gate": pointer["publication_gate"]}, indent=2))
    return 0


def _inbox(root: Path, args: argparse.Namespace) -> int:
    inbox = (root / args.inbox).resolve()
    if args.edition:
        edition_dir = Path(args.edition)
        if not edition_dir.is_absolute():
            edition_dir = root / edition_dir
        manifest_path = edition_dir / "manifest.json"
        if not manifest_path.exists():
            raise EditionRejected(f"no manifest.json in {edition_dir}")
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        approval = str(manifest.get("approval") or "")
        if not _approval_allows(approval, explicit_owner_flag=args.approved):
            _print_blocked(
                manifest.get("edition_id"),
                f"manifest approval is {approval or 'missing'}; an explicit unapproved manifest is never overridden",
            )
            return 2 if args.apply else 0
        candidate = {"path": edition_dir, "manifest": manifest, "edition_id": manifest.get("edition_id")}
    else:
        approved = find_approved_editions(inbox)
        if not approved:
            _print_blocked(None, "no owner_approved edition in book_inbox")
            report_path = root / "planning" / "intake" / "NO_APPROVED_BOOK.json"
            write_json(
                report_path,
                {
                    "publication_gate": "BLOCKED_PENDING_APPROVED_BOOK",
                    "inbox": str(inbox),
                    "approved_editions": [],
                },
            )
            return 2 if args.apply else 0
        candidate = approved[-1]
    pack = _load_edition_directory(candidate["path"], candidate["manifest"])
    errors = structural_errors(pack)
    if errors:
        raise EditionRejected("edition failed structural validation:\n- " + "\n- ".join(errors))
    previous = load_active_pack(root)
    diff = diff_packs(previous, pack)
    prepared = prepare_successor(previous, pack, diff)
    impact = classify_impact(diff)
    report = {
        "edition_id": prepared["edition"]["edition_id"],
        "publication_gate": gate_for(prepared),
        "impact": impact,
        "added": [item["stable_id"] for item in diff["added"]],
        "removed": [item["stable_id"] for item in diff["removed"]],
        "text_changed": diff["text_changed"],
        "apply": bool(args.apply),
    }
    print(json.dumps(report, indent=2))
    if args.report or args.apply:
        from_id = diff.get("from_edition") or "none"
        to_id = diff.get("to_edition") or "unknown"
        report_dir = root / "planning" / "updates" / f"{from_id}_to_{to_id}"
        report_dir.mkdir(parents=True, exist_ok=True)
        (report_dir / "DIFF.md").write_text(render_diff_markdown(diff, impact), encoding="utf-8")
        write_json(report_dir / "impact.json", {"diff": diff, "impact": impact})
    if not args.apply:
        return 0
    if not args.approved and str(candidate["manifest"].get("approval")) != "owner_approved":
        return 2
    relative = f"content/canonical/{prepared['edition']['edition_id']}"
    activate_pack(root, prepared, relative_dir=relative, publication_gate=gate_for(prepared))
    return 0


def _load_edition_directory(path: Path, manifest: dict[str, Any]) -> dict[str, Any]:
    pack_file = path / "content_pack.json"
    if pack_file.exists():
        pack = json.loads(pack_file.read_text(encoding="utf-8"))
        pack.setdefault("edition", {})
        pack["edition"]["approval_state"] = manifest.get("approval") or pack["edition"].get("approval_state")
        pack["edition"]["edition_id"] = manifest.get("edition_id") or pack["edition"].get("edition_id")
        pack["edition"]["version"] = manifest.get("version") or pack["edition"].get("version")
        return pack
    chapter_dir = path / "chapters"
    if chapter_dir.exists():
        return _pack_from_markdown(path, manifest)
    raise EditionRejected(f"{path} has no content_pack.json or chapters/")


def _pack_from_markdown(path: Path, manifest: dict[str, Any]) -> dict[str, Any]:
    experiences = []
    for chapter in sorted((path / "chapters").glob("*.md")):
        meta, body = parse_markdown_chapter(chapter.read_text(encoding="utf-8"))
        stable_id = meta.get("stable_id") or chapter.stem[:3]
        experiences.append(
            {
                "stable_id": stable_id,
                "numeric_id": int(stable_id) if stable_id.isdigit() else None,
                "title": meta.get("title") or chapter.stem,
                "aliases": [],
                "part_id": meta.get("part_id"),
                "subtitle": meta.get("subtitle"),
                "provenance": "markdown_edition",
                "prose_blocks": [
                    {
                        "block_id": f"{stable_id}-body",
                        "kind": "full_chapter",
                        "text": body,
                        "origin": "verbatim_markdown",
                    }
                ],
                "preparation": [],
                "materials": [],
                "steps": [],
                "variants": [],
                "debrief": None,
                "prompt_ids": [],
                "reference_ids": [],
                "asset_ids": [],
                "metadata": empty_metadata(),
                "interaction_definition": None,
                "interaction_version": None,
                "source_gaps": [],
            }
        )
    return {
        "content_schema_version": manifest.get("content_schema_version") or "1.0.0",
        "edition": {
            "source_book_id": manifest.get("source_book_id") or "the-closer-project",
            "edition_id": manifest.get("edition_id"),
            "version": manifest.get("version"),
            "publication_date": manifest.get("publication_date"),
            "source_hashes": {},
            "imported_at": None,
            "provenance": "markdown chapters",
            "locale": manifest.get("locale") or "en",
            "approval_state": manifest.get("approval"),
            "completeness": manifest.get("completeness") or "incomplete",
            "app_compatibility": ">=0.1.0 <2.0.0",
            "checksum": None,
        },
        "parts": manifest.get("parts") or [],
        "experiences": experiences,
        "signatures": manifest.get("signatures") or [],
        "prompts": [],
        "assets": [],
        "legacy_archive": [],
        "required_signature_ids": ["S01", "S02", "S03", "S04", "S05", "S06"],
    }


def _approval_allows(approval: str, *, explicit_owner_flag: bool) -> bool:
    """Manifest value owner_approved is enough. A draft marker cannot be overridden."""

    if approval == "owner_approved":
        return True
    if approval == "" and explicit_owner_flag:
        return True
    return False


def _print_blocked(edition_id: str | None, reason: str) -> None:
    print(
        json.dumps(
            {
                "publication_gate": "BLOCKED_PENDING_APPROVED_BOOK",
                "edition_id": edition_id,
                "reason": reason,
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    raise SystemExit(main())
