#!/usr/bin/env bash

set -euo pipefail

readonly AI_ROBOTICS_SKILL_NAME="ai-robotics-paper-to-research-zotero"
readonly AI_ROBOTICS_DEFAULT_REPO="MicroGrey/ai-robotics-paper-to-research-zotero"
readonly AI_ROBOTICS_REPO_SLUG="${AI_ROBOTICS_SKILL_REPO:-${AI_ROBOTICS_DEFAULT_REPO}}"
readonly AI_ROBOTICS_REPO_REF="${AI_ROBOTICS_SKILL_REF:-main}"
readonly AI_ROBOTICS_SKILLS_ROOT="${CODEX_SKILLS_DIR:-${HOME}/.agents/skills}"
readonly AI_ROBOTICS_TARGET_DIR="${AI_ROBOTICS_SKILLS_ROOT}/${AI_ROBOTICS_SKILL_NAME}"

ai_robotics_temp_dir=""
ai_robotics_stage_dir=""

cleanup() {
  if [[ -n "${ai_robotics_temp_dir}" && -d "${ai_robotics_temp_dir}" ]]; then
    rm -rf -- "${ai_robotics_temp_dir}"
  fi

  if [[ -n "${ai_robotics_stage_dir}" && -d "${ai_robotics_stage_dir}" ]]; then
    rm -rf -- "${ai_robotics_stage_dir}"
  fi
}

trap cleanup EXIT

ai_robotics_source_dir=""
ai_robotics_script_path="${BASH_SOURCE[0]:-}"

if [[ -n "${ai_robotics_script_path}" && -f "${ai_robotics_script_path}" ]]; then
  ai_robotics_script_dir="$(cd -- "$(dirname -- "${ai_robotics_script_path}")" && pwd)"
  if [[ -f "${ai_robotics_script_dir}/SKILL.md" ]]; then
    ai_robotics_source_dir="${ai_robotics_script_dir}"
  fi
fi

if [[ -z "${ai_robotics_source_dir}" ]]; then
  command -v curl >/dev/null 2>&1 || {
    echo "Error: curl is required for remote installation." >&2
    exit 1
  }
  command -v tar >/dev/null 2>&1 || {
    echo "Error: tar is required for remote installation." >&2
    exit 1
  }

  ai_robotics_temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/ai-robotics-skill.XXXXXX")"
  ai_robotics_archive="${ai_robotics_temp_dir}/source.tar.gz"
  ai_robotics_archive_url="https://github.com/${AI_ROBOTICS_REPO_SLUG}/archive/refs/heads/${AI_ROBOTICS_REPO_REF}.tar.gz"

  curl -fsSL "${ai_robotics_archive_url}" -o "${ai_robotics_archive}"
  tar -xzf "${ai_robotics_archive}" -C "${ai_robotics_temp_dir}"

  ai_robotics_source_dir="$(find "${ai_robotics_temp_dir}" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -exec dirname {} \; -quit)"
fi

if [[ -z "${ai_robotics_source_dir}" || ! -f "${ai_robotics_source_dir}/SKILL.md" ]]; then
  echo "Error: the downloaded repository does not contain SKILL.md at its root." >&2
  exit 1
fi

if ! grep -q "^name: ${AI_ROBOTICS_SKILL_NAME}$" "${ai_robotics_source_dir}/SKILL.md"; then
  echo "Error: SKILL.md has an unexpected skill name." >&2
  exit 1
fi

mkdir -p -- "${AI_ROBOTICS_SKILLS_ROOT}"
ai_robotics_stage_dir="$(mktemp -d "${AI_ROBOTICS_SKILLS_ROOT}/.${AI_ROBOTICS_SKILL_NAME}.install.XXXXXX")"

cp "${ai_robotics_source_dir}/SKILL.md" "${ai_robotics_stage_dir}/SKILL.md"

for ai_robotics_component in agents references scripts assets; do
  if [[ -d "${ai_robotics_source_dir}/${ai_robotics_component}" ]]; then
    cp -R "${ai_robotics_source_dir}/${ai_robotics_component}" "${ai_robotics_stage_dir}/${ai_robotics_component}"
  fi
done

if [[ -e "${AI_ROBOTICS_TARGET_DIR}" ]]; then
  rm -rf -- "${AI_ROBOTICS_TARGET_DIR}"
fi

mv "${ai_robotics_stage_dir}" "${AI_ROBOTICS_TARGET_DIR}"
ai_robotics_stage_dir=""

echo "Installed ${AI_ROBOTICS_SKILL_NAME} to ${AI_ROBOTICS_TARGET_DIR}"
echo "If Codex is already open and the skill does not appear, restart Codex."
echo "First-time Zotero MCP check prompt:"
echo '  paper2zotero 初始化'
