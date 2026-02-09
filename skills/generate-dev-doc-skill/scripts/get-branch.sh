#!/usr/bin/env sh
# 输出当前 Git 分支名
# 用法: get-branch.sh [工作区路径]

WORKSPACE="${1:-.}"
cd "$WORKSPACE" 2>/dev/null || exit 1
git rev-parse --abbrev-ref HEAD 2>/dev/null || exit 1
