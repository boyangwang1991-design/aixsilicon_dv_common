#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""tools/result_check - 结果自校验（Gate G7 证据校验）。

校验 test_result / run_manifest 是否符合 schemas/ 定义的结构约束：
  - test_result：schema_version/test/run 必填；status 与 exit_code 枚举合法；
  - run_manifest：schema_version 必填；关键字段类型合法。

用法：
  python3 tools/result_check/check_result.py <result.yaml> [--manifest]
"""

import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from common import load_yaml, report, main_or_fail  # noqa: E402

STATUS_ENUM = {"PASS", "FAIL", "SKIP", "ABORT"}
EXIT_ENUM = {0, 1, 2, 3, 4, 5, 6, 7, 8}
SCHEMA_VERSIONS = {"1.0"}
UVM_PROFILES = {"uvm12_legacy", "uvm1800_2"}


def _check_test_result(data):
    ok = True
    if data.get("schema_version") not in SCHEMA_VERSIONS:
        ok = report(False, f"test_result: invalid schema_version {data.get('schema_version')!r}")
    test = data.get("test")
    if not isinstance(test, dict) or "name" not in test:
        ok = report(False, "test_result: missing test.name")
    run = data.get("run")
    if not isinstance(run, dict):
        ok = report(False, "test_result: missing run")
    else:
        if "id" not in run:
            ok = report(False, "test_result: missing run.id")
        if "seed" not in run:
            ok = report(False, "test_result: missing run.seed")
        if run.get("status") not in STATUS_ENUM:
            ok = report(False, f"test_result: invalid run.status {run.get('status')!r}")
        if run.get("exit_code") not in EXIT_ENUM:
            ok = report(False, f"test_result: invalid run.exit_code {run.get('exit_code')!r}")
    return ok


def _check_manifest(data):
    ok = True
    if data.get("schema_version") not in SCHEMA_VERSIONS:
        ok = report(False, f"manifest: invalid schema_version {data.get('schema_version')!r}")
    uvm = data.get("uvm_profile")
    if uvm is not None and uvm not in UVM_PROFILES:
        ok = report(False, f"manifest: invalid uvm_profile {uvm!r}")
    if "seed" in data and not isinstance(data["seed"], int):
        ok = report(False, f"manifest: seed must be int, got {type(data['seed']).__name__}")
    return ok


def run():
    if len(sys.argv) < 2:
        print("usage: python3 tools/result_check/check_result.py <result.yaml> [--manifest]")
        return False
    path = sys.argv[1]
    manifest = "--manifest" in sys.argv
    try:
        data = load_yaml(path)
    except ValueError as exc:
        return report(False, f"load {path}: {exc}")

    ok = _check_manifest(data) if manifest else _check_test_result(data)
    report(ok, f"result_check: {path} ({'manifest' if manifest else 'test_result'})")
    return ok


if __name__ == "__main__":
    main_or_fail(run)
