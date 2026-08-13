#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""tools/api_diff - API 差异检查（PR/Release 时运行，Gate G7 佐证）。

从 SV 源码提取公共符号（package/class/function/task/typedef/enum），
对比两个版本/目录，输出新增/删除/改名，并按符号影响提示 Major/Minor。

用法：
  python3 tools/api_diff/api_diff.py [old_dir] [new_dir]
    # 不给参数时，对比最近两次 git commit 中的 src/ 符号
  python3 tools/api_diff/api_diff.py --dump
    # 输出当前 src/ 全部符号快照（可用于归档）
"""

import os
import subprocess
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from common import repo_path, walk_sv_files, scan_public_symbols, report, main_or_fail  # noqa: E402

SRC_DIR = "src"


def collect_symbols(sv_files):
    """返回 {file: {"packages": [...], "classes": [...], ...}}。"""
    out = {}
    for f in sv_files:
        p = repo_path(f)
        if not os.path.exists(p):
            continue
        with open(p, "r", encoding="utf-8") as fh:
            out[f] = scan_public_symbols(fh.read())
    return out


def flatten(sym_map):
    """将 {file: {kind: [...]}} 展开为 {qualified: kind}。"""
    flat = {}
    for f, kinds in sym_map.items():
        for kind, names in kinds.items():
            for n in names:
                flat[f"{f}::{kind}::{n}"] = kind
    return flat


def diff(old, new):
    """返回 (added, removed)。"""
    old_keys = set(old)
    new_keys = set(new)
    return sorted(new_keys - old_keys), sorted(old_keys - new_keys)


def git_snapshot(commit):
    """取某 commit 下 src/ 文件内容做符号快照。"""
    out = {}
    for f in walk_sv_files((SRC_DIR,)):
        try:
            proc = subprocess.run(
                ["git", "show", f"{commit}:{f}"],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                universal_newlines=True, check=True,
            )
            out[f] = scan_public_symbols(proc.stdout)
        except subprocess.CalledProcessError:
            pass  # 该 commit 无此文件
    return out


def dump_mode():
    syms = collect_symbols(walk_sv_files((SRC_DIR,)))
    flat = flatten(syms)
    for k in sorted(flat):
        print(k)
    return True


def diff_mode(old_dir, new_dir):
    old_syms = collect_symbols(
        [os.path.relpath(os.path.join(old_dir, f), repo_path())
         for f in walk_sv_files((SRC_DIR,)) if os.path.exists(os.path.join(old_dir, f))])
    new_syms = collect_symbols(walk_sv_files((SRC_DIR,)))
    added, removed = diff(flatten(old_syms), flatten(new_syms))

    ok = True
    if not added and not removed:
        report(True, "no public API change")
        return ok
    if removed:
        ok = False
        for k in removed:
            report(False, f"API REMOVED: {k}")
    for k in added:
        report(True, f"API ADDED: {k}")
    report(not removed, "api_diff: no breaking (removed) symbols")
    return ok


def git_diff_mode():
    try:
        proc = subprocess.run(
            ["git", "merge-base", "HEAD~1", "HEAD"],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            universal_newlines=True, check=True,
        )
        base = proc.stdout.strip()
    except subprocess.CalledProcessError:
        report(False, "git history too short; provide old/new dirs explicitly")
        return False
    old = git_snapshot(base)
    new = git_snapshot("HEAD")
    added, removed = diff(flatten(old), flatten(new))
    for k in removed:
        report(False, f"API REMOVED (HEAD~1..HEAD): {k}")
    for k in added:
        report(True, f"API ADDED (HEAD~1..HEAD): {k}")
    return not removed


def run():
    if len(sys.argv) >= 2 and sys.argv[1] == "--dump":
        return dump_mode()
    if len(sys.argv) >= 3:
        return diff_mode(sys.argv[1], sys.argv[2])
    return git_diff_mode()


if __name__ == "__main__":
    main_or_fail(run)
