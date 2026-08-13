#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""tools/dep_check - 依赖方向与循环检查（Gate G1）。

检查项：
  1. 解析 fusesoc/*.core 的 fileset 级 depend，构建 VLNV 依赖图；
  2. 检测依赖环（DFS）；
  3. 校验依赖方向：底层 package 不得反向依赖聚合 package；
  4. 校验公共库不得依赖 VIP / IP / SoC / project 类 VLNV；
  5. 校验 Core 引用的源文件存在。

用法：
  python3 tools/dep_check/check_deps.py
"""

import os
import re
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from common import repo_path, load_yaml, report, main_or_fail  # noqa: E402

FORBIDDEN_PREFIX = ("axi-", "apb-", "uart-", "spi-", "i2c-", "soc_", "soc-", "ip_", "project")
AGGREGATE_NAMES = {"aix:dv:common_all"}
OWN_PREFIX = "aix:dv:"


def canon(vlnv):
    """将 VLNV 规整为 V:L:N 三段的规范键（去掉版本约束）。"""
    parts = re.split(r"[:\^~<>=]", vlnv)
    # 去掉空段与版本号；保留前 3 段（vendor:library:name）
    clean = [p for p in parts if p]
    if len(clean) >= 3 and re.match(r"^\d", clean[2]):
        # 形如 V:L:1.0 或 V:L:^1.0 的情况
        clean = clean[:2]
    return ":".join(clean[:3])


def parse_cores():
    """返回 {canon_vlnv: {"file": path, "deps": [canon_vlnv...]}}。"""
    core_dir = repo_path("fusesoc")
    cores = {}
    for f in sorted(os.listdir(core_dir)):
        if not f.endswith(".core"):
            continue
        path = os.path.join(core_dir, f)
        try:
            data = load_yaml(path)
        except ValueError as exc:
            report(False, f"core parse: {f} ({exc})")
            continue
        name = data.get("name")
        if not name:
            report(False, f"core: {f} missing 'name'")
            continue
        deps = set()
        for fs in (data.get("filesets") or {}).values():
            for d in (fs.get("depend") or []):
                deps.add(canon(d))
        cores[canon(name)] = {"file": f, "deps": sorted(deps)}
    return cores


def _check_cycles(cores):
    """DFS 检测依赖环。返回 (ok, cycles)。"""
    state = {}  # 0=未访问, 1=在栈, 2=完成
    cycles = []

    def dfs(v, stack):
        state[v] = 1
        stack.append(v)
        for dep in cores[v]["deps"]:
            if dep not in cores:
                continue  # 外部依赖，跳过环检测
            if state.get(dep, 0) == 1:
                idx = stack.index(dep)
                cycles.append(stack[idx:] + [dep])
            elif state.get(dep, 0) == 0:
                dfs(dep, stack)
        stack.pop()
        state[v] = 2

    for v in cores:
        if state.get(v, 0) == 0:
            dfs(v, [])
    return len(cycles) == 0, cycles


def _check_direction(cores):
    """底层 package 不得反向依赖聚合 package。"""
    ok = True
    for vlnv, info in cores.items():
        for dep in info["deps"]:
            if dep in AGGREGATE_NAMES and vlnv not in AGGREGATE_NAMES:
                ok = report(False, f"reverse-depend: {vlnv} -> {dep}")
    return ok


def _check_forbidden(cores):
    """公共库不得依赖 VIP/IP/SoC/Project。"""
    ok = True
    for vlnv, info in cores.items():
        for dep in info["deps"]:
            lower = dep.lower()
            if lower.startswith(OWN_PREFIX):
                continue
            if any(lower.startswith(p) for p in FORBIDDEN_PREFIX):
                ok = report(False, f"forbidden-depend: {vlnv} -> {dep}")
    return ok


def _check_files_exist(cores):
    """Core 引用的源文件必须存在。"""
    ok = True
    core_dir = repo_path("fusesoc")
    for vlnv, info in cores.items():
        path = os.path.join(core_dir, info["file"])
        data = load_yaml(path)
        for fs in (data.get("filesets") or {}).values():
            for rel in (fs.get("files") or []):
                if "{" in str(rel):
                    continue
                full = os.path.normpath(os.path.join(core_dir, str(rel)))
                if not os.path.exists(full):
                    ok = report(False, f"missing file: {vlnv} references {rel}")
    return ok


def run():
    cores = parse_cores()
    ok = True
    report(len(cores) > 0, f"parsed {len(cores)} cores from fusesoc/")

    acyclic, cycles = _check_cycles(cores)
    if not acyclic:
        ok = False
        for c in cycles:
            report(False, f"dependency cycle: {' -> '.join(c)}")
    else:
        report(True, "dependency graph is acyclic")

    ok &= _check_direction(cores)
    ok &= _check_forbidden(cores)
    ok &= _check_files_exist(cores)

    report(ok, "dep_check completed")
    return ok


if __name__ == "__main__":
    main_or_fail(run)
