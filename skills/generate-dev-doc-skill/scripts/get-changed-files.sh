#!/usr/bin/env sh
# 输出变更文件列表：非 master 时用 git diff master...HEAD，否则用 git status --porcelain
# 用法: get-changed-files.sh [工作区路径]
# 输出: 每行 "STATUS\tPATH"（STATUS 为 A/M/D 或 porcelain 两字符）

WORKSPACE="${1:-.}"
cd "$WORKSPACE" 2>/dev/null || exit 1

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -z "$BRANCH" ]; then
  echo "ERROR: not a git repo or no branch" >&2
  exit 1
fi

if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
  git status --porcelain 2>/dev/null | while read -r line; do
    [ -z "$line" ] && continue
    STATUS=$(echo "$line" | cut -c1-2)
    PATH_PART=$(echo "$line" | cut -c4-)
    printf "%s\t%s\n" "$STATUS" "$PATH_PART"
  done
else
  git diff --name-status master...HEAD 2>/dev/null | while read -r line; do
    [ -z "$line" ] && continue
    STATUS="${line%%	*}"
    PATH_PART="${line#*	}"
    printf "%s\t%s\n" "$STATUS" "$PATH_PART"
  done
fi
