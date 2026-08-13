#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""tools/schema_check - 校验 schemas/ 与 metadata/ 的合法性与一致性。

检查项（对应 plan.md 第 16.1 节 PR 流水线第 1 步）：
  1. 所有 schemas/*.yaml 与 metadata/*.yaml 可被 YAML 解析；
  2. schemas/*.yaml 是合法 JSON-Schema（含 $schema / title / type）；
  3. metadata/message_ids.yaml 中 Message ID 遵循 AIX_DV_<DOMAIN>_<EVENT>；
  4. metadata/components.yaml 条目含必填字段（name/vlnv/category/owner/maturity）。

用法：
  python3 tools/schema_check/check_schema.py
  python3 tools/schema_check/check_schema.py schemas/run_config.schema.yaml   # 校验单个文件
"""

import os
import re
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from common import repo_path, load_yaml, report, main_or_fail  # noqa: E402

MESSAGE_ID_RE = re.compile(r"^AIX_DV_[A-Z0-9_]+_[A-Z0-9_]+$")

COMPONENT_REQUIRED = ["name", "vlnv", "category", "owner", "maturity"]
CATEGORY_ENUM = {
    "types", "utility", "runtime_service", "reusable_component",
    "uvm_framework", "ral", "adapter",
}
MATURITY_ENUM = {"draft", "experimental", "candidate", "qualified", "deprecated", "retired"}


def _check_yaml(path):
    try:
        load_yaml(path)
    except ValueError as exc:
        return report(False, f"YAML parse: {path} ({exc})")
    return report(True, f"YAML parse: {path}")


def _check_schema(path):
    try:
        data = load_yaml(path)
    except ValueError as exc:
        return report(False, f"schema {path}: {exc}")
    ok = True
    if "$schema" not in data:
        ok = report(False, f"schema {path}: missing '$schema'")
    if "title" not in data:
        ok = report(False, f"schema {path}: missing 'title'")
    if "type" not in data:
        ok = report(False, f"schema {path}: missing 'type'")
    if ok:
        report(True, f"schema: {path}")
    return ok


def _check_message_ids(path):
    try:
        data = load_yaml(path)
    except ValueError as exc:
        return report(False, f"message_ids {path}: {exc}")
    ids = data.get("message_ids", [])
    ok = True
    seen = set()
    for entry in ids:
        mid = entry.get("id")
        if not mid:
            ok = report(False, f"message_ids: entry missing 'id'")
            continue
        if mid in seen:
            ok = report(False, f"message_ids: duplicate id {mid}")
        seen.add(mid)
        if not MESSAGE_ID_RE.match(mid):
            ok = report(False, f"message_ids: invalid format {mid!r} (expect AIX_DV_<DOMAIN>_<EVENT>)")
        if "domain" not in entry:
            ok = report(False, f"message_ids: {mid} missing 'domain'")
    if ok:
        report(True, f"message_ids: {path} ({len(ids)} ids)")
    return ok


def _check_components(path):
    try:
        data = load_yaml(path)
    except ValueError as exc:
        return report(False, f"components {path}: {exc}")
    comps = data.get("components", [])
    ok = True
    name_seen = set()
    for c in comps:
        name = c.get("name", "<unnamed>")
        for field in COMPONENT_REQUIRED:
            if field not in c:
                ok = report(False, f"components: {name} missing '{field}'")
        if c.get("category") not in CATEGORY_ENUM:
            ok = report(False, f"components: {name} invalid category {c.get('category')!r}")
        if c.get("maturity") not in MATURITY_ENUM:
            ok = report(False, f"components: {name} invalid maturity {c.get('maturity')!r}")
        if name in name_seen:
            ok = report(False, f"components: duplicate component name {name!r}")
        name_seen.add(name)
    if ok:
        report(True, f"components: {path} ({len(comps)} entries)")
    return ok


def run():
    ok = True

    if len(sys.argv) > 1:
        target = sys.argv[1]
        if not os.path.isabs(target):
            target = os.path.abspath(target)
        ok &= _check_yaml(target)
        if os.path.basename(target).endswith(".schema.yaml"):
            ok &= _check_schema(target)
        return ok

    schema_dir = repo_path("schemas")
    meta_dir = repo_path("metadata")

    for f in sorted(os.listdir(schema_dir)):
        if f.endswith(".yaml"):
            p = os.path.join(schema_dir, f)
            ok &= _check_yaml(p)
            ok &= _check_schema(p)

    for f in sorted(os.listdir(meta_dir)):
        if not f.endswith(".yaml"):
            continue
        p = os.path.join(meta_dir, f)
        ok &= _check_yaml(p)
        if f == "message_ids.yaml":
            ok &= _check_message_ids(p)
        elif f == "components.yaml":
            ok &= _check_components(p)

    report(ok, "schema_check completed")
    return ok


if __name__ == "__main__":
    main_or_fail(run)
