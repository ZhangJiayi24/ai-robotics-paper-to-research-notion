#!/usr/bin/env bash

set -euo pipefail

readonly WEASYPRINT_VERSION="69.0"
readonly RUNTIME_ROOT="${PAPER2ZOTERO_RUNTIME_DIR:-${XDG_CACHE_HOME:-${HOME}/.cache}/paper2zotero/pdf-runtime}"
readonly CONFIG_ROOT="${PAPER2ZOTERO_CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/paper2zotero}"
readonly VENV_DIR="${RUNTIME_ROOT}/venv"
readonly RENDERER_FILE="${CONFIG_ROOT}/renderer"

with_native_library_path() {
  if [[ "$(uname -s)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    local prefix
    prefix="$(brew --prefix)"
    DYLD_FALLBACK_LIBRARY_PATH="${prefix}/lib${DYLD_FALLBACK_LIBRARY_PATH:+:${DYLD_FALLBACK_LIBRARY_PATH}}" "$@"
  else
    "$@"
  fi
}

weasyprint_command() {
  if command -v weasyprint >/dev/null 2>&1 && with_native_library_path weasyprint --info >/dev/null 2>&1; then
    command -v weasyprint
    return
  fi

  if [[ -x "${VENV_DIR}/bin/weasyprint" ]] && with_native_library_path "${VENV_DIR}/bin/weasyprint" --info >/dev/null 2>&1; then
    printf '%s\n' "${VENV_DIR}/bin/weasyprint"
    return
  fi

  return 1
}

check_poppler() {
  local missing=()
  local tool
  for tool in pdfinfo pdffonts pdftotext pdftoppm pdfimages; do
    command -v "${tool}" >/dev/null 2>&1 || missing+=("${tool}")
  done

  if (( ${#missing[@]} == 0 )); then
    printf '%s\n' "poppler=available"
  else
    printf '%s\n' "poppler=missing"
    printf 'poppler_missing=%s\n' "$(IFS=,; printf '%s' "${missing[*]}")"
  fi
}

check_cjk_fonts() {
  if ! command -v fc-list >/dev/null 2>&1; then
    printf '%s\n' "cjk_fonts=unknown"
    return
  fi

  local family
  family="$(fc-list :lang=zh -f '%{family[0]}\n' 2>/dev/null | awk 'NF { print; exit }')"
  if [[ -n "${family}" ]]; then
    printf '%s\n' "cjk_fonts=available"
    printf 'cjk_font_sample=%s\n' "${family}"
  else
    printf '%s\n' "cjk_fonts=missing"
  fi
}

check_runtime() {
  local renderer
  if renderer="$(weasyprint_command)"; then
    printf '%s\n' "weasyprint=available"
    printf 'weasyprint_version=%s\n' "$(with_native_library_path "${renderer}" --version | awk '{print $NF}')"
    if [[ "${renderer}" == "${VENV_DIR}/bin/weasyprint" ]]; then
      printf '%s\n' "weasyprint_mode=dedicated"
    else
      printf '%s\n' "weasyprint_mode=system"
    fi
  elif [[ -x "${VENV_DIR}/bin/weasyprint" ]]; then
    printf '%s\n' "weasyprint=native-dependency-missing"
  else
    printf '%s\n' "weasyprint=missing"
  fi

  check_poppler
  check_cjk_fonts
  printf 'renderer_preference=%s\n' "$(get_renderer)"
}

install_weasyprint() {
  command -v python3 >/dev/null 2>&1 || {
    echo "Error: Python 3.10 or newer is required." >&2
    exit 1
  }
  python3 -c 'import sys; raise SystemExit(sys.version_info < (3, 10))' || {
    echo "Error: Python 3.10 or newer is required." >&2
    exit 1
  }

  mkdir -p -- "${RUNTIME_ROOT}"
  if command -v uv >/dev/null 2>&1; then
    UV_CACHE_DIR="${RUNTIME_ROOT}/uv-cache" uv venv --clear --python python3 "${VENV_DIR}"
    UV_CACHE_DIR="${RUNTIME_ROOT}/uv-cache" uv pip install \
      --python "${VENV_DIR}/bin/python" \
      "weasyprint==${WEASYPRINT_VERSION}" pikepdf pillow
  else
    python3 -m venv --clear "${VENV_DIR}"
    "${VENV_DIR}/bin/python" -m pip install \
      "weasyprint==${WEASYPRINT_VERSION}" pikepdf pillow
  fi

  if ! with_native_library_path "${VENV_DIR}/bin/weasyprint" --info >/dev/null 2>&1; then
    echo "Error: WeasyPrint is installed, but required native libraries such as Pango are unavailable." >&2
    exit 1
  fi

  check_runtime
}

set_renderer() {
  case "${1:-}" in
    auto|weasyprint|codex-pdf) ;;
    *)
      echo "Error: renderer must be auto, weasyprint, or codex-pdf." >&2
      exit 2
      ;;
  esac
  mkdir -p -- "${CONFIG_ROOT}"
  printf '%s\n' "$1" > "${RENDERER_FILE}"
  printf 'renderer_preference=%s\n' "$1"
}

get_renderer() {
  if [[ -f "${RENDERER_FILE}" ]]; then
    case "$(cat "${RENDERER_FILE}")" in
      auto|weasyprint|codex-pdf) cat "${RENDERER_FILE}"; return ;;
    esac
  fi
  printf '%s\n' "auto"
}

render_weasyprint() {
  [[ $# -eq 2 ]] || {
    echo "Usage: pdf-runtime.sh render-weasyprint INPUT_HTML OUTPUT_PDF" >&2
    exit 2
  }
  local renderer
  renderer="$(weasyprint_command)" || {
    echo "Error: WeasyPrint is unavailable. Run paper2zotero initialization first." >&2
    exit 1
  }
  with_native_library_path "${renderer}" "$1" "$2"
}

case "${1:-check}" in
  check) check_runtime ;;
  install-weasyprint) install_weasyprint ;;
  set-renderer) shift; set_renderer "$@" ;;
  get-renderer) get_renderer ;;
  render-weasyprint) shift; render_weasyprint "$@" ;;
  *)
    echo "Usage: pdf-runtime.sh {check|install-weasyprint|set-renderer MODE|get-renderer|render-weasyprint INPUT OUTPUT}" >&2
    exit 2
    ;;
esac
