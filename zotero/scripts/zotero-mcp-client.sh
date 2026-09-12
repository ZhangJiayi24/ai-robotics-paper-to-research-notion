#!/usr/bin/env bash

set -euo pipefail

readonly CODEX_BIN="${CODEX_BIN:-codex}"
readonly CURL_BIN="${CURL_BIN:-curl}"
readonly PYTHON_BIN="${PYTHON_BIN:-python3}"
readonly MCP_NAME_PATTERN="${PAPER2ZOTERO_MCP_NAME_PATTERN:-zotero}"
readonly REQUEST_TIMEOUT="${PAPER2ZOTERO_MCP_TIMEOUT:-60}"

usage() {
  echo "Usage: zotero-mcp-client.sh {list-tools|call TOOL JSON_ARGUMENTS}" >&2
  exit 2
}

[[ $# -ge 1 ]] || usage
readonly ACTION="$1"
shift

registry_json="$(${CODEX_BIN} mcp list --json 2>/dev/null)"
endpoint="$(printf '%s' "${registry_json}" | ${PYTHON_BIN} -c '
import json
import sys

pattern = sys.argv[1].casefold()
servers = json.load(sys.stdin)
matches = [
    server for server in servers
    if pattern in str(server.get("name", "")).casefold()
    and server.get("enabled")
]
if not matches:
    raise SystemExit("No enabled Zotero MCP connection is registered.")
transport = matches[0].get("transport") or {}
if transport.get("type") != "streamable_http" or not transport.get("url"):
    raise SystemExit("The registered Zotero MCP does not use streamable HTTP.")
print(transport["url"])
' "${MCP_NAME_PATTERN}")"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/paper2zotero-mcp.XXXXXX")"
trap 'rm -rf -- "${tmp_dir}"' EXIT
headers_file="${tmp_dir}/headers"
init_file="${tmp_dir}/initialize.json"

${CURL_BIN} -fsS --noproxy '*' --max-time "${REQUEST_TIMEOUT}" \
  -D "${headers_file}" -o "${init_file}" -X POST "${endpoint}" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  --data '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"paper2zotero","version":"1.0"}}}'

session_id="$(awk 'BEGIN{IGNORECASE=1} /^Mcp-Session-Id:/ {gsub("\r", "", $2); print $2; exit}' "${headers_file}")"
session_headers=()
if [[ -n "${session_id}" ]]; then
  session_headers=(-H "Mcp-Session-Id: ${session_id}")
fi

request_id=2
case "${ACTION}" in
  list-tools)
    [[ $# -eq 0 ]] || usage
    payload='{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
    ;;
  call)
    [[ $# -eq 2 ]] || usage
    tool_name="$1"
    arguments="$2"
    payload="$(${PYTHON_BIN} -c '
import json
import sys

tool_name = sys.argv[1]
arguments = json.loads(sys.argv[2])
if not isinstance(arguments, dict):
    raise SystemExit("JSON_ARGUMENTS must be an object.")
print(json.dumps({
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/call",
    "params": {"name": tool_name, "arguments": arguments},
}, ensure_ascii=False))
' "${tool_name}" "${arguments}")"
    ;;
  *) usage ;;
esac

${CURL_BIN} -fsS --noproxy '*' --max-time "${REQUEST_TIMEOUT}" \
  -X POST "${endpoint}" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  "${session_headers[@]}" \
  --data-binary "${payload}"
