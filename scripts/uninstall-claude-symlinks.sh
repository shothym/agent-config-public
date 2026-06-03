#!/usr/bin/env bash
# Remove symlinks under ~/.claude/ that point into this repository only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR/.." rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
else
  REPO_ROOT="$(cd "$REPO_ROOT" && pwd -P)"
fi

DEST_SKILLS="${HOME}/.claude/skills"
DEST_AGENTS="${HOME}/.claude/agents"
DEST_CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
DEST_SETTINGS_JSON="${HOME}/.claude/settings.json"
DEST_USER_DEFINED="${HOME}/.claude/user-defined"

# Resolve a symlink's target into a canonical path. Falls back to readlink so a
# dangling link (its target was deleted from the repo) still resolves.
link_target_into_repo() {
  local link="$1"
  local resolved
  resolved="$(python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "${link}" 2>/dev/null || true)"
  if [[ -z "${resolved}" ]]; then
    resolved="$(cd "$(dirname "${link}")" && readlink "${link}")"
  fi
  case "${resolved}" in
    "${REPO_ROOT}" | "${REPO_ROOT}"/*) return 0 ;;
    *) return 1 ;;
  esac
}

# Scan a dest directory and remove every symlink that points into this repo,
# including dangling links for skills/agents that were deleted from the repo.
# Symlinks pointing elsewhere and real files are left untouched.
prune_dest() {
  local dest_dir="$1"
  local kind="$2"
  [[ -d "${dest_dir}" ]] || return 0
  shopt -s nullglob
  local link
  for link in "${dest_dir}"/*; do
    [[ -L "${link}" ]] || continue
    if link_target_into_repo "${link}"; then
      rm "${link}"
      echo "Removed ${kind} symlink: ${link}"
      removed=$((removed + 1))
    fi
  done
  shopt -u nullglob
}

removed=0
prune_dest "${DEST_SKILLS}" "skill"
prune_dest "${DEST_AGENTS}" "agent"

if [[ -L "${DEST_CLAUDE_MD}" ]] && link_target_into_repo "${DEST_CLAUDE_MD}"; then
  rm "${DEST_CLAUDE_MD}"
  echo "Removed CLAUDE.md symlink: ${DEST_CLAUDE_MD}"
  removed=$((removed + 1))
fi

if [[ -L "${DEST_SETTINGS_JSON}" ]] && link_target_into_repo "${DEST_SETTINGS_JSON}"; then
  rm "${DEST_SETTINGS_JSON}"
  echo "Removed settings.json symlink: ${DEST_SETTINGS_JSON}"
  removed=$((removed + 1))
fi

if [[ -L "${DEST_USER_DEFINED}" ]] && link_target_into_repo "${DEST_USER_DEFINED}"; then
  rm "${DEST_USER_DEFINED}"
  echo "Removed user-defined symlink: ${DEST_USER_DEFINED}"
  removed=$((removed + 1))
fi

echo "Done (${removed} removed)."
