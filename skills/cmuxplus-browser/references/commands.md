# Command Reference (CMUX+ Browser)

This maps common `agent-browser` usage to `cmuxplus browser` usage.

## Direct Equivalents

- `agent-browser open <url>` -> `cmuxplus browser open <url>`
- `agent-browser goto|navigate <url>` -> `cmuxplus browser <surface> goto|navigate <url>`
- `agent-browser snapshot -i` -> `cmuxplus browser <surface> snapshot --interactive`
- `agent-browser click <ref>` -> `cmuxplus browser <surface> click <ref>`
- `agent-browser fill <ref> <text>` -> `cmuxplus browser <surface> fill <ref> <text>`
- `agent-browser type <ref> <text>` -> `cmuxplus browser <surface> type <ref> <text>`
- `agent-browser select <ref> <value>` -> `cmuxplus browser <surface> select <ref> <value>`
- `agent-browser get text <ref>` -> `cmuxplus browser <surface> get text <ref-or-selector>`
- `agent-browser get url` -> `cmuxplus browser <surface> get url`
- `agent-browser get title` -> `cmuxplus browser <surface> get title`

## Core Command Groups

### Navigation

```bash
cmuxplus browser open <url>                        # opens in caller's workspace (uses CMUX_WORKSPACE_ID)
cmuxplus browser open <url> --workspace <id|ref>   # opens in a specific workspace
cmuxplus browser <surface> goto <url>
cmuxplus browser <surface> back|forward|reload
cmuxplus browser <surface> get url|title
```

> **Workspace context:** `browser open` targets the workspace of the terminal where the command is run (via `CMUX_WORKSPACE_ID`), even if a different workspace is currently focused. Use `--workspace` to override.

### Snapshot and Inspection

```bash
cmuxplus browser <surface> snapshot --interactive
cmuxplus browser <surface> snapshot --interactive --compact --max-depth 3
cmuxplus browser <surface> get text body
cmuxplus browser <surface> get html body
cmuxplus browser <surface> get value "#email"
cmuxplus browser <surface> get attr "#email" --attr placeholder
cmuxplus browser <surface> get count ".row"
cmuxplus browser <surface> get box "#submit"
cmuxplus browser <surface> get styles "#submit" --property color
cmuxplus browser <surface> eval '<js>'
```

### Interaction

```bash
cmuxplus browser <surface> click|dblclick|hover|focus <selector-or-ref>
cmuxplus browser <surface> fill <selector-or-ref> [text]   # empty text clears
cmuxplus browser <surface> type <selector-or-ref> <text>
cmuxplus browser <surface> press|keydown|keyup <key>
cmuxplus browser <surface> select <selector-or-ref> <value>
cmuxplus browser <surface> check|uncheck <selector-or-ref>
cmuxplus browser <surface> scroll [--selector <css>] [--dx <n>] [--dy <n>]
```

### Wait

```bash
cmuxplus browser <surface> wait --selector "#ready" --timeout-ms 10000
cmuxplus browser <surface> wait --text "Done" --timeout-ms 10000
cmuxplus browser <surface> wait --url-contains "/dashboard" --timeout-ms 10000
cmuxplus browser <surface> wait --load-state complete --timeout-ms 15000
cmuxplus browser <surface> wait --function "document.readyState === 'complete'" --timeout-ms 10000
```

### Session/State

```bash
cmuxplus browser <surface> cookies get|set|clear ...
cmuxplus browser <surface> storage local|session get|set|clear ...
cmuxplus browser <surface> tab list|new|switch|close ...
cmuxplus browser <surface> state save|load <path>
```

### Diagnostics

```bash
cmuxplus browser <surface> console list|clear
cmuxplus browser <surface> errors list|clear
cmuxplus browser <surface> highlight <selector>
cmuxplus browser <surface> screenshot
cmuxplus browser <surface> download wait --timeout-ms 10000
```

## Agent Reliability Tips

- Use `--snapshot-after` on mutating actions to return a fresh post-action snapshot.
- Re-snapshot after navigation, modal open/close, or major DOM changes.
- Prefer short handles in outputs by default (`surface:N`, `pane:N`, `workspace:N`, `window:N`).
- Use `--id-format both` only when a UUID must be logged/exported.

## Known WKWebView Gaps (`not_supported`)

- `browser.viewport.set`
- `browser.geolocation.set`
- `browser.offline.set`
- `browser.trace.start|stop`
- `browser.network.route|unroute|requests`
- `browser.screencast.start|stop`
- `browser.input_mouse|input_keyboard|input_touch`

See also:
- [snapshot-refs.md](snapshot-refs.md)
- [authentication.md](authentication.md)
- [session-management.md](session-management.md)
