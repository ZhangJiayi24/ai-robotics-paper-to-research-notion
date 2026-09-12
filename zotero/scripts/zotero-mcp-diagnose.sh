#!/usr/bin/env bash

set -u

readonly CODEX_BIN="${CODEX_BIN:-codex}"
readonly CURL_BIN="${CURL_BIN:-curl}"
readonly LSOF_BIN="${LSOF_BIN:-lsof}"
readonly PYTHON_BIN="${PYTHON_BIN:-python3}"
readonly MCP_NAME_PATTERN="${PAPER2ZOTERO_MCP_NAME_PATTERN:-zotero}"
readonly TOOLS_EXPOSED="${PAPER2ZOTERO_MCP_TOOLS_EXPOSED:-unknown}"

emit() {
  printf '%s=%s\n' "$1" "$2"
}

registry_json=""
if ! command -v "${CODEX_BIN}" >/dev/null 2>&1; then
  emit "connection_registration" "unknown"
  emit "session_tools" "${TOOLS_EXPOSED}"
  emit "diagnosis" "registry-unavailable"
  exit 0
fi

if ! registry_json="$(${CODEX_BIN} mcp list --json 2>/dev/null)"; then
  emit "connection_registration" "unknown"
  emit "session_tools" "${TOOLS_EXPOSED}"
  emit "diagnosis" "registry-unavailable"
  exit 0
fi

registered="$(${PYTHON_BIN} -c '
import json
import sys

pattern = sys.argv[1].casefold()
try:
    servers = json.load(sys.stdin)
except Exception:
    raise SystemExit(2)

matches = [s for s in servers if pattern in str(s.get("name", "")).casefold()]
if not matches:
    raise SystemExit(1)

server = matches[0]
transport = server.get("transport") or {}
values = [
    "true" if server.get("enabled") else "false",
    str(transport.get("type") or "unknown"),
    str(transport.get("url") or ""),
]
print("\t".join(values))
' "${MCP_NAME_PATTERN}" <<<"${registry_json}" 2>/dev/null)"
parse_status=$?

if [[ ${parse_status} -eq 1 ]]; then
  emit "connection_registration" "not-configured"
  emit "session_tools" "${TOOLS_EXPOSED}"
  emit "diagnosis" "not-configured"
  exit 0
elif [[ ${parse_status} -ne 0 ]]; then
  emit "connection_registration" "unknown"
  emit "session_tools" "${TOOLS_EXPOSED}"
  emit "diagnosis" "registry-unreadable"
  exit 0
fi

IFS=$'\t' read -r enabled transport endpoint <<<"${registered}"
emit "connection_registration" "configured"
emit "connection_enabled" "${enabled}"
emit "session_tools" "${TOOLS_EXPOSED}"
emit "transport" "${transport}"

if [[ "${enabled}" != "true" ]]; then
  emit "diagnosis" "configured-disabled"
  exit 0
fi

if [[ "${TOOLS_EXPOSED}" == "yes" ]]; then
  emit "diagnosis" "session-tools-exposed"
  exit 0
fi

if [[ "${transport}" != "streamable_http" || -z "${endpoint}" ]]; then
  emit "endpoint_probe" "not-applicable"
  emit "diagnosis" "configured-not-exposed"
  exit 0
fi

if command -v "${CURL_BIN}" >/dev/null 2>&1 && \
  "${CURL_BIN}" -fsS --noproxy '*' --max-time 2 "${endpoint}" >/dev/null 2>&1; then
  emit "endpoint_probe" "available"
  emit "diagnosis" "mcp-endpoint-available"
  exit 0
fi

emit "endpoint_probe" "failed"

port="$(${PYTHON_BIN} -c '
import sys
from urllib.parse import urlparse

parsed = urlparse(sys.argv[1])
if parsed.hostname not in {"127.0.0.1", "localhost", "::1"}:
    raise SystemExit(1)
print(parsed.port or (443 if parsed.scheme == "https" else 80))
' "${endpoint}" 2>/dev/null)"

if [[ -n "${port}" ]] && command -v "${LSOF_BIN}" >/dev/null 2>&1; then
  if "${LSOF_BIN}" -nP "-iTCP:${port}" -sTCP:LISTEN >/dev/null 2>&1; then
    emit "local_listener" "present"
    emit "diagnosis" "sandbox-retry-required"
  else
    emit "local_listener" "absent"
    emit "diagnosis" "service-unreachable-unverified"
  fi
else
  emit "local_listener" "unknown"
  emit "diagnosis" "service-unreachable-unverified"
fi
