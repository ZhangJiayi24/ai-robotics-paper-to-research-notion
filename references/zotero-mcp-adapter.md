# Zotero MCP Adapter

Zotero MCP servers do not share one universal tool namespace. Inspect the connected server's actual tool schemas and map capabilities by meaning rather than assuming a specific implementation.

## Connection Discovery

Discover Zotero through the MCP connections and tools exposed by the current Codex environment. Do not read a repository-local endpoint, assume a port, infer a Zotero storage directory, or persist machine-specific connection data in this skill.

Treat tool exposure, connection registration, endpoint reachability, and tool-call success as separate signals. An empty Zotero tool list proves only that the current session did not expose Zotero tools. Before reporting the MCP as missing, inspect Codex's native connection registry or connection-management state without assuming a user-specific config path. If a registered endpoint is available, probe only that endpoint with a read-only status or MCP handshake.

If an in-sandbox probe fails, retry outside the sandbox only after the required approval. A successful authorized retry means `sandbox-blocked`, not `service-unreachable`. If approval is unavailable, report `configured-unverified`.

Native task wrappers are preferred but are not the authority on MCP availability. When a Codex-registered streamable HTTP endpoint completes the MCP handshake but wrappers are absent, use `scripts/zotero-mcp-client.sh` as a standard MCP transport fallback. Build the same schema-driven capability map from `tools/list`, preserve the same confirmation and write-verification rules, and never access the Zotero database or storage directly. Do not use an endpoint guessed from a port or pasted into the repository; the fallback may use only the connection returned by Codex's registry.

## Transport Priority And Authorization

1. Prefer native MCP tool wrappers whenever the task exposes them.
2. If wrappers are absent, standard MCP HTTP transport is allowed only after confirming the Codex-registered connection, the local endpoint, a successful MCP handshake, and the user's authorization to use the fallback.
3. Read-only initialization may use the fallback only for schema, library, search, and content checks needed by the request.
4. A mutation requires explicit Zotero write intent in the current user request. Capture every returned stable key and immediately re-read the parent item or its children through MCP.
5. If the mutation response cannot be re-read and verified, report the write as unverified; never claim persistence from an echoed request alone.
6. Standard MCP HTTP transport is still MCP. The prohibited paths are guessed endpoints, repository-persisted connection details, and direct Zotero database or storage access.

When Codex connection registration cannot be read or no reliable Zotero connection can be identified, ask the user to copy the MCP client configuration shown in Zotero's MCP settings. Treat it as sensitive runtime input: validate its transport shape, do not echo credentials, do not execute arbitrary commands from it, and never persist it in this repository or generated research artifacts. Add or update the connection only through Codex's native MCP configuration flow, then reload the session and repeat read-only discovery.

During `paper2zotero 初始化`, build a runtime capability map from the actual tool schemas. If more than one connected server exposes plausible Zotero semantics and the active library cannot be determined safely, ask the user to choose the connection. If no compatible connection exists, stop and direct the user to Codex's native MCP connection flow; do not invent a server configuration.

## Capability Map

| Semantic operation | Common tool-name patterns | Required behavior |
|---|---|---|
| Check connection/library | `zotero_status`, `status`, `libraries` | Confirm readable library and, if supported, active library |
| Search items | `zotero_search`, `search_items`, `zotero_search_items` | Query DOI/arXiv/title/author and return stable item keys |
| Read one item | `zotero_item`, `get_item`, `zotero_get_item` | Return metadata and stable parent key |
| List children | `get_children`, `zotero_get_children`, item detail | Return attachments and child notes |
| Read notes | `get_notes`, `zotero_get_notes`, item detail | Return note key, parent key, and content |
| Read full text | `get_fulltext`, `zotero_get_fulltext`, `read_pdf` | Return searchable text, ideally with page boundaries |
| Resolve PDF | `get_pdf_path`, `list_attachments`, `zotero_attachments` | Identify the PDF attachment key/path without guessing |
| Import generated PDF | `write_item` import, `import_attachment`, `attach_file` | Import a verified local PDF under the intended parent item and return an attachment key |
| Add tags | `add_tags`, `zotero_add_tags`, item update | Add without replacing existing tags |
| Create/import item | `create_item`, `zotero_import`, `add_by_doi`, `add_by_url` | Return new item key and avoid duplicates |

These are recognition hints, not commands. The connected MCP's schema is authoritative.

## Safe Fallbacks

- Search unavailable: the workflow cannot safely resolve a library item; stop before writing.
- Full text unavailable but a user-supplied PDF is readable: analyze the PDF, but write only after the Zotero item and attachment are resolved.
- PDF import unavailable: preserve the verified local PDF but do not claim Zotero persistence.
- Page-aware extraction unavailable: use verified figure/table/section anchors inside the generated memo PDF and omit unverified page numbers.
- Metadata patch unavailable: leave metadata unchanged and report gaps.
- Import unavailable: do not create a local file as a substitute for Zotero import.

## Generated PDF Import

The generated memo must be a valid local PDF before import. Use the connector's import operation with the absolute file path, parent item key, and a clear attachment title. Do not import HTML/Markdown as a substitute and do not re-parent or replace the source-paper attachment.

## Identity And Duplicate Rules

Use this matching order:

1. normalized DOI;
2. normalized arXiv identifier;
3. exact normalized title plus year and first author;
4. exact normalized title with manual disambiguation.

Normalize identifiers for comparison only; preserve canonical display values in Zotero. Do not merge, delete, or move duplicates under this workflow.

## Write Verification

After each mutation, capture the returned item or note key. Re-read the parent item or its children when supported. A response that merely echoes the request is not sufficient evidence of persistence.
