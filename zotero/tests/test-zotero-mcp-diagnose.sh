#!/usr/bin/env bash

set -euo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SCRIPT="${ROOT_DIR}/scripts/zotero-mcp-diagnose.sh"
readonly TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/paper2zotero-mcp-test.XXXXXX")"
trap 'rm -rf -- "${TEST_ROOT}"' EXIT

write_fake_codex() {
  mkdir -p -- "${TEST_ROOT}/bin"
  cat > "${TEST_ROOT}/bin/codex" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${FAKE_REGISTRY_JSON}"
EOF
  chmod +x "${TEST_ROOT}/bin/codex"
}

write_fake_probe() {
  local curl_exit="$1"
  local listener="$2"
  cat > "${TEST_ROOT}/bin/curl" <<EOF
#!/usr/bin/env bash
exit ${curl_exit}
EOF
  cat > "${TEST_ROOT}/bin/lsof" <<EOF
#!/usr/bin/env bash
[[ "${listener}" == "present" ]]
EOF
  chmod +x "${TEST_ROOT}/bin/curl" "${TEST_ROOT}/bin/lsof"
}

run_case() {
  local expected="$1"
  local output
  shift
  output="$(env PATH="${TEST_ROOT}/bin:${PATH}" CODEX_BIN=codex CURL_BIN=curl LSOF_BIN=lsof "$@" "${SCRIPT}")"
  grep -q "^diagnosis=${expected}$" <<<"${output}" || {
    printf 'Expected diagnosis=%s, got:\n%s\n' "${expected}" "${output}" >&2
    exit 1
  }
}

write_fake_codex

export FAKE_REGISTRY_JSON='[]'
write_fake_probe 1 absent
run_case not-configured env PAPER2ZOTERO_MCP_TOOLS_EXPOSED=no

export FAKE_REGISTRY_JSON='[{"name":"zotero","enabled":true,"transport":{"type":"streamable_http","url":"http://127.0.0.1:23120/mcp"}}]'
write_fake_probe 0 absent
run_case mcp-endpoint-available env PAPER2ZOTERO_MCP_TOOLS_EXPOSED=no

write_fake_probe 1 present
run_case sandbox-retry-required env PAPER2ZOTERO_MCP_TOOLS_EXPOSED=no

write_fake_probe 1 absent
run_case service-unreachable-unverified env PAPER2ZOTERO_MCP_TOOLS_EXPOSED=no

write_fake_probe 1 absent
run_case session-tools-exposed env PAPER2ZOTERO_MCP_TOOLS_EXPOSED=yes

printf '%s\n' "All Zotero MCP diagnosis tests passed."
