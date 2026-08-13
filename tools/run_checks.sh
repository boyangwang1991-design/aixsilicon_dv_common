#!/usr/bin/env bash
# AIX DV Common - 本地检查入口（对应 PR 流水线 1~3 步）
# 用法: bash tools/run_checks.sh
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

echo "== [1/3] schema_check =="
python3 "$ROOT/tools/schema_check/check_schema.py" || FAIL=1

echo
echo "== [2/3] dep_check =="
python3 "$ROOT/tools/dep_check/check_deps.py" || FAIL=1

echo
echo "== [3/3] api_diff (HEAD~1..HEAD) =="
python3 "$ROOT/tools/api_diff/api_diff.py" || FAIL=1

echo
if [ "$FAIL" -eq 0 ]; then
  echo "ALL CHECKS PASSED"
else
  echo "SOME CHECKS FAILED"
fi
exit "$FAIL"
