#!/usr/bin/env python3
"""Fetch schema catalogs from Global FM and JKR db_query_tool, then write a diff report."""

from __future__ import annotations

import json
import subprocess
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

API_KEY = "8c4442e9927b90ade9228f5d462cc1f37a09449b841477aeb373e698902a64cf"

ENDPOINTS = {
    "globalfm": "https://gfmgems.globalfm.com.my/maintenance/db_query_tool.php",
    "jkr": "https://gems.jkr.gov.my/maintenance/db_query_tool.php",
}

QUERIES = {
    "identity": """SELECT DATABASE() AS db_name, @@hostname AS host, VERSION() AS version""",
    "tables": """
SELECT TABLE_NAME, ENGINE, TABLE_COLLATION, TABLE_COMMENT,
       TABLE_ROWS, DATA_LENGTH, INDEX_LENGTH
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME
""".strip(),
    "columns": """
SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, COLUMN_TYPE,
       IS_NULLABLE, COLUMN_DEFAULT, COLUMN_KEY, EXTRA, COLUMN_COMMENT,
       CHARACTER_SET_NAME, COLLATION_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, ORDINAL_POSITION
""".strip(),
    "indexes": """
SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX,
       COLUMN_NAME, COLLATION, CARDINALITY, INDEX_TYPE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX
""".strip(),
    "fks": """
SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME,
       REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME, ORDINAL_POSITION
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME, ORDINAL_POSITION
""".strip(),
}


