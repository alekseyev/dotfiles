---
name: nicegui-quirks
description: |
  Pitfalls and workarounds when writing NiceGUI / Quasar code — layout centering, input prop forwarding, dialog/upload/table/select gotchas, browser-side JS interop, and cookie/auth flows. Apply these when writing or reviewing NiceGUI page code so you don't rediscover the same bugs.

  TRIGGER when: editing or writing Python that imports `nicegui` or calls `ui.*` / `app.*` from NiceGUI; user asks about NiceGUI, Quasar, or any of `ui.dialog` / `ui.upload` / `ui.table` / `ui.select` / `ui.input` / `ui.html` / `ui.add_body_html` / `ui.run_javascript` / `ui.navigate`; user is debugging a NiceGUI page that "looks wrong" or behaves unexpectedly in the browser.

  SKIP: non-Python files; Python without NiceGUI imports; general web/frontend questions unrelated to NiceGUI.
---

# NiceGUI / Quasar quirks

These are not in the NiceGUI docs (or are easy to miss). Apply them proactively when writing NiceGUI code — don't wait to be bitten.

## Layout

- **Page content is a flex column with `items-start`.** `margin: auto` on a child won't horizontally center it. To center, run `ui.query(".nicegui-content").classes("items-center")` at the top of the page.

## Inputs & forms

- **`.props("id=...")` on `ui.input` lands on the Quasar wrapper, not the inner `<input>`.** So `document.getElementById(...).value` returns `undefined`. To get values from browser-side JS, prefer `input.value` via NiceGUI's binding; if you must query the DOM, use `name=` or `input-class=` (Quasar forwards both to the inner native input).
- **`ui.input` does not debounce by default** — every keystroke fires `on_change`. Pass `debounce=N` (ms) as a prop to throttle.

## Component quirks

- **`ui.dialog` is hidden, not removed, on close.** Repeated open/create leaks DOM. Either create the dialog once and reuse it, or call `.clear()` after dismissal.
- **`ui.upload` buffers the entire file before invoking the handler** — it is not streaming. For large files, mount a raw FastAPI route on `app` (NiceGUI's `app` *is* a FastAPI instance) and iterate `request.stream()`.
- **`ui.table` doesn't auto-forward custom slot `$emit` events to Python.** Vue events emitted inside slot templates don't bubble up to NiceGUI. Use the table's built-in row/selection events, or invoke a callback via JS.
- **`ui.select` async search doesn't work via `bind_options_from`.** For server-side filtering (e.g. ES autocomplete), listen for Quasar's `filter` event directly. Initial dict values can also break `option-label`/`option-value` rendering — prefer plain strings or map manually.

## Browser-side JS interop

- **`ui.html()` content has Vue's `v-html` sanitization applied** — inline event handlers (`onclick=`, `onchange=`, etc.) in raw HTML strings get stripped for XSS protection. Either use NiceGUI components or attach listeners via a separate `<script>` block.
- **`ui.add_body_html` content lives outside NiceGUI's Vue component tree** — visible elements injected this way can end up hidden or unstyled. Use `ui.html()` for visible content (lives in the component tree); reserve `ui.add_body_html()` for `<script>` blocks.
- **`ui.run_javascript`'s default timeout is 1.0s** — too short for any `fetch()`-based snippet. Bump to ~10s.

## Cookies & auth

- **Browser cookies can't be set via the NiceGUI WebSocket.** Any flow that needs to set a session cookie (login is the canonical example) must originate from a real browser HTTP request — typically a `fetch()` invoked from `ui.run_javascript`.
- **`ui.navigate.to()` is SPA navigation** — it won't pick up fresh auth/server state. Use `ui.navigate.reload()` or set `window.location.href` when you need a full reload.

## Maintenance

When you discover a new quirk in any project, append it here (and prune entries that newer NiceGUI versions have fixed).

