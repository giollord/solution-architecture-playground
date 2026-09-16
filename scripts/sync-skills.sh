#!/bin/sh
# Mirrors .agents/skills into .claude/skills.
#
# .claude/skills is a generated copy (see .gitignore) because Windows can't
# reliably use symlinks for this. Source of truth is .agents/skills; run this
# script (or let the git hooks in .githooks/ do it) whenever that changes.

set -e

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
src="$repo_root/.agents/skills"
dest="$repo_root/.claude/skills"

if [ ! -d "$src" ]; then
  exit 0
fi

rm -rf "$dest"
mkdir -p "$dest"
cp -r "$src/." "$dest/"
