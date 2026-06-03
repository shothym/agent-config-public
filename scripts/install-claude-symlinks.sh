#!/usr/bin/env bash
# Install symlinks from this repo into ~/.claude/skills/ and ~/.claude/agents/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR/.." rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
else
  REPO_ROOT="$(cd "$REPO_ROOT" && pwd -P)"
fi

SRC_SKILLS="${REPO_ROOT}/.claude/skills"
SRC_AGENTS="${REPO_ROOT}/.claude/agents"
SRC_CLAUDE_MD="${REPO_ROOT}/.claude/CLAUDE.md"
SRC_SETTINGS_JSON="${REPO_ROOT}/.claude/settings.json"
SRC_USER_DEFINED="${REPO_ROOT}/.claude/user-defined"
DEST_SKILLS="${HOME}/.claude/skills"
DEST_AGENTS="${HOME}/.claude/agents"
DEST_CLAUDE_MD="${HOME}/.claude/CLAUDE.md"
DEST_SETTINGS_JSON="${HOME}/.claude/settings.json"
DEST_USER_DEFINED="${HOME}/.claude/user-defined"

mkdir -p "${DEST_SKILLS}" "${DEST_AGENTS}"

# Remove all repo-managed symlinks first, then regenerate from scratch so links
# for skills/agents deleted from the repo do not linger as dangling symlinks.
"${SCRIPT_DIR}/uninstall-claude-symlinks.sh"

abort=false

ensure_target_is_symlink_or_absent() {
  local target="$1"
  local kind="$2"
  if [[ -e "${target}" || -L "${target}" ]]; then
    if [[ -L "${target}" ]]; then
      return 0
    fi
    echo "Error: ${kind} target exists and is not a symlink (refusing to overwrite): ${target}" >&2
    return 1
  fi
  return 0
}

# Skills: link each subdirectory of .claude/skills that contains SKILL.md
if [[ -d "${SRC_SKILLS}" ]]; then
  shopt -s nullglob
  for dir in "${SRC_SKILLS}"/*/; do
    [[ -d "${dir}" ]] || continue
    [[ -f "${dir}/SKILL.md" ]] || continue
    name="$(basename "${dir}")"
    target="${DEST_SKILLS}/${name}"
    src="$(cd "${dir}" && pwd -P)"
    if ! ensure_target_is_symlink_or_absent "${target}" "skill"; then
      abort=true
      continue
    fi
    ln -sfn "${src}" "${target}"
    echo "Linked skill: ${target} -> ${src}"
  done
  shopt -u nullglob
fi

# Agents: link each *.md except README.md
if [[ -d "${SRC_AGENTS}" ]]; then
  shopt -s nullglob
  for f in "${SRC_AGENTS}"/*.md; do
    base="$(basename "${f}")"
    [[ "${base}" == "README.md" ]] && continue
    target="${DEST_AGENTS}/${base}"
    src="$(cd "$(dirname "${f}")" && pwd -P)/$(basename "${f}")"
    if ! ensure_target_is_symlink_or_absent "${target}" "agent"; then
      abort=true
      continue
    fi
    ln -sfn "${src}" "${target}"
    echo "Linked agent: ${target} -> ${src}"
  done
  shopt -u nullglob
fi

# CLAUDE.md: link the repo's .claude/CLAUDE.md to ~/.claude/CLAUDE.md
if [[ -f "${SRC_CLAUDE_MD}" ]]; then
  src="$(cd "$(dirname "${SRC_CLAUDE_MD}")" && pwd -P)/$(basename "${SRC_CLAUDE_MD}")"
  if ensure_target_is_symlink_or_absent "${DEST_CLAUDE_MD}" "CLAUDE.md"; then
    ln -sfn "${src}" "${DEST_CLAUDE_MD}"
    echo "Linked CLAUDE.md: ${DEST_CLAUDE_MD} -> ${src}"
  else
    abort=true
  fi
fi

# settings.json: link the repo's .claude/settings.json to ~/.claude/settings.json
if [[ -f "${SRC_SETTINGS_JSON}" ]]; then
  src="$(cd "$(dirname "${SRC_SETTINGS_JSON}")" && pwd -P)/$(basename "${SRC_SETTINGS_JSON}")"
  if ensure_target_is_symlink_or_absent "${DEST_SETTINGS_JSON}" "settings.json"; then
    ln -sfn "${src}" "${DEST_SETTINGS_JSON}"
    echo "Linked settings.json: ${DEST_SETTINGS_JSON} -> ${src}"
  else
    abort=true
  fi
fi

# user-defined/: link the repo's .claude/user-defined directory to ~/.claude/user-defined
if [[ -d "${SRC_USER_DEFINED}" ]]; then
  src="$(cd "${SRC_USER_DEFINED}" && pwd -P)"
  if ensure_target_is_symlink_or_absent "${DEST_USER_DEFINED}" "user-defined"; then
    ln -sfn "${src}" "${DEST_USER_DEFINED}"
    echo "Linked user-defined: ${DEST_USER_DEFINED} -> ${src}"
  else
    abort=true
  fi
fi

if [[ "${abort}" == true ]]; then
  echo "Install finished with errors (see above)." >&2
  exit 1
fi

echo "Done."
