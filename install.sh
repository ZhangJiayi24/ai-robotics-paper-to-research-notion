#!/usr/bin/env bash

set -euo pipefail

readonly AI_ROBOTICS_BACKEND="${1:-notion}"
readonly AI_ROBOTICS_DEFAULT_REPO="ZhangJiayi24/ai-robotics-paper-to-research-notion"
readonly AI_ROBOTICS_REPO_SLUG="${AI_ROBOTICS_SKILL_REPO:-${AI_ROBOTICS_DEFAULT_REPO}}"
readonly AI_ROBOTICS_REPO_REF="${AI_ROBOTICS_SKILL_REF:-main}"
readonly AI_ROBOTICS_SKILLS_ROOT="${CODEX_SKILLS_DIR:-${HOME}/.agents/skills}"

case "${AI_ROBOTICS_BACKEND}" in
  notion|zotero|all) ;;
  *)
    echo "Usage: bash install.sh [notion|zotero|all]" >&2
    exit 1
    ;;
esac

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

ai_robotics_repo_dir=""
ai_robotics_script_path="${BASH_SOURCE[0]:-}"

if [[ -n "${ai_robotics_script_path}" && -f "${ai_robotics_script_path}" ]]; then
  ai_robotics_script_dir="$(cd -- "$(dirname -- "${ai_robotics_script_path}")" && pwd)"
  if [[ -f "${ai_robotics_script_dir}/SKILL.md" ]]; then
    ai_robotics_repo_dir="${ai_robotics_script_dir}"
  fi
fi

if [[ -z "${ai_robotics_repo_dir}" ]]; then
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

  ai_robotics_repo_dir="$(find "${ai_robotics_temp_dir}" -mindepth 1 -maxdepth 1 -type d -print -quit)"
fi

if [[ -z "${ai_robotics_repo_dir}" || ! -f "${ai_robotics_repo_dir}/SKILL.md" ]]; then
  echo "Error: the downloaded repository does not contain the Notion skill at its root." >&2
  exit 1
fi

install_backend() {
  local backend="$1"
  local skill_name=""
  local source_dir=""
  local setup_label=""

  case "${backend}" in
    notion)
      skill_name="ai-robotics-paper-to-research-notion"
      source_dir="${ai_robotics_repo_dir}"
      setup_label="paper2notion 初始化"
      ;;
    zotero)
      skill_name="ai-robotics-paper-to-research-zotero"
      source_dir="${ai_robotics_repo_dir}/zotero"
      setup_label="paper2zotero 初始化"
      ;;
  esac

  if [[ ! -f "${source_dir}/SKILL.md" ]]; then
    echo "Error: the repository does not contain the ${backend} skill." >&2
    exit 1
  fi

  if ! grep -q "^name: ${skill_name}$" "${source_dir}/SKILL.md"; then
    echo "Error: ${source_dir}/SKILL.md has an unexpected skill name." >&2
    exit 1
  fi

  mkdir -p -- "${AI_ROBOTICS_SKILLS_ROOT}"
  ai_robotics_stage_dir="$(mktemp -d "${AI_ROBOTICS_SKILLS_ROOT}/.${skill_name}.install.XXXXXX")"

  cp "${source_dir}/SKILL.md" "${ai_robotics_stage_dir}/SKILL.md"

  for ai_robotics_component in agents references scripts assets; do
    if [[ -d "${source_dir}/${ai_robotics_component}" ]]; then
      cp -R "${source_dir}/${ai_robotics_component}" "${ai_robotics_stage_dir}/${ai_robotics_component}"
    fi
  done

  local target_dir="${AI_ROBOTICS_SKILLS_ROOT}/${skill_name}"
  if [[ -e "${target_dir}" ]]; then
    rm -rf -- "${target_dir}"
  fi

  mv "${ai_robotics_stage_dir}" "${target_dir}"
  ai_robotics_stage_dir=""

  echo "Installed ${skill_name} to ${target_dir}"
  echo "First-time setup prompt: ${setup_label}"
}

case "${AI_ROBOTICS_BACKEND}" in
  notion) install_backend notion ;;
  zotero) install_backend zotero ;;
  all)
    install_backend notion
    install_backend zotero
    ;;
esac

echo "If Codex is already open and the skill does not appear, restart Codex."
