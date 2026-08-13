#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""AIX DV Common - 工具共享模块。

提供仓库根定位、YAML 安全加载、SV 符号扫描等公共能力，
供 tools/ 下各检查工具复用（schema_check / dep_check / api_diff / result_check / doc_gen）。
"""

import os
import re
import sys

# 仓库根（本文件位于 <root>/tools/common.py）
REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def repo_path(*parts):
    """返回相对于仓库根的路径。"""
    return os.path.join(REPO_ROOT, *parts)


def load_yaml(path):
    """加载 YAML 文件，失败时抛异常并附文件路径。"""
    import yaml
    with open(path, "r", encoding="utf-8") as fh:
        try:
            return yaml.safe_load(fh)
        except yaml.YAMLError as exc:
            raise ValueError(f"YAML parse error in {path}: {exc}")


def walk_sv_files(roots=("src", "rtl", "unit", "examples", "tests")):
    """遍历仓库内所有 .sv 文件，返回相对仓库根的路径列表。"""
    out = []
    for root in roots:
        base = repo_path(root)
        if not os.path.isdir(base):
            continue
        for dirpath, _dirs, files in os.walk(base):
            for f in sorted(files):
                if f.endswith(".sv"):
                    out.append(os.path.relpath(os.path.join(dirpath, f), REPO_ROOT))
    return sorted(out)


# ---------------------------------------------------------------------------
# SV 符号扫描（供 api_diff / doc_gen 使用）
# ---------------------------------------------------------------------------

# 匹配 package 声明
PKG_RE = re.compile(r"^\s*package\s+(\w+)\s*;", re.M)
# 匹配 class 声明（含 virtual class）
CLASS_RE = re.compile(r"^\s*(?:virtual\s+)?class\s+(\w+)\s+extends\s+\w+\s*;", re.M)
# 匹配 function/task 声明（含 static/automatic/虚函数，名称后接 "(" 或 ";"）
FUNC_RE = re.compile(
    r"^\s*(?:virtual\s+)?(?:static\s+)?(?:function|task)\s+"
    r"(?:\w+\s+)*?(\w+)\s*(?:\(|;|$)",
    re.M,
)
# 匹配 enum typedef 名
ENUM_RE = re.compile(r"^\s*typedef\s+enum.*?(\w+)\s*;", re.M | re.S)
# 匹配 typedef struct/class 名
TYPEDEF_RE = re.compile(r"^\s*typedef\s+(?:struct|union|class|logic|bit|int|longint|real|string)\b"
                        r"[^;{}]*?\b(\w+)\s*;", re.M | re.S)


def scan_public_symbols(sv_text):
    """从 SV 源码文本提取公共符号集合。

    返回 dict: {"packages": [...], "classes": [...], "functions": [...],
                "tasks": [...], "typedefs": [...], "enums": [...]}
    """
    syms = {
        "packages": sorted(set(PKG_RE.findall(sv_text))),
        "classes": sorted(set(CLASS_RE.findall(sv_text))),
        "functions": [],
        "tasks": [],
        "typedefs": sorted(set(TYPEDEF_RE.findall(sv_text))),
        "enums": sorted(set(ENUM_RE.findall(sv_text))),
    }
    for m in FUNC_RE.finditer(sv_text):
        # 判断是 function 还是 task（看匹配行）
        line = sv_text[: m.start()].rstrip()
        kind = "functions" if line.rfind("function") > line.rfind("task") else "tasks"
        syms[kind].append(m.group(1))
    syms["functions"] = sorted(set(syms["functions"]))
    syms["tasks"] = sorted(set(syms["tasks"]))
    return syms


def extract_header(sv_text):
    """提取文件头注释（第一个注释块），用于 doc_gen。"""
    m = re.match(r"\s*(//[^\n]*\n(?:\s*//[^\n]*\n)*)", sv_text)
    return m.group(1).strip() if m else ""


def report(ok, msg):
    """统一输出：PASS/FAIL。"""
    tag = "PASS" if ok else "FAIL"
    print(f"[{tag}] {msg}")
    return ok


def main_or_fail(func):
    """包装入口：异常时以退出码 1 结束。"""
    try:
        ok = func()
        sys.exit(0 if ok else 1)
    except Exception as exc:  # noqa: BLE001
        print(f"[ERROR] {exc}")
        sys.exit(1)
