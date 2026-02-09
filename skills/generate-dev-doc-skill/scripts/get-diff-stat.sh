#!/usr/bin/env sh
# 对传入的文件路径输出 git diff --numstat（增删行数）
# 用法: get-diff-stat.sh [工作区路径]；文件路径从 stdin 每行一个，或作为剩余参数传入
# 输出: 每行 "PATH\t+INS\t-DEL"

WORKSPACE="${1:-.}"
cd "$WORKSPACE" 2>/dev/null || exit 1

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -z "$BRANCH" ]; then
  echo "ERROR: not a git repo" >&2
  exit 1
fi

if [ -d "$1" ] 2>/dev/null; then
  WORKSPACE="$1"
  shift
  cd "$WORKSPACE" 2>/dev/null || exit 1
fi

FILES=""
if [ -n "$*" ]; then
  FILES="$*"
else
  while read -r path; do
    [ -z "$path" ] && continue
    FILES="${FILES:+$FILES }$path"
  done
fi

for FILE in $FILES; do
  [ -z "$FILE" ] && continue
  if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
    LINE=$(git diff --numstat -- "$FILE" 2>/dev/null)
  else
    LINE=$(git diff --numstat master...HEAD -- "$FILE" 2>/dev/null)
  fi
  INS=0
  DEL=0
  if [ -n "$LINE" ]; then
    INS=$(echo "$LINE" | awk '{print $1}')
    DEL=$(echo "$LINE" | awk '{print $2}')
    [ "$INS" = "-" ] && INS=0
    [ "$DEL" = "-" ] && DEL=0
  fi
  printf "%s\t+%s\t-%s\n" "$FILE" "${INS:-0}" "${DEL:-0}"
done