def run_query(url: str, query: str) -> list[dict]:
    result = subprocess.run(
        [
            "curl",
            "-sS",
            "--url",
            url,
            "-H",
            "Accept: application/json",
            "-H",
            f"x-api-key: {API_KEY}",
            "-F",
            "action=execute",
            "-F",
            f"query={query}",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(f"curl failed for {url}: {result.stderr}")
    try:
        payload = json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Invalid JSON from {url}: {result.stdout[:500]}") from exc
    if not payload.get("success"):
        raise RuntimeError(f"Query failed on {url}: {payload.get('error')}")
    data = payload.get("data") or payload
    rows = data.get("results") or []
    return rows


def fetch_side(name: str, url: str) -> dict:
    print(f"Fetching {name}...", flush=True)
    out = {"name": name, "url": url}
    for key, sql in QUERIES.items():
        print(f"  - {key}", flush=True)
        out[key] = run_query(url, sql)
        print(f"    rows={len(out[key])}", flush=True)
    return out


def col_sig(c: dict) -> tuple:
    return (
        str(c.get("COLUMN_TYPE") or ""),
        str(c.get("IS_NULLABLE") or ""),
        str(c.get("COLUMN_DEFAULT") if c.get("COLUMN_DEFAULT") is not None else "∅"),
        str(c.get("COLUMN_KEY") or ""),
        str(c.get("EXTRA") or ""),
        str(c.get("CHARACTER_SET_NAME") or ""),
        str(c.get("COLLATION_NAME") or ""),
    )


def index_groups(rows: list[dict]) -> dict[tuple[str, str], list[dict]]:
    groups: dict[tuple[str, str], list[dict]] = defaultdict(list)
    for r in rows:
        key = (r["TABLE_NAME"], r["INDEX_NAME"])
        groups[key].append(r)
    for key in groups:
        groups[key].sort(key=lambda x: int(x.get("SEQ_IN_INDEX") or 0))
    return groups


def index_sig(parts: list[dict]) -> tuple:
    cols = tuple(p.get("COLUMN_NAME") for p in parts)
    non_unique = str(parts[0].get("NON_UNIQUE")) if parts else ""
    idx_type = str(parts[0].get("INDEX_TYPE") or "") if parts else ""
    return (non_unique, idx_type, cols)


def fk_groups(rows: list[dict]) -> dict[tuple[str, str], list[dict]]:
    groups: dict[tuple[str, str], list[dict]] = defaultdict(list)
    for r in rows:
        key = (r["TABLE_NAME"], r["CONSTRAINT_NAME"])
        groups[key].append(r)
    for key in groups:
        groups[key].sort(key=lambda x: int(x.get("ORDINAL_POSITION") or 0))
    return groups


def fk_sig(parts: list[dict]) -> tuple:
    cols = tuple(p.get("COLUMN_NAME") for p in parts)
    ref_table = parts[0].get("REFERENCED_TABLE_NAME") if parts else None
    ref_cols = tuple(p.get("REFERENCED_COLUMN_NAME") for p in parts)
    return (ref_table, cols, ref_cols)


def build_report(a: dict, b: dict) -> str:
    # a = globalfm/gems2, b = jkr
    a_id = a["identity"][0]
    b_id = b["identity"][0]
    a_tables = {t["TABLE_NAME"]: t for t in a["tables"]}
    b_tables = {t["TABLE_NAME"]: t for t in b["tables"]}

    only_a = sorted(set(a_tables) - set(b_tables))
    only_b = sorted(set(b_tables) - set(a_tables))
    common = sorted(set(a_tables) & set(b_tables))

    a_cols: dict[str, dict[str, dict]] = defaultdict(dict)
    b_cols: dict[str, dict[str, dict]] = defaultdict(dict)
    for c in a["columns"]:
        a_cols[c["TABLE_NAME"]][c["COLUMN_NAME"]] = c
    for c in b["columns"]:
        b_cols[c["TABLE_NAME"]][c["COLUMN_NAME"]] = c

    a_idx = index_groups(a["indexes"])
    b_idx = index_groups(b["indexes"])
    a_fk = fk_groups(a["fks"])
    b_fk = fk_groups(b["fks"])

    tables_with_col_diff = []
    col_diff_details = []
    for table in common:
        ac = a_cols.get(table, {})
        bc = b_cols.get(table, {})
        only_ac = sorted(set(ac) - set(bc))
        only_bc = sorted(set(bc) - set(ac))
        changed = []
        for col in sorted(set(ac) & set(bc)):
            if col_sig(ac[col]) != col_sig(bc[col]):
                changed.append((col, ac[col], bc[col]))
        if only_ac or only_bc or changed:
            tables_with_col_diff.append(table)
            col_diff_details.append((table, only_ac, only_bc, changed))

    # Index diffs on common tables
    idx_diff_tables = []
    idx_details = []
    for table in common:
        a_keys = {k for k in a_idx if k[0] == table}
        b_keys = {k for k in b_idx if k[0] == table}
        a_names = {k[1] for k in a_keys}
        b_names = {k[1] for k in b_keys}
        only_ai = sorted(a_names - b_names)
        only_bi = sorted(b_names - a_names)
        changed_i = []
        for name in sorted(a_names & b_names):
            if index_sig(a_idx[(table, name)]) != index_sig(b_idx[(table, name)]):
                changed_i.append(name)
        if only_ai or only_bi or changed_i:
            idx_diff_tables.append(table)
            idx_details.append((table, only_ai, only_bi, changed_i))

    fk_diff_tables = []
    fk_details = []
    for table in common:
        a_keys = {k for k in a_fk if k[0] == table}
        b_keys = {k for k in b_fk if k[0] == table}
        a_names = {k[1] for k in a_keys}
        b_names = {k[1] for k in b_keys}
        only_af = sorted(a_names - b_names)
        only_bf = sorted(b_names - a_names)
        changed_f = []
        for name in sorted(a_names & b_names):
            if fk_sig(a_fk[(table, name)]) != fk_sig(b_fk[(table, name)]):
                changed_f.append(name)
        if only_af or only_bf or changed_f:
            fk_diff_tables.append(table)
            fk_details.append((table, only_af, only_bf, changed_f))

    # Notification callouts
    def has_col(side_cols, table, col):
        return col in side_cols.get(table, {})

    noti_checks = [
        ("noti_send", "noti_data"),
        ("noti_log", "noti_data"),
        ("noti_log", "noti_log_read_at"),
        ("sys_user", "user_token"),
    ]

    lines = []
    lines.append("# Schema Diff: Global FM (gems2) vs JKR (gems)")
    lines.append("")
    lines.append(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S %Z')}".rstrip())
    lines.append("")
    lines.append("## Environments")
    lines.append("")
    lines.append("| Side | Label | Database | Host | MariaDB |")
    lines.append("|------|-------|----------|------|---------|")
    lines.append(
        f"| A | Global FM | `{a_id['db_name']}` | `{a_id['host']}` | `{a_id['version']}` |"
    )
    lines.append(
        f"| B | JKR | `{b_id['db_name']}` | `{b_id['host']}` | `{b_id['version']}` |"
    )
    lines.append("")
    lines.append("Queried via `maintenance/db_query_tool.php` (`action=execute`) with `x-api-key`.")
    lines.append("")
    lines.append("## Summary")
    lines.append("")
    lines.append("| Metric | Global FM | JKR |")
    lines.append("|--------|-----------|-----|")
    lines.append(f"| Base tables | {len(a_tables)} | {len(b_tables)} |")
    lines.append(f"| Columns | {len(a['columns'])} | {len(b['columns'])} |")
    lines.append(f"| Index entries | {len(a['indexes'])} | {len(b['indexes'])} |")
    lines.append(f"| Foreign key column refs | {len(a['fks'])} | {len(b['fks'])} |")
    lines.append(f"| Tables only in Global FM | {len(only_a)} | — |")
    lines.append(f"| Tables only in JKR | — | {len(only_b)} |")
    lines.append(f"| Common tables | {len(common)} | {len(common)} |")
    lines.append(f"| Common tables with column diffs | {len(tables_with_col_diff)} | {len(tables_with_col_diff)} |")
    lines.append(f"| Common tables with index diffs | {len(idx_diff_tables)} | {len(idx_diff_tables)} |")
    lines.append(f"| Common tables with FK diffs | {len(fk_diff_tables)} | {len(fk_diff_tables)} |")
    lines.append("")

    lines.append("## Notification deploy callout")
    lines.append("")
    lines.append("| Object | Global FM | JKR | Needed for new push code? |")
    lines.append("|--------|-----------|-----|---------------------------|")
    for table, col in noti_checks:
        ga = "YES" if has_col(a_cols, table, col) else "NO"
        jb = "YES" if has_col(b_cols, table, col) else "NO"
        needed = "Yes" if (table, col) != ("sys_user", "user_token") else "Existing"
        lines.append(f"| `{table}.{col}` | {ga} | {jb} | {needed} |")
    lines.append("")
    missing_jkr = [
        f"`{t}.{c}`"
        for t, c in noti_checks
        if (t, c) != ("sys_user", "user_token") and not has_col(b_cols, t, c)
    ]
    if missing_jkr:
        lines.append(
            "**JKR is missing notification columns:** "
            + ", ".join(missing_jkr)
            + ". Run `maintenance/add_noti_data_columns.sql` on JKR before deploying push code."
        )
    else:
        lines.append("JKR already has the required notification columns for the new push code.")
    lines.append("")

    lines.append("## Tables only in Global FM (gems2)")
    lines.append("")
    if only_a:
        for t in only_a:
            lines.append(f"- `{t}`")
    else:
        lines.append("_None_")
    lines.append("")

    lines.append("## Tables only in JKR")
    lines.append("")
    if only_b:
        for t in only_b:
            lines.append(f"- `{t}`")
    else:
        lines.append("_None_")
    lines.append("")

    lines.append("## Column differences (common tables)")
    lines.append("")
    if not col_diff_details:
        lines.append("_No column differences on common tables._")
        lines.append("")
    else:
        for table, only_ac, only_bc, changed in col_diff_details:
            lines.append(f"### `{table}`")
            lines.append("")
            if only_ac:
                lines.append("**Columns only in Global FM:**")
                for c in only_ac:
                    cc = a_cols[table][c]
                    lines.append(f"- `{c}` ({cc.get('COLUMN_TYPE')}, null={cc.get('IS_NULLABLE')})")
                lines.append("")
            if only_bc:
                lines.append("**Columns only in JKR:**")
                for c in only_bc:
                    cc = b_cols[table][c]
                    lines.append(f"- `{c}` ({cc.get('COLUMN_TYPE')}, null={cc.get('IS_NULLABLE')})")
                lines.append("")
            if changed:
                lines.append("**Changed columns:**")
                lines.append("")
                lines.append("| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |")
                lines.append("|--------|------|------|------|---------|-----|-------|")
                for col, ac, bc in changed:
                    lines.append(
                        f"| `{col}` | Global FM | `{ac.get('COLUMN_TYPE')}` | {ac.get('IS_NULLABLE')} | `{ac.get('COLUMN_DEFAULT')}` | {ac.get('COLUMN_KEY') or ''} | {ac.get('EXTRA') or ''} |"
                    )
                    lines.append(
                        f"| `{col}` | JKR | `{bc.get('COLUMN_TYPE')}` | {bc.get('IS_NULLABLE')} | `{bc.get('COLUMN_DEFAULT')}` | {bc.get('COLUMN_KEY') or ''} | {bc.get('EXTRA') or ''} |"
                    )
                lines.append("")

    lines.append("## Index differences (common tables)")
    lines.append("")
    if not idx_details:
        lines.append("_No index differences on common tables._")
        lines.append("")
    else:
        for table, only_ai, only_bi, changed_i in idx_details:
            lines.append(f"### `{table}`")
            lines.append("")
            if only_ai:
                lines.append("**Indexes only in Global FM:** " + ", ".join(f"`{i}`" for i in only_ai))
            if only_bi:
                lines.append("**Indexes only in JKR:** " + ", ".join(f"`{i}`" for i in only_bi))
            if changed_i:
                lines.append("**Changed indexes:** " + ", ".join(f"`{i}`" for i in changed_i))
                for name in changed_i:
                    sa = index_sig(a_idx[(table, name)])
                    sb = index_sig(b_idx[(table, name)])
                    lines.append(f"- `{name}` Global FM: non_unique={sa[0]} type={sa[1]} cols={sa[2]}")
                    lines.append(f"- `{name}` JKR: non_unique={sb[0]} type={sb[1]} cols={sb[2]}")
            lines.append("")

    lines.append("## Foreign key differences (common tables)")
    lines.append("")
    if not fk_details:
        lines.append("_No foreign key differences on common tables._")
        lines.append("")
    else:
        for table, only_af, only_bf, changed_f in fk_details:
            lines.append(f"### `{table}`")
            lines.append("")
            if only_af:
                lines.append("**FKs only in Global FM:** " + ", ".join(f"`{i}`" for i in only_af))
            if only_bf:
                lines.append("**FKs only in JKR:** " + ", ".join(f"`{i}`" for i in only_bf))
            if changed_f:
                lines.append("**Changed FKs:** " + ", ".join(f"`{i}`" for i in changed_f))
                for name in changed_f:
                    sa = fk_sig(a_fk[(table, name)])
                    sb = fk_sig(b_fk[(table, name)])
                    lines.append(f"- `{name}` Global FM: {sa}")
                    lines.append(f"- `{name}` JKR: {sb}")
            lines.append("")

    lines.append("## Common tables with no structural column diffs")
    lines.append("")
    clean = [t for t in common if t not in tables_with_col_diff]
    lines.append(f"{len(clean)} / {len(common)} common tables have identical column sets/types (by compared fields).")
    lines.append("")

    return "\n".join(lines) + "\n"


def main() -> int:
    out_dir = Path(__file__).resolve().parent
    cache = out_dir / "_schema_diff_cache.json"
    report_path = out_dir / "SCHEMA_DIFF_GEMS2_VS_JKR.md"

    globalfm = fetch_side("globalfm", ENDPOINTS["globalfm"])
    jkr = fetch_side("jkr", ENDPOINTS["jkr"])

    cache.write_text(json.dumps({"globalfm": globalfm, "jkr": jkr}, indent=2), encoding="utf-8")
    print(f"Cached raw catalogs -> {cache}", flush=True)

    report = build_report(globalfm, jkr)
    report_path.write_text(report, encoding="utf-8")
    print(f"Wrote report -> {report_path}", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
