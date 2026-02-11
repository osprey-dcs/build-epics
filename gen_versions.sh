#!/bin/sh
set -eu

OUT="${1:-VERSIONS.txt}"

{
  echo "# Submodule versions (tag if exact, otherwise closest tag) — generated $(date -Iseconds)"
  echo
  printf "%-44s %-32s %s\n" "module" "tag" "commit"
  echo "------------------------------------------------------------------------------------------------"

  git submodule foreach --quiet --recursive '
    # Skip CI submodules anywhere in the path
    case "$path" in
      *.ci|*.ci/*|*/.ci|*/.ci/*) exit 0 ;;
    esac

    # depth = number of "/" in path
    depth=$(printf "%s" "$path" | awk -F"/" "{print NF-1}")

    # indent_level = max(depth-1, 0)
    indent_level=$depth
    if [ "$indent_level" -gt 0 ]; then
      indent_level=$((indent_level-1))
    fi

    indent=""
    i=0
    while [ "$i" -lt "$indent_level" ]; do
      indent="${indent}  "   # two spaces per level
      i=$((i+1))
    done

    tag=$(git describe --tags --exact-match 2>/dev/null || git describe --tags --always 2>/dev/null || echo "unknown")
    sha=$(git rev-parse --short=12 HEAD)

    printf "%s%-44s %-32s %s\n" "$indent" "$path" "$tag" "$sha"
  '
} > "$OUT"
